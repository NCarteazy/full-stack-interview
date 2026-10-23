import mongomock
from typing import Dict, List, Any
from datetime import datetime

# In-memory MongoDB using mongomock
client = mongomock.MongoClient()
db = client.pet_adoption

# Collections
centers_collection = db.centers
pets_collection = db.pets
applications_collection = db.applications


def get_db():
    return db


def init_db():
    """Initialize database with sample data"""
    # Clear existing data
    centers_collection.delete_many({})
    pets_collection.delete_many({})
    applications_collection.delete_many({})

    # Insert sample centers
    centers_data = [
        {
            "_id": 1,
            "name": "Sunny Paws Rescue",
            "location": "123 Main St, Downtown",
            "phone": "555-0101",
            "capacity": 50,
        },
        {
            "_id": 2,
            "name": "Mountain View Shelter",
            "location": "456 Oak Ave, Suburbs",
            "phone": "555-0102",
            "capacity": 75,
        },
        {
            "_id": 3,
            "name": "Coastal Pet Haven",
            "location": "789 Beach Blvd, Seaside",
            "phone": "555-0103",
            "capacity": 30,
        },
    ]
    centers_collection.insert_many(centers_data)

    # Insert sample pets
    pets_data = [
        {
            "_id": 1,
            "name": "Luna",
            "species": "cat",
            "breed": "Persian",
            "age_months": 8,
            "size": "small",
            "temperament": "calm",
            "description": "Beautiful Persian cat with long fluffy fur",
            "photo_url": "https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400",
            "center_id": 1,
            "status": "available",
            "arrival_date": "2024-01-15",
        },
        {
            "_id": 2,
            "name": "Max",
            "species": "dog",
            "breed": "Golden Retriever",
            "age_months": 24,
            "size": "large",
            "temperament": "energetic",
            "description": "Friendly family dog, great with kids",
            "photo_url": "https://images.unsplash.com/photo-1552053831-71594a27632d?w=400",
            "center_id": 2,
            "status": "available",
            "arrival_date": "2024-02-01",
        },
        {
            "_id": 3,
            "name": "Whiskers",
            "species": "cat",
            "breed": "Tabby",
            "age_months": 60,
            "size": "medium",
            "temperament": "independent",
            "description": "Independent senior cat, perfect for quiet homes",
            "photo_url": "https://images.unsplash.com/photo-1573865526739-10659fec78a5?w=400",
            "center_id": 3,
            "status": "available",
            "arrival_date": "2024-01-20",
        },
        {
            "_id": 4,
            "name": "Buddy",
            "species": "dog",
            "breed": "Labrador Mix",
            "age_months": 18,
            "size": "large",
            "temperament": "playful",
            "description": "Energetic young dog who loves fetch",
            "photo_url": "https://images.unsplash.com/photo-1537151625747-768eb6cf92b2?w=400",
            "center_id": 1,
            "status": "available",
            "arrival_date": "2024-02-10",
        },
    ]
    pets_collection.insert_many(pets_data)

    print("In-memory MongoDB initialized with sample data!")
