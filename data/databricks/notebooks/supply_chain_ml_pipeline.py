# Databricks notebook source
# MAGIC %md
# MAGIC # Supply Chain ML Pipeline
# MAGIC 
# MAGIC This notebook implements machine learning models for Bosch's supply chain prediction and optimization.
# MAGIC It includes demand forecasting, anomaly detection, and logistics optimization models.

# COMMAND ----------

# MAGIC %md
# MAGIC ## Configuration and Imports

# COMMAND ----------

from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.types import *
from pyspark.ml import Pipeline
from pyspark.ml.feature import VectorAssembler, StandardScaler, StringIndexer
from pyspark.ml.regression import RandomForestRegressor, LinearRegression
from pyspark.ml.classification import RandomForestClassifier, LogisticRegression
from pyspark.ml.clustering import KMeans
from pyspark.ml.evaluation import RegressionEvaluator, ClassificationEvaluator
import mlflow
import mlflow.spark
import json
from datetime import datetime, timedelta
import logging
import numpy as np

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# COMMAND ----------

# MAGIC %md
# MAGIC ## Initialize MLflow and Configuration

# COMMAND ----------

# Initialize MLflow
mlflow.set_tracking_uri("databricks")
mlflow.set_experiment("/Shared/SupplyChainML")

# Get Spark session
spark = SparkSession.builder.appName("SupplyChainML").getOrCreate()

# Set Spark configurations for ML
spark.conf.set("spark.sql.adaptive.enabled", "true")
spark.conf.set("spark.sql.adaptive.coalescePartitions.enabled", "true")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Data Preparation

# COMMAND ----------

def prepare_ml_data():
    """Prepare data for machine learning models"""
    
    logger.info("Preparing ML data...")
    
    # Read gold layer data
    supply_chain_metrics_df = spark.read.format("delta").load("/mnt/data-lake/gold/supply_chain_metrics")
    material_performance_df = spark.read.format("delta").load("/mnt/data-lake/gold/material_performance")
    carrier_performance_df = spark.read.format("delta").load("/mnt/data-lake/gold/carrier_performance")
    
    # Read IoT sensor data
    warehouse_sensors_df = spark.read.format("delta").load("/mnt/data-lake/silver/iot/warehouse_sensors")
    factory_sensors_df = spark.read.format("delta").load("/mnt/data-lake/silver/iot/factory_sensors")
    transport_sensors_df = spark.read.format("delta").load("/mnt/data-lake/silver/iot/transport_sensors")
    
    # Create feature engineering
    # Time-based features
    supply_chain_metrics_df = supply_chain_metrics_df.withColumn(
        "order_month", month(col("order_date"))
    ).withColumn(
        "order_quarter", quarter(col("order_date"))
    ).withColumn(
        "order_day_of_week", dayofweek(col("order_date"))
    )
    
    # Performance features
    supply_chain_metrics_df = supply_chain_metrics_df.withColumn(
        "delivery_performance", 
        when(col("delivery_delay_days") <= 0, 1).otherwise(0)
    ).withColumn(
        "delay_severity",
        when(col("delivery_delay_days") <= 0, 0)
        .when(col("delivery_delay_days") <= 3, 1)
        .when(col("delivery_delay_days") <= 7, 2)
        .otherwise(3)
    )
    
    # IoT sensor aggregations
    warehouse_metrics = warehouse_sensors_df.groupBy("location_id").agg(
        avg("temperature").alias("avg_temperature"),
        avg("humidity").alias("avg_humidity"),
        avg("pressure").alias("avg_pressure"),
        count("*").alias("sensor_count")
    )
    
    factory_metrics = factory_sensors_df.groupBy("machine_id").agg(
        avg("vibration").alias("avg_vibration"),
        avg("temperature").alias("avg_temperature"),
        avg("pressure").alias("avg_pressure"),
        count("*").alias("sensor_count")
    )
    
    transport_metrics = transport_sensors_df.groupBy("vehicle_id").agg(
        avg("speed").alias("avg_speed"),
        avg("temperature").alias("avg_temperature"),
        avg("fuel_level").alias("avg_fuel_level"),
        count("*").alias("sensor_count")
    )
    
    logger.info("ML data preparation completed")
    
    return supply_chain_metrics_df, material_performance_df, carrier_performance_df, warehouse_metrics, factory_metrics, transport_metrics

# COMMAND ----------

# MAGIC %md
# MAGIC ## Demand Forecasting Model

# COMMAND ----------

def train_demand_forecasting_model(supply_chain_metrics_df):
    """Train demand forecasting model using Random Forest"""
    
    logger.info("Training demand forecasting model...")
    
    with mlflow.start_run(run_name="demand_forecasting"):
        
        # Prepare features for demand forecasting
        demand_features = supply_chain_metrics_df.select(
            col("material_id"),
            col("order_month"),
            col("order_quarter"),
            col("order_day_of_week"),
            col("delivery_delay_days"),
            col("reliability_score"),
            col("order_quantity").alias("target")
        ).filter(col("target").isNotNull())
        
        # Feature engineering
        feature_columns = ["order_month", "order_quarter", "order_day_of_week", "delivery_delay_days", "reliability_score"]
        
        # Create feature vector
        assembler = VectorAssembler(
            inputCols=feature_columns,
            outputCol="features"
        )
        
        # Standardize features
        scaler = StandardScaler(
            inputCol="features",
            outputCol="scaled_features"
        )
        
        # Random Forest model
        rf_model = RandomForestRegressor(
            featuresCol="scaled_features",
            labelCol="target",
            numTrees=100,
            maxDepth=10,
            seed=42
        )
        
        # Create pipeline
        pipeline = Pipeline(stages=[assembler, scaler, rf_model])
        
        # Split data
        train_data, test_data = demand_features.randomSplit([0.8, 0.2], seed=42)
        
        # Train model
        model = pipeline.fit(train_data)
        
        # Make predictions
        predictions = model.transform(test_data)
        
        # Evaluate model
        evaluator = RegressionEvaluator(
            labelCol="target",
            predictionCol="prediction",
            metricName="rmse"
        )
        
        rmse = evaluator.evaluate(predictions)
        mae = evaluator.evaluate(predictions, {evaluator.metricName: "mae"})
        r2 = evaluator.evaluate(predictions, {evaluator.metricName: "r2"})
        
        # Log metrics
        mlflow.log_metric("rmse", rmse)
        mlflow.log_metric("mae", mae)
        mlflow.log_metric("r2", r2)
        
        # Log model
        mlflow.spark.log_model(model, "demand_forecasting_model")
        
        logger.info(f"Demand forecasting model trained - RMSE: {rmse:.4f}, MAE: {mae:.4f}, R2: {r2:.4f}")
        
        return model

# COMMAND ----------

# MAGIC %md
# MAGIC ## Anomaly Detection Model

# COMMAND ----------

def train_anomaly_detection_model(supply_chain_metrics_df):
    """Train anomaly detection model using K-Means clustering"""
    
    logger.info("Training anomaly detection model...")
    
    with mlflow.start_run(run_name="anomaly_detection"):
        
        # Prepare features for anomaly detection
        anomaly_features = supply_chain_metrics_df.select(
            col("delivery_delay_days"),
            col("reliability_score"),
            col("order_quantity"),
            col("order_month"),
            col("order_quarter")
        ).filter(col("delivery_delay_days").isNotNull())
        
        # Feature engineering
        feature_columns = ["delivery_delay_days", "reliability_score", "order_quantity", "order_month", "order_quarter"]
        
        # Create feature vector
        assembler = VectorAssembler(
            inputCols=feature_columns,
            outputCol="features"
        )
        
        # Standardize features
        scaler = StandardScaler(
            inputCol="features",
            outputCol="scaled_features"
        )
        
        # K-Means model
        kmeans_model = KMeans(
            featuresCol="scaled_features",
            k=3,  # Number of clusters
            seed=42
        )
        
        # Create pipeline
        pipeline = Pipeline(stages=[assembler, scaler, kmeans_model])
        
        # Train model
        model = pipeline.fit(anomaly_features)
        
        # Make predictions
        predictions = model.transform(anomaly_features)
        
        # Calculate cluster centers and distances
        cluster_centers = model.stages[-1].clusterCenters()
        
        # Calculate distance to cluster centers for anomaly detection
        def calculate_distance_to_centers(features, centers):
            distances = []
            for center in centers:
                distance = np.sqrt(np.sum((features - center) ** 2))
                distances.append(distance)
            return min(distances)
        
        # Add distance column
        from pyspark.sql.functions import udf
        from pyspark.sql.types import DoubleType
        
        distance_udf = udf(lambda features: calculate_distance_to_centers(features, cluster_centers), DoubleType())
        predictions = predictions.withColumn("distance_to_center", distance_udf(col("scaled_features")))
        
        # Define anomaly threshold (e.g., 95th percentile of distances)
        threshold = predictions.select(percentile_approx("distance_to_center", 0.95)).collect()[0][0]
        
        # Mark anomalies
        predictions = predictions.withColumn(
            "is_anomaly",
            when(col("distance_to_center") > threshold, 1).otherwise(0)
        )
        
        # Log metrics
        anomaly_count = predictions.filter(col("is_anomaly") == 1).count()
        total_count = predictions.count()
        anomaly_rate = anomaly_count / total_count
        
        mlflow.log_metric("anomaly_count", anomaly_count)
        mlflow.log_metric("anomaly_rate", anomaly_rate)
        mlflow.log_metric("threshold", threshold)
        
        # Log model
        mlflow.spark.log_model(model, "anomaly_detection_model")
        
        logger.info(f"Anomaly detection model trained - Anomaly rate: {anomaly_rate:.4f}")
        
        return model, threshold

# COMMAND ----------

# MAGIC %md
# MAGIC ## Carrier Performance Prediction Model

# COMMAND ----------

def train_carrier_performance_model(carrier_performance_df):
    """Train carrier performance prediction model"""
    
    logger.info("Training carrier performance model...")
    
    with mlflow.start_run(run_name="carrier_performance"):
        
        # Prepare features for carrier performance
        carrier_features = carrier_performance_df.select(
            col("carrier_name"),
            col("total_shipments"),
            col("avg_delay_days"),
            col("avg_reliability_score"),
            col("success_rate").alias("target")
        ).filter(col("target").isNotNull())
        
        # Feature engineering
        feature_columns = ["total_shipments", "avg_delay_days", "avg_reliability_score"]
        
        # Create feature vector
        assembler = VectorAssembler(
            inputCols=feature_columns,
            outputCol="features"
        )
        
        # Standardize features
        scaler = StandardScaler(
            inputCol="features",
            outputCol="scaled_features"
        )
        
        # Random Forest model
        rf_model = RandomForestRegressor(
            featuresCol="scaled_features",
            labelCol="target",
            numTrees=50,
            maxDepth=8,
            seed=42
        )
        
        # Create pipeline
        pipeline = Pipeline(stages=[assembler, scaler, rf_model])
        
        # Split data
        train_data, test_data = carrier_features.randomSplit([0.8, 0.2], seed=42)
        
        # Train model
        model = pipeline.fit(train_data)
        
        # Make predictions
        predictions = model.transform(test_data)
        
        # Evaluate model
        evaluator = RegressionEvaluator(
            labelCol="target",
            predictionCol="prediction",
            metricName="rmse"
        )
        
        rmse = evaluator.evaluate(predictions)
        mae = evaluator.evaluate(predictions, {evaluator.metricName: "mae"})
        r2 = evaluator.evaluate(predictions, {evaluator.metricName: "r2"})
        
        # Log metrics
        mlflow.log_metric("rmse", rmse)
        mlflow.log_metric("mae", mae)
        mlflow.log_metric("r2", r2)
        
        # Log model
        mlflow.spark.log_model(model, "carrier_performance_model")
        
        logger.info(f"Carrier performance model trained - RMSE: {rmse:.4f}, MAE: {mae:.4f}, R2: {r2:.4f}")
        
        return model

# COMMAND ----------

# MAGIC %md
# MAGIC ## Supply Chain Optimization Model

# COMMAND ----------

def train_supply_chain_optimization_model(supply_chain_metrics_df):
    """Train supply chain optimization model"""
    
    logger.info("Training supply chain optimization model...")
    
    with mlflow.start_run(run_name="supply_chain_optimization"):
        
        # Prepare features for optimization
        optimization_features = supply_chain_metrics_df.select(
            col("material_id"),
            col("order_month"),
            col("order_quarter"),
            col("order_day_of_week"),
            col("delivery_delay_days"),
            col("reliability_score"),
            col("order_quantity"),
            col("delivery_performance").alias("target")
        ).filter(col("target").isNotNull())
        
        # Feature engineering
        feature_columns = ["order_month", "order_quarter", "order_day_of_week", "delivery_delay_days", "reliability_score", "order_quantity"]
        
        # Create feature vector
        assembler = VectorAssembler(
            inputCols=feature_columns,
            outputCol="features"
        )
        
        # Standardize features
        scaler = StandardScaler(
            inputCol="features",
            outputCol="scaled_features"
        )
        
        # Logistic Regression model
        lr_model = LogisticRegression(
            featuresCol="scaled_features",
            labelCol="target",
            maxIter=100,
            regParam=0.01
        )
        
        # Create pipeline
        pipeline = Pipeline(stages=[assembler, scaler, lr_model])
        
        # Split data
        train_data, test_data = optimization_features.randomSplit([0.8, 0.2], seed=42)
        
        # Train model
        model = pipeline.fit(train_data)
        
        # Make predictions
        predictions = model.transform(test_data)
        
        # Evaluate model
        evaluator = ClassificationEvaluator(
            labelCol="target",
            predictionCol="prediction",
            metricName="accuracy"
        )
        
        accuracy = evaluator.evaluate(predictions)
        precision = evaluator.evaluate(predictions, {evaluator.metricName: "weightedPrecision"})
        recall = evaluator.evaluate(predictions, {evaluator.metricName: "weightedRecall"})
        f1 = evaluator.evaluate(predictions, {evaluator.metricName: "f1"})
        
        # Log metrics
        mlflow.log_metric("accuracy", accuracy)
        mlflow.log_metric("precision", precision)
        mlflow.log_metric("recall", recall)
        mlflow.log_metric("f1", f1)
        
        # Log model
        mlflow.spark.log_model(model, "supply_chain_optimization_model")
        
        logger.info(f"Supply chain optimization model trained - Accuracy: {accuracy:.4f}, F1: {f1:.4f}")
        
        return model

# COMMAND ----------

# MAGIC %md
# MAGIC ## Model Deployment and Inference

# COMMAND ----------

def deploy_models(models):
    """Deploy trained models for inference"""
    
    logger.info("Deploying models...")
    
    # Save models to MLflow Model Registry
    for model_name, model in models.items():
        with mlflow.start_run(run_name=f"deploy_{model_name}"):
            # Log model to registry
            mlflow.spark.log_model(
                model, 
                f"{model_name}_model",
                registered_model_name=f"supply_chain_{model_name}"
            )
    
    logger.info("Models deployed successfully")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Main ML Pipeline Execution

# COMMAND ----------

def main():
    """Main ML pipeline execution"""
    
    logger.info("Starting Supply Chain ML Pipeline...")
    
    try:
        # Prepare data
        supply_chain_metrics_df, material_performance_df, carrier_performance_df, warehouse_metrics, factory_metrics, transport_metrics = prepare_ml_data()
        
        # Train models
        demand_forecasting_model = train_demand_forecasting_model(supply_chain_metrics_df)
        anomaly_detection_model, threshold = train_anomaly_detection_model(supply_chain_metrics_df)
        carrier_performance_model = train_carrier_performance_model(carrier_performance_df)
        optimization_model = train_supply_chain_optimization_model(supply_chain_metrics_df)
        
        # Deploy models
        models = {
            "demand_forecasting": demand_forecasting_model,
            "anomaly_detection": anomaly_detection_model,
            "carrier_performance": carrier_performance_model,
            "optimization": optimization_model
        }
        
        deploy_models(models)
        
        logger.info("Supply Chain ML Pipeline completed successfully")
        
    except Exception as e:
        logger.error(f"ML Pipeline failed: {str(e)}")
        raise e

# COMMAND ----------

# Execute the main pipeline
if __name__ == "__main__":
    main()

# COMMAND ----------

# MAGIC %md
# MAGIC ## Pipeline Completion
# MAGIC 
# MAGIC The Supply Chain ML Pipeline has been executed successfully. The following models have been trained and deployed:
# MAGIC 
# MAGIC 1. **Demand Forecasting Model**: Predicts future demand for materials and products
# MAGIC 2. **Anomaly Detection Model**: Identifies unusual patterns in supply chain data
# MAGIC 3. **Carrier Performance Model**: Predicts carrier reliability and performance
# MAGIC 4. **Supply Chain Optimization Model**: Optimizes delivery performance and logistics
# MAGIC 
# MAGIC All models are now available in the MLflow Model Registry for inference and deployment to production environments.
