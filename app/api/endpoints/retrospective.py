"""
Retrospective Endpoints
"""
from fastapi import APIRouter, HTTPException
from typing import Optional
from datetime import datetime, timedelta
from app.schemas.retrospective import RetrospectiveRequest, RetrospectiveResponse
from app.services.retrospective_service import RetrospectiveService

router = APIRouter()
retrospective_service = RetrospectiveService()


@router.post("/generate", response_model=RetrospectiveResponse)
async def generate_retrospective(request: RetrospectiveRequest):
    """
    주간 회고 및 요약 생성
    
    - **start_date**: 시작 날짜 (YYYY-MM-DD)
    - **end_date**: 종료 날짜 (YYYY-MM-DD)
    - **scope**: 프로젝트 범위 (선택사항)
    """
    try:
        result = await retrospective_service.generate_retrospective(
            start_date=request.start_date,
            end_date=request.end_date,
            scope=request.scope
        )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/generate/weekly")
async def generate_weekly_retrospective():
    """
    최근 7일간의 주간 회고 자동 생성
    """
    end_date = datetime.now()
    start_date = end_date - timedelta(days=7)
    
    try:
        result = await retrospective_service.generate_retrospective(
            start_date=start_date.date(),
            end_date=end_date.date()
        )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
