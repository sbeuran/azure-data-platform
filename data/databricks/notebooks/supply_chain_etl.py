# Databricks notebook source
# MAGIC %md
# MAGIC # Supply Chain ETL Pipeline
# MAGIC 
# MAGIC This notebook implements the ETL pipeline for Bosch's supply chain data platform.
# MAGIC It processes data from multiple sources including SAP S/4HANA, logistics partners, and IoT devices.

# COMMAND ----------

# MAGIC %md
# MAGIC ## Configuration and Imports

# COMMAND ----------

from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.types import *
import json
from datetime import datetime, timedelta
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# COMMAND ----------

# MAGIC %md
# MAGIC ## Initialize Spark Session and Configuration

# COMMAND ----------

# Get Spark session
spark = SparkSession.builder.appName("SupplyChainETL").getOrCreate()

# Set Spark configurations for performance
spark.conf.set("spark.sql.adaptive.enabled", "true")
spark.conf.set("spark.sql.adaptive.coalescePartitions.enabled", "true")
spark.conf.set("spark.sql.adaptive.skewJoin.enabled", "true")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Data Lake Configuration

# COMMAND ----------

# Data lake paths
BRONZE_PATH = "/mnt/data-lake/bronze"
SILVER_PATH = "/mnt/data-lake/silver"
GOLD_PATH = "/mnt/data-lake/gold"

# Source paths
SAP_S4HANA_PATH = f"{BRONZE_PATH}/sap/s4hana"
SAP_R3_PATH = f"{BRONZE_PATH}/sap/r3"
LOGISTICS_PATH = f"{BRONZE_PATH}/logistics"
IOT_PATH = f"{BRONZE_PATH}/iot"

# COMMAND ----------

# MAGIC %md
# MAGIC ## SAP S/4HANA Data Processing

# COMMAND ----------

def process_sap_s4hana_data():
    """Process SAP S/4HANA data including materials, sales orders, and production planning"""
    
    logger.info("Processing SAP S/4HANA data...")
    
    # Materials data
    materials_df = spark.read.format("delta").load(f"{SAP_S4HANA_PATH}/materials")
    
    # Sales orders data
    sales_orders_df = spark.read.format("delta").load(f"{SAP_S4HANA_PATH}/sales_orders")
    
    # Production planning data
    production_planning_df = spark.read.format("delta").load(f"{SAP_S4HANA_PATH}/production_planning")
    
    # Data quality checks
    materials_df = materials_df.filter(col("material_number").isNotNull())
    sales_orders_df = sales_orders_df.filter(col("order_number").isNotNull())
    production_planning_df = production_planning_df.filter(col("planning_date").isNotNull())
    
    # Transform and standardize data
    materials_processed = materials_df.select(
        col("material_number").alias("material_id"),
        col("material_description").alias("material_name"),
        col("material_type"),
        col("base_unit"),
        col("created_date"),
        col("last_modified_date"),
        current_timestamp().alias("processed_timestamp")
    )
    
    sales_orders_processed = sales_orders_df.select(
        col("order_number").alias("order_id"),
        col("customer_number").alias("customer_id"),
        col("material_number").alias("material_id"),
        col("order_quantity"),
        col("order_date"),
        col("delivery_date"),
        col("order_status"),
        current_timestamp().alias("processed_timestamp")
    )
    
    production_planning_processed = production_planning_df.select(
        col("planning_date"),
        col("material_number").alias("material_id"),
        col("planned_quantity"),
        col("plant"),
        col("work_center"),
        current_timestamp().alias("processed_timestamp")
    )
    
    # Write to silver layer
    materials_processed.write \
        .format("delta") \
        .mode("overwrite") \
        .option("mergeSchema", "true") \
        .save(f"{SILVER_PATH}/sap/s4hana/materials")
    
    sales_orders_processed.write \
        .format("delta") \
        .mode("overwrite") \
        .option("mergeSchema", "true") \
        .save(f"{SILVER_PATH}/sap/s4hana/sales_orders")
    
    production_planning_processed.write \
        .format("delta") \
        .mode("overwrite") \
        .option("mergeSchema", "true") \
        .save(f"{SILVER_PATH}/sap/s4hana/production_planning")
    
    logger.info("SAP S/4HANA data processing completed")

# COMMAND ----------

# MAGIC %md
# MAGIC ## SAP R/3 Data Processing

# COMMAND ----------

def process_sap_r3_data():
    """Process SAP R/3 legacy data for migration support"""
    
    logger.info("Processing SAP R/3 data...")
    
    # Legacy materials data
    legacy_materials_df = spark.read.format("delta").load(f"{SAP_R3_PATH}/materials")
    
    # Legacy sales data
    legacy_sales_df = spark.read.format("delta").load(f"{SAP_R3_PATH}/sales")
    
    # Data quality and transformation
    legacy_materials_processed = legacy_materials_df.select(
        col("material_number").alias("material_id"),
        col("material_description").alias("material_name"),
        col("material_type"),
        col("base_unit"),
        col("created_date"),
        col("last_modified_date"),
        lit("R3").alias("source_system"),
        current_timestamp().alias("processed_timestamp")
    )
    
    legacy_sales_processed = legacy_sales_df.select(
        col("order_number").alias("order_id"),
        col("customer_number").alias("customer_id"),
        col("material_number").alias("material_id"),
        col("order_quantity"),
        col("order_date"),
        col("delivery_date"),
        col("order_status"),
        lit("R3").alias("source_system"),
        current_timestamp().alias("processed_timestamp")
    )
    
    # Write to silver layer
    legacy_materials_processed.write \
        .format("delta") \
        .mode("overwrite") \
        .option("mergeSchema", "true") \
        .save(f"{SILVER_PATH}/sap/r3/materials")
    
    legacy_sales_processed.write \
        .format("delta") \
        .mode("overwrite") \
        .option("mergeSchema", "true") \
        .save(f"{SILVER_PATH}/sap/r3/sales")
    
    logger.info("SAP R/3 data processing completed")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Logistics Data Processing

# COMMAND ----------

def process_logistics_data():
    """Process logistics and shipping data from external partners"""
    
    logger.info("Processing logistics data...")
    
    # Shipping data
    shipping_df = spark.read.format("delta").load(f"{LOGISTICS_PATH}/shipping")
    
    # Carrier data
    carrier_df = spark.read.format("delta").load(f"{LOGISTICS_PATH}/carriers")
    
    # Route data
    route_df = spark.read.format("delta").load(f"{LOGISTICS_PATH}/routes")
    
    # Data quality checks
    shipping_df = shipping_df.filter(col("shipment_id").isNotNull())
    carrier_df = carrier_df.filter(col("carrier_id").isNotNull())
    route_df = route_df.filter(col("route_id").isNotNull())
    
    # Transform shipping data
    shipping_processed = shipping_df.select(
        col("shipment_id"),
        col("order_id"),
        col("carrier_id"),
        col("route_id"),
        col("shipment_date"),
        col("estimated_delivery_date"),
        col("actual_delivery_date"),
        col("shipment_status"),
        col("tracking_number"),
        col("weight"),
        col("dimensions"),
        current_timestamp().alias("processed_timestamp")
    )
    
    # Transform carrier data
    carrier_processed = carrier_df.select(
        col("carrier_id"),
        col("carrier_name"),
        col("carrier_type"),
        col("contact_info"),
        col("service_level"),
        col("reliability_score"),
        current_timestamp().alias("processed_timestamp")
    )
    
    # Transform route data
    route_processed = route_df.select(
        col("route_id"),
        col("origin_location"),
        col("destination_location"),
        col("distance_km"),
        col("estimated_duration_hours"),
        col("route_type"),
        col("cost_per_km"),
        current_timestamp().alias("processed_timestamp")
    )
    
    # Write to silver layer
    shipping_processed.write \
        .format("delta") \
        .mode("overwrite") \
        .option("mergeSchema", "true") \
        .save(f"{SILVER_PATH}/logistics/shipping")
    
    carrier_processed.write \
        .format("delta") \
        .mode("overwrite") \
        .option("mergeSchema", "true") \
        .save(f"{SILVER_PATH}/logistics/carriers")
    
    route_processed.write \
        .format("delta") \
        .mode("overwrite") \
        .option("mergeSchema", "true") \
        .save(f"{SILVER_PATH}/logistics/routes")
    
    logger.info("Logistics data processing completed")

# COMMAND ----------

# MAGIC %md
# MAGIC ## IoT Data Processing

# COMMAND ----------

def process_iot_data():
    """Process IoT sensor data from warehouses, factories, and transportation"""
    
    logger.info("Processing IoT data...")
    
    # Warehouse sensor data
    warehouse_sensors_df = spark.read.format("delta").load(f"{IOT_PATH}/warehouse_sensors")
    
    # Factory sensor data
    factory_sensors_df = spark.read.format("delta").load(f"{IOT_PATH}/factory_sensors")
    
    # Transportation sensor data
    transport_sensors_df = spark.read.format("delta").load(f"{IOT_PATH}/transport_sensors")
    
    # Data quality checks
    warehouse_sensors_df = warehouse_sensors_df.filter(col("sensor_id").isNotNull())
    factory_sensors_df = factory_sensors_df.filter(col("sensor_id").isNotNull())
    transport_sensors_df = transport_sensors_df.filter(col("sensor_id").isNotNull())
    
    # Transform warehouse sensor data
    warehouse_processed = warehouse_sensors_df.select(
        col("sensor_id"),
        col("location_id"),
        col("sensor_type"),
        col("temperature"),
        col("humidity"),
        col("pressure"),
        col("timestamp"),
        col("battery_level"),
        col("signal_strength"),
        current_timestamp().alias("processed_timestamp")
    )
    
    # Transform factory sensor data
    factory_processed = factory_sensors_df.select(
        col("sensor_id"),
        col("machine_id"),
        col("sensor_type"),
        col("vibration"),
        col("temperature"),
        col("pressure"),
        col("timestamp"),
        col("machine_status"),
        current_timestamp().alias("processed_timestamp")
    )
    
    # Transform transportation sensor data
    transport_processed = transport_sensors_df.select(
        col("sensor_id"),
        col("vehicle_id"),
        col("sensor_type"),
        col("gps_latitude"),
        col("gps_longitude"),
        col("speed"),
        col("temperature"),
        col("timestamp"),
        col("fuel_level"),
        current_timestamp().alias("processed_timestamp")
    )
    
    # Write to silver layer
    warehouse_processed.write \
        .format("delta") \
        .mode("overwrite") \
        .option("mergeSchema", "true") \
        .save(f"{SILVER_PATH}/iot/warehouse_sensors")
    
    factory_processed.write \
        .format("delta") \
        .mode("overwrite") \
        .option("mergeSchema", "true") \
        .save(f"{SILVER_PATH}/iot/factory_sensors")
    
    transport_processed.write \
        .format("delta") \
        .mode("overwrite") \
        .option("mergeSchema", "true") \
        .save(f"{SILVER_PATH}/iot/transport_sensors")
    
    logger.info("IoT data processing completed")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Gold Layer Data Aggregation

# COMMAND ----------

def create_gold_layer_aggregations():
    """Create aggregated views and metrics for business intelligence"""
    
    logger.info("Creating gold layer aggregations...")
    
    # Read silver layer data
    materials_df = spark.read.format("delta").load(f"{SILVER_PATH}/sap/s4hana/materials")
    sales_orders_df = spark.read.format("delta").load(f"{SILVER_PATH}/sap/s4hana/sales_orders")
    shipping_df = spark.read.format("delta").load(f"{SILVER_PATH}/logistics/shipping")
    carriers_df = spark.read.format("delta").load(f"{SILVER_PATH}/logistics/carriers")
    
    # Create supply chain performance metrics
    supply_chain_metrics = sales_orders_df.join(
        shipping_df, 
        sales_orders_df.order_id == shipping_df.order_id, 
        "left"
    ).join(
        carriers_df,
        shipping_df.carrier_id == carriers_df.carrier_id,
        "left"
    ).select(
        col("order_id"),
        col("material_id"),
        col("order_date"),
        col("delivery_date"),
        col("actual_delivery_date"),
        col("shipment_status"),
        col("carrier_name"),
        col("reliability_score"),
        datediff(col("actual_delivery_date"), col("delivery_date")).alias("delivery_delay_days"),
        when(col("shipment_status") == "Delivered", 1).otherwise(0).alias("delivery_success")
    )
    
    # Create material performance summary
    material_performance = supply_chain_metrics.groupBy("material_id").agg(
        count("*").alias("total_orders"),
        sum("delivery_success").alias("successful_deliveries"),
        avg("delivery_delay_days").alias("avg_delay_days"),
        max("delivery_delay_days").alias("max_delay_days"),
        min("delivery_delay_days").alias("min_delay_days")
    ).withColumn(
        "success_rate", 
        col("successful_deliveries") / col("total_orders")
    )
    
    # Create carrier performance summary
    carrier_performance = supply_chain_metrics.groupBy("carrier_name").agg(
        count("*").alias("total_shipments"),
        sum("delivery_success").alias("successful_deliveries"),
        avg("delivery_delay_days").alias("avg_delay_days"),
        avg("reliability_score").alias("avg_reliability_score")
    ).withColumn(
        "success_rate",
        col("successful_deliveries") / col("total_shipments")
    )
    
    # Write gold layer data
    supply_chain_metrics.write \
        .format("delta") \
        .mode("overwrite") \
        .option("mergeSchema", "true") \
        .save(f"{GOLD_PATH}/supply_chain_metrics")
    
    material_performance.write \
        .format("delta") \
        .mode("overwrite") \
        .option("mergeSchema", "true") \
        .save(f"{GOLD_PATH}/material_performance")
    
    carrier_performance.write \
        .format("delta") \
        .mode("overwrite") \
        .option("mergeSchema", "true") \
        .save(f"{GOLD_PATH}/carrier_performance")
    
    logger.info("Gold layer aggregations completed")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Main ETL Pipeline Execution

# COMMAND ----------

def main():
    """Main ETL pipeline execution"""
    
    logger.info("Starting Supply Chain ETL Pipeline...")
    
    try:
        # Process data from all sources
        process_sap_s4hana_data()
        process_sap_r3_data()
        process_logistics_data()
        process_iot_data()
        
        # Create gold layer aggregations
        create_gold_layer_aggregations()
        
        logger.info("Supply Chain ETL Pipeline completed successfully")
        
    except Exception as e:
        logger.error(f"ETL Pipeline failed: {str(e)}")
        raise e

# COMMAND ----------

# Execute the main pipeline
if __name__ == "__main__":
    main()

# COMMAND ----------

# MAGIC %md
# MAGIC ## Pipeline Completion
# MAGIC 
# MAGIC The Supply Chain ETL Pipeline has been executed successfully. All data has been processed and stored in the appropriate layers:
# MAGIC - **Bronze Layer**: Raw data from all sources
# MAGIC - **Silver Layer**: Cleaned and standardized data
# MAGIC - **Gold Layer**: Aggregated business metrics and KPIs
# MAGIC 
# MAGIC The pipeline is now ready for analytics and machine learning applications.
