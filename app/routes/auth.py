from fastapi import APIRouter
from app.database import stores
from app.utils.auth import create_token
from uuid import uuid4

router = APIRouter()

@router.post("/store/register")
def register_store(data: dict):
    data["store_id"] = str(uuid4())
    stores.insert_one(data)
    return {"msg": "Store created"}

@router.post("/store/login")
def login_store(data: dict):
    store = stores.find_one({"email": data["email"]})
    if not store:
        return {"error": "Store not found"}
    
    token = create_token({"store_id": store["store_id"]})
    return {"token": token}