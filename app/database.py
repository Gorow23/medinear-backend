from pymongo import MongoClient
import os

MONGO_URI = os.getenv("MONGO_URI")

client = MongoClient(MONGO_URI)

db = client["pharmacy"]

stores = db["stores"]
medicines = db["medicines"]
orders = db["orders"]