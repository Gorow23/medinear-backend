from fastapi import APIRouter
from app.database import orders

router = APIRouter()

@router.post("/")
def place_order(data: dict):
    orders.insert_one(data)
    return {"msg": "Order placed"}

@router.get("/store/{store_id}")
def get_orders(store_id: str):
    result = list(orders.find({"store_id": store_id}, {"_id": 0}))
    return result