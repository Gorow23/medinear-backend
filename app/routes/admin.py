from fastapi import APIRouter

from app.database import db

router = APIRouter()

medicine_collection = db["medicine"]


@router.post("/admin/add-medicine")
def add_medicine(data: dict):

    medicine_collection.insert_one({

        "name": data["name"],

        "price": data["price"],

        "pharmacy": data["pharmacy"],

        "location": data["location"],

        "image": data["image"],
    })

    return {
        "message": "Medicine added successfully"
    }


@router.get("/admin/medicines")
def get_medicines():

    medicines = list(
        medicine_collection.find()
    )

    for medicine in medicines:

        medicine["_id"] = str(
            medicine["_id"]
        )

    return medicines