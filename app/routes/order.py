from fastapi import APIRouter
from app.database import db

router = APIRouter()

collection = db["orders"]


@router.post("/orders/create")
def create_order(data: dict):

    collection.insert_one(data)

    return {
        "message": "Order placed successfully"
    }


@router.get("/orders")
def get_orders():

    orders = list(
        collection.find({}, {"_id": 0})
    )

    return orders