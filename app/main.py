from fastapi import FastAPI, Request
from app.routes import auth, medicine, order
from fastapi.middleware.cors import CORSMiddleware


app = FastAPI()

# Middleware for multi-tenant
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # allow all (for now)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routes
app.include_router(auth.router, prefix="/auth")
app.include_router(medicine.router, prefix="/medicines")
app.include_router(order.router, prefix="/orders")