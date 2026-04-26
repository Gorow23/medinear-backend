from fastapi import FastAPI, Request
from app.routes import auth, medicine, order

app = FastAPI()

# Middleware for multi-tenant
@app.middleware("http")
async def tenant_middleware(request: Request, call_next):
    request.state.store_id = request.headers.get("store-id")
    response = await call_next(request)
    return response

# Routes
app.include_router(auth.router, prefix="/auth")
app.include_router(medicine.router, prefix="/medicines")
app.include_router(order.router, prefix="/orders")