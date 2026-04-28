from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routes import auth, medicine, order

app = FastAPI()

# ✅ CORS FIX (VERY IMPORTANT)
origins = [
    "http://localhost:3000",
    "http://127.0.0.1:5500",
    "https://wowmedical.netlify.app"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 👈 for testing (allow all)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routers
app.include_router(auth.router, prefix="/auth")
app.include_router(medicine.router, prefix="/medicines")
app.include_router(order.router, prefix="/orders")