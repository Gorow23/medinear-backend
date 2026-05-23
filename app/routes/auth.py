from fastapi import APIRouter
from app.database import db

from passlib.context import CryptContext

from jose import jwt

router = APIRouter()

SECRET_KEY = "medplussecret"

ALGORITHM = "HS256"

pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto"
)

collection = db["users"]


# REGISTER
@router.post("/register")
def register(data: dict):

    existing = collection.find_one({
        "email": data["email"]
    })

    if existing:

        return {
            "message": "User already exists"
        }

    hashed_password = pwd_context.hash(
        data["password"]
    )

    user_data = {

    "name": data.get("name", ""),

    "email": data["email"],

    "password": hashed_password
}
    collection.insert_one(user_data)

    return {
        "message": "Registration successful"
    }


# LOGIN
@router.post("/login")
def login(data: dict):

    user = collection.find_one({
        "email": data["email"]
    })

    if not user:

        return {
            "message": "User not found"
        }

    password_verified = pwd_context.verify(

        data["password"],

        user["password"]
    )

    if not password_verified:

        return {
            "message": "Invalid password"
        }

    token = jwt.encode(

        {
            "email": user["email"]
        },

        SECRET_KEY,

        algorithm=ALGORITHM
    )

    return {

        "message": "Login successful",

        "token": token,

        "name": user["name"]
    }