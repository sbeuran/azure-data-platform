#!/usr/bin/env python3
"""
Demo API Server for Bosch Supply Chain Data Platform
This server provides mock data for testing the data platform
"""

from flask import Flask, jsonify, request
from datetime import datetime, timedelta
import random
import json
import uuid

app = Flask(__name__)

# Demo data generators
def generate_shipment_data():
    """Generate demo shipment data"""
    carriers = ["DHL", "FedEx", "UPS", "TNT", "DPD"]
    statuses = ["In Transit", "Delivered", "Delayed", "Out for Delivery", "Processing"]
    routes = ["EU-001", "EU-002", "US-001", "AS-001", "AF-001"]
    
    return {
        "shipment_id": str(uuid.uuid4()),
        "order_id": f"ORD-{random.randint(10000, 99999)}",
        "carrier_id": random.choice(carriers),
        "route_id": random.choice(routes),
        "shipment_date": (datetime.now() - timedelta(days=random.randint(0, 30))).isoformat(),
        "estimated_delivery_date": (datetime.now() + timedelta(days=random.randint(1, 14))).isoformat(),
        "actual_delivery_date": (datetime.now() + timedelta(days=random.randint(-5, 10))).isoformat() if random.random() > 0.3 else None,
        "shipment_status": random.choice(statuses),
        "tracking_number": f"TRK{random.randint(100000000, 999999999)}",
        "weight": round(random.uniform(0.5, 100.0), 2),
        "dimensions": {
            "length": round(random.uniform(10, 200), 2),
            "width": round(random.uniform(10, 100), 2),
            "height": round(random.uniform(5, 50), 2)
        }
    }

def generate_carrier_data():
    """Generate demo carrier data"""
    carriers = [
        {"name": "DHL", "type": "Express", "reliability_score": 0.95},
        {"name": "FedEx", "type": "Express", "reliability_score": 0.92},
        {"name": "UPS", "type": "Standard", "reliability_score": 0.88},
        {"name": "TNT", "type": "Economy", "reliability_score": 0.85},
        {"name": "DPD", "type": "Standard", "reliability_score": 0.90}
    ]
    
    carrier = random.choice(carriers)
    return {
        "carrier_id": carrier["name"],
        "carrier_name": carrier["name"],
        "carrier_type": carrier["type"],
        "contact_info": {
            "phone": f"+49-{random.randint(100, 999)}-{random.randint(1000000, 9999999)}",
            "email": f"contact@{carrier['name'].lower()}.com"
        },
        "service_level": carrier["type"],
        "reliability_score": carrier["reliability_score"]
    }

def generate_route_data():
    """Generate demo route data"""
    origins = ["Munich", "Berlin", "Hamburg", "Frankfurt", "Cologne"]
    destinations = ["Paris", "London", "Madrid", "Rome", "Amsterdam", "Brussels", "Vienna", "Prague"]
    
    origin = random.choice(origins)
    destination = random.choice(destinations)
    
    return {
        "route_id": f"RT-{random.randint(1000, 9999)}",
        "origin_location": origin,
        "destination_location": destination,
        "distance_km": random.randint(200, 2000),
        "estimated_duration_hours": random.randint(4, 48),
        "route_type": random.choice(["Highway", "Rail", "Air", "Sea"]),
        "cost_per_km": round(random.uniform(0.5, 2.0), 2)
    }

def generate_iot_sensor_data():
    """Generate demo IoT sensor data"""
    sensor_types = ["Temperature", "Humidity", "Pressure", "Vibration", "GPS"]
    locations = ["Warehouse-A", "Warehouse-B", "Factory-1", "Factory-2", "Transport-001"]
    
    return {
        "sensor_id": f"SENSOR-{random.randint(1000, 9999)}",
        "location_id": random.choice(locations),
        "sensor_type": random.choice(sensor_types),
        "reading_value": round(random.uniform(0, 100), 2),
        "reading_timestamp": datetime.now().isoformat(),
        "battery_level": round(random.uniform(20, 100), 1),
        "signal_strength": round(random.uniform(50, 100), 1)
    }

def generate_weather_data():
    """Generate demo weather data"""
    conditions = ["Sunny", "Cloudy", "Rainy", "Snowy", "Foggy"]
    return {
        "location": random.choice(["Munich", "Berlin", "Hamburg", "Frankfurt", "Cologne"]),
        "temperature": round(random.uniform(-10, 35), 1),
        "humidity": round(random.uniform(30, 90), 1),
        "pressure": round(random.uniform(980, 1030), 1),
        "condition": random.choice(conditions),
        "wind_speed": round(random.uniform(0, 30), 1),
        "timestamp": datetime.now().isoformat()
    }

# API Routes
@app.route('/')
def home():
    """API home endpoint"""
    return jsonify({
        "message": "Bosch Supply Chain Demo API",
        "version": "1.0.0",
        "endpoints": {
            "shipments": "/shipments",
            "carriers": "/carriers", 
            "routes": "/routes",
            "sensors": "/sensors",
            "weather": "/weather"
        }
    })

@app.route('/shipments', methods=['GET'])
def get_shipments():
    """Get shipments data"""
    count = request.args.get('count', 10, type=int)
    shipments = [generate_shipment_data() for _ in range(count)]
    return jsonify({
        "data": shipments,
        "count": len(shipments),
        "timestamp": datetime.now().isoformat()
    })

@app.route('/carriers', methods=['GET'])
def get_carriers():
    """Get carriers data"""
    carriers = [generate_carrier_data() for _ in range(5)]
    return jsonify({
        "data": carriers,
        "count": len(carriers),
        "timestamp": datetime.now().isoformat()
    })

@app.route('/routes', methods=['GET'])
def get_routes():
    """Get routes data"""
    count = request.args.get('count', 10, type=int)
    routes = [generate_route_data() for _ in range(count)]
    return jsonify({
        "data": routes,
        "count": len(routes),
        "timestamp": datetime.now().isoformat()
    })

@app.route('/sensors', methods=['GET'])
def get_sensors():
    """Get IoT sensor data"""
    sensor_type = request.args.get('type', 'all')
    count = request.args.get('count', 20, type=int)
    
    sensors = []
    for _ in range(count):
        sensor_data = generate_iot_sensor_data()
        if sensor_type != 'all' and sensor_data['sensor_type'] != sensor_type:
            continue
        sensors.append(sensor_data)
    
    return jsonify({
        "data": sensors,
        "count": len(sensors),
        "timestamp": datetime.now().isoformat()
    })

@app.route('/weather', methods=['GET'])
def get_weather():
    """Get weather data"""
    location = request.args.get('location', 'Munich')
    weather_data = generate_weather_data()
    weather_data['location'] = location
    
    return jsonify({
        "data": weather_data,
        "timestamp": datetime.now().isoformat()
    })

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "uptime": "running"
    })

if __name__ == '__main__':
    print("Starting Bosch Supply Chain Demo API Server...")
    print("Available endpoints:")
    print("- GET /shipments - Get shipment data")
    print("- GET /carriers - Get carrier data")
    print("- GET /routes - Get route data")
    print("- GET /sensors - Get IoT sensor data")
    print("- GET /weather - Get weather data")
    print("- GET /health - Health check")
    print()
    print("Server starting on http://localhost:5000")
    app.run(host='0.0.0.0', port=5000, debug=True)
