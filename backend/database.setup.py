import mongomock

# Using mongomock for interview - no real MongoDB needed
client = mongomock.MongoClient()
db = client["interview_db"]

# Generic collections - will be populated during interview
items_collection = db["items"]
categories_collection = db["categories"]

# Seed with minimal test data
items_collection.insert_many([
    {"_id": 1, "name": "Sample Item 1", "description": "Test item"},
    {"_id": 2, "name": "Sample Item 2", "description": "Another test item"},
])

categories_collection.insert_many([
    {"_id": 1, "name": "Category A"},
    {"_id": 2, "name": "Category B"},
])
