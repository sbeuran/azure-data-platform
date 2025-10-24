#!/usr/bin/env python3
"""
Demo Data Generator for Bosch Supply Chain Data Platform
Generates realistic demo data for testing the data platform
"""

import json
import csv
import random
import uuid
from datetime import datetime, timedelta
import argparse
import os

def generate_materials_data(count=100):
    """Generate demo materials data"""
    materials = []
    material_types = ["Raw Material", "Component", "Finished Product", "Packaging", "Tool"]
    base_units = ["KG", "PCS", "L", "M", "M2"]
    
    for i in range(count):
        material = {
            "material_id": f"MAT-{i+1:06d}",
            "material_name": f"Material {i+1}",
            "material_type": random.choice(material_types),
            "base_unit": random.choice(base_units),
            "created_date": (datetime.now() - timedelta(days=random.randint(30, 365))).strftime("%Y-%m-%d"),
            "last_modified_date": (datetime.now() - timedelta(days=random.randint(1, 30))).strftime("%Y-%m-%d"),
            "source_system": "SAP_S4HANA"
        }
        materials.append(material)
    
    return materials

def generate_sales_orders_data(count=500):
    """Generate demo sales orders data"""
    orders = []
    statuses = ["Open", "In Process", "Shipped", "Delivered", "Cancelled"]
    customers = [f"CUST-{i:04d}" for i in range(1, 51)]
    
    for i in range(count):
        order_date = datetime.now() - timedelta(days=random.randint(1, 90))
        delivery_date = order_date + timedelta(days=random.randint(1, 30))
        
        order = {
            "order_id": f"ORD-{i+1:06d}",
            "customer_id": random.choice(customers),
            "material_id": f"MAT-{random.randint(1, 100):06d}",
            "order_quantity": round(random.uniform(1, 1000), 2),
            "order_date": order_date.strftime("%Y-%m-%d"),
            "delivery_date": delivery_date.strftime("%Y-%m-%d"),
            "order_status": random.choice(statuses),
            "source_system": "SAP_S4HANA"
        }
        orders.append(order)
    
    return orders

def generate_shipments_data(count=300):
    """Generate demo shipments data"""
    shipments = []
    carriers = ["DHL", "FedEx", "UPS", "TNT", "DPD"]
    statuses = ["In Transit", "Delivered", "Delayed", "Out for Delivery", "Processing"]
    routes = ["EU-001", "EU-002", "US-001", "AS-001", "AF-001"]
    
    for i in range(count):
        shipment_date = datetime.now() - timedelta(days=random.randint(1, 60))
        estimated_delivery = shipment_date + timedelta(days=random.randint(1, 14))
        actual_delivery = estimated_delivery + timedelta(days=random.randint(-3, 5)) if random.random() > 0.3 else None
        
        shipment = {
            "shipment_id": str(uuid.uuid4()),
            "order_id": f"ORD-{random.randint(1, 500):06d}",
            "carrier_id": random.choice(carriers),
            "route_id": random.choice(routes),
            "shipment_date": shipment_date.strftime("%Y-%m-%d"),
            "estimated_delivery_date": estimated_delivery.strftime("%Y-%m-%d"),
            "actual_delivery_date": actual_delivery.strftime("%Y-%m-%d") if actual_delivery else None,
            "shipment_status": random.choice(statuses),
            "tracking_number": f"TRK{random.randint(100000000, 999999999)}",
            "weight": round(random.uniform(0.5, 100.0), 2),
            "dimensions": {
                "length": round(random.uniform(10, 200), 2),
                "width": round(random.uniform(10, 100), 2),
                "height": round(random.uniform(5, 50), 2)
            }
        }
        shipments.append(shipment)
    
    return shipments

def generate_carriers_data():
    """Generate demo carriers data"""
    carriers = [
        {
            "carrier_id": "DHL",
            "carrier_name": "DHL Express",
            "carrier_type": "Express",
            "contact_info": {
                "phone": "+49-30-12345678",
                "email": "contact@dhl.com"
            },
            "service_level": "Express",
            "reliability_score": 0.95
        },
        {
            "carrier_id": "FedEx",
            "carrier_name": "FedEx Corporation",
            "carrier_type": "Express",
            "contact_info": {
                "phone": "+49-30-87654321",
                "email": "contact@fedex.com"
            },
            "service_level": "Express",
            "reliability_score": 0.92
        },
        {
            "carrier_id": "UPS",
            "carrier_name": "United Parcel Service",
            "carrier_type": "Standard",
            "contact_info": {
                "phone": "+49-30-11223344",
                "email": "contact@ups.com"
            },
            "service_level": "Standard",
            "reliability_score": 0.88
        },
        {
            "carrier_id": "TNT",
            "carrier_name": "TNT Express",
            "carrier_type": "Economy",
            "contact_info": {
                "phone": "+49-30-55667788",
                "email": "contact@tnt.com"
            },
            "service_level": "Economy",
            "reliability_score": 0.85
        },
        {
            "carrier_id": "DPD",
            "carrier_name": "DPD Group",
            "carrier_type": "Standard",
            "contact_info": {
                "phone": "+49-30-99887766",
                "email": "contact@dpd.com"
            },
            "service_level": "Standard",
            "reliability_score": 0.90
        }
    ]
    
    return carriers

def generate_routes_data(count=50):
    """Generate demo routes data"""
    routes = []
    origins = ["Munich", "Berlin", "Hamburg", "Frankfurt", "Cologne", "Stuttgart", "Düsseldorf"]
    destinations = ["Paris", "London", "Madrid", "Rome", "Amsterdam", "Brussels", "Vienna", "Prague", "Warsaw", "Stockholm"]
    
    for i in range(count):
        origin = random.choice(origins)
        destination = random.choice(destinations)
        
        route = {
            "route_id": f"RT-{i+1:04d}",
            "origin_location": origin,
            "destination_location": destination,
            "distance_km": random.randint(200, 2000),
            "estimated_duration_hours": random.randint(4, 48),
            "route_type": random.choice(["Highway", "Rail", "Air", "Sea"]),
            "cost_per_km": round(random.uniform(0.5, 2.0), 2)
        }
        routes.append(route)
    
    return routes

def generate_iot_sensor_data(count=1000):
    """Generate demo IoT sensor data"""
    sensors = []
    sensor_types = ["Temperature", "Humidity", "Pressure", "Vibration", "GPS"]
    locations = ["Warehouse-A", "Warehouse-B", "Factory-1", "Factory-2", "Transport-001", "Transport-002"]
    
    for i in range(count):
        sensor = {
            "sensor_id": f"SENSOR-{i+1:04d}",
            "location_id": random.choice(locations),
            "sensor_type": random.choice(sensor_types),
            "reading_value": round(random.uniform(0, 100), 2),
            "reading_timestamp": (datetime.now() - timedelta(hours=random.randint(0, 24))).isoformat(),
            "battery_level": round(random.uniform(20, 100), 1),
            "signal_strength": round(random.uniform(50, 100), 1)
        }
        sensors.append(sensor)
    
    return sensors

def generate_weather_data(count=100):
    """Generate demo weather data"""
    weather_data = []
    locations = ["Munich", "Berlin", "Hamburg", "Frankfurt", "Cologne"]
    conditions = ["Sunny", "Cloudy", "Rainy", "Snowy", "Foggy"]
    
    for i in range(count):
        weather = {
            "location": random.choice(locations),
            "temperature": round(random.uniform(-10, 35), 1),
            "humidity": round(random.uniform(30, 90), 1),
            "pressure": round(random.uniform(980, 1030), 1),
            "condition": random.choice(conditions),
            "wind_speed": round(random.uniform(0, 30), 1),
            "timestamp": (datetime.now() - timedelta(hours=random.randint(0, 24))).isoformat()
        }
        weather_data.append(weather)
    
    return weather_data

def save_data_to_files(data, output_dir):
    """Save data to JSON and CSV files"""
    os.makedirs(output_dir, exist_ok=True)
    
    for data_type, data_list in data.items():
        # Save as JSON
        json_file = os.path.join(output_dir, f"{data_type}.json")
        with open(json_file, 'w') as f:
            json.dump(data_list, f, indent=2)
        
        # Save as CSV
        csv_file = os.path.join(output_dir, f"{data_type}.csv")
        if data_list:
            with open(csv_file, 'w', newline='') as f:
                writer = csv.DictWriter(f, fieldnames=data_list[0].keys())
                writer.writeheader()
                writer.writerows(data_list)
        
        print(f"Generated {len(data_list)} {data_type} records")

def main():
    """Main function to generate demo data"""
    parser = argparse.ArgumentParser(description='Generate demo data for Bosch Supply Chain Data Platform')
    parser.add_argument('--output', '-o', default='demo-data', help='Output directory for demo data')
    parser.add_argument('--materials', type=int, default=100, help='Number of materials to generate')
    parser.add_argument('--orders', type=int, default=500, help='Number of sales orders to generate')
    parser.add_argument('--shipments', type=int, default=300, help='Number of shipments to generate')
    parser.add_argument('--routes', type=int, default=50, help='Number of routes to generate')
    parser.add_argument('--sensors', type=int, default=1000, help='Number of IoT sensor readings to generate')
    parser.add_argument('--weather', type=int, default=100, help='Number of weather records to generate')
    
    args = parser.parse_args()
    
    print("Generating demo data for Bosch Supply Chain Data Platform...")
    print(f"Output directory: {args.output}")
    
    # Generate all data
    data = {
        'materials': generate_materials_data(args.materials),
        'sales_orders': generate_sales_orders_data(args.orders),
        'shipments': generate_shipments_data(args.shipments),
        'carriers': generate_carriers_data(),
        'routes': generate_routes_data(args.routes),
        'iot_sensors': generate_iot_sensor_data(args.sensors),
        'weather': generate_weather_data(args.weather)
    }
    
    # Save data to files
    save_data_to_files(data, args.output)
    
    print(f"\nDemo data generation completed!")
    print(f"Data saved to: {args.output}")
    print(f"Total records generated: {sum(len(data_list) for data_list in data.values())}")

if __name__ == "__main__":
    main()
