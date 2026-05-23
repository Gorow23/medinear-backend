from fastapi import FastAPI

from fastapi.middleware.cors import CORSMiddleware

from app.routes import (
    medicine,
    order,
    auth,
    pharmacy,
    admin,
    pharmacy_owner,
)

app = FastAPI()

# CORS
app.add_middleware(

    CORSMiddleware,

    allow_origins=["*"],

    allow_credentials=True,

    allow_methods=["*"],

    allow_headers=["*"],
)

# ROUTES
app.include_router(medicine.router)

app.include_router(order.router)

app.include_router(auth.router)

app.include_router(pharmacy.router)

app.include_router(admin.router)

app.include_router(pharmacy_owner.router)