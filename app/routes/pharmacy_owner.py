from fastapi import APIRouter

from app.database import db

router = APIRouter()

owner_collection = db["pharmacy_owners"]

medicine_collection = db["medicine"]


# OWNER REGISTER
@router.post("/owner/register")
def register(data: dict):

    existing = owner_collection.find_one({

        "email": data["email"]
    })

    if existing:

        return {
            "message": "Owner already exists"
        }

    owner_collection.insert_one({

        "name": data["name"],

        "email": data["email"],

        "password": data["password"],

        "pharmacy": data["pharmacy"],

        "location": data["location"],

        "lat": data["lat"],

        "lng": data["lng"],
    })

    return {
        "message": "Owner registered successfully"
    }


# OWNER LOGIN
@router.post("/owner/login")
def login(data: dict):

    owner = owner_collection.find_one({

        "email": data["email"],

        "password": data["password"]
    })

    if not owner:

        return {
            "message": "Invalid credentials"
        }

    owner["_id"] = str(owner["_id"])

    return {

        "message": "Login successful",

        "owner": owner
    }


# ADD MEDICINE
@router.post("/owner/add-medicine")
def add_medicine(data: dict):

    medicine_collection.insert_one({

        "name": data["name"],

        "price": data["price"],

        "pharmacy": data["pharmacy"],

        "location": data["location"],

        "image": data["image"],
    })

    return {
        "message": "Medicine added"
    }