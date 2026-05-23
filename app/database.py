from pymongo import MongoClient

client = MongoClient("mongodb://localhost:27017")

db = client["med"]

medicine_collection = db["medicine"]

pharmacy_collection = db["pharmacy"]