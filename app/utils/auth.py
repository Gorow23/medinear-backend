from jose import jwt
from datetime import datetime, timedelta
import os

SECRET = os.getenv("SECRET", "secret")

def create_token(data: dict):
    payload = data.copy()
    payload["exp"] = datetime.utcnow() + timedelta(days=1)
    return jwt.encode(payload, SECRET, algorithm="HS256")
