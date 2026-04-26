from pymongo import MongoClient
import os
from dotenv import load_dotenv

# Load .env
load_dotenv()

# Get Mongo URI
MONGO_URI = os.getenv("MONGO_URI")

# Debug print (remove later)
print("Mongo URI:", MONGO_URI)

# Connect to MongoDB
client = MongoClient(MONGO_URI)

# Database
db = client["pharmacy"]

# Collections
stores = db["stores"]
medicines = db["medicines"]
orders = db["orders"]