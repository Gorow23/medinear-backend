from fastapi import APIRouter, Header
from app.database import medicines

router = APIRouter()

# ✅ Add Medicine
@router.post("/")
def add_medicine(data: dict, store_id: str = Header(...)):
    data["store_id"] = store_id
    medicines.insert_one(data)
    return {"msg": "Medicine added"}

# ✅ Search Medicine (THIS WAS MISSING)
@router.get("/search")
def search_medicine(name: str):
    result = list(medicines.find(
        {"name": {"$regex": name, "$options": "i"}},
        {"_id": 0}
    ))
    return result