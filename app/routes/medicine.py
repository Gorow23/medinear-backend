from fastapi import APIRouter

from geopy.distance import geodesic

from app.database import db

router = APIRouter()

medicine_collection = db["medicine"]

owner_collection = db["pharmacy_owners"]


@router.get("/medicines/search")
def search_medicine(

    name: str,

    user_lat: float = 0,

    user_lng: float = 0,
):

    medicines = list(

        medicine_collection.find({

            "name": {

                "$regex": name,

                "$options": "i"
            }
        })
    )

    results = []

    for medicine in medicines:

        owner = owner_collection.find_one({

            "pharmacy":
                medicine["pharmacy"]
        })

        # SAFE CHECK
        if owner and "lat" in owner and "lng" in owner:

            distance = geodesic(

                (user_lat, user_lng),

                (owner["lat"], owner["lng"])

            ).km

            medicine["distance"] = round(
                distance,
                2,
            )

        else:

            medicine["distance"] = 0

        medicine["_id"] = str(
            medicine["_id"]
        )

        results.append(medicine)

    return results