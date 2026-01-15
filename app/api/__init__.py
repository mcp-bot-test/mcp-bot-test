"""
API Routes
"""
from fastapi import APIRouter
from app.api.endpoints import retrospective, health

router = APIRouter()

router.include_router(health.router, prefix="/health", tags=["health"])
router.include_router(retrospective.router, prefix="/retrospective", tags=["retrospective"])
