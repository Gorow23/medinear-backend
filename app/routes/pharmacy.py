from fastapi import APIRouter
from app.database import pharmacy_collection

router = APIRouter()

@router.get("/pharmacy/search")
def search_pharmacy(name: str):

    pharmacies = list(

        pharmacy_collection.find({

            "medicines": {
                "$regex": name,
                "$options": "i"
            }

        })

    )

    for p in pharmacies:

        p["_id"] = str(p["_id"])

    return pharmacies