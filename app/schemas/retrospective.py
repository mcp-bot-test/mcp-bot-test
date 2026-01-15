"""
Retrospective Schemas
"""
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import date


class RetrospectiveRequest(BaseModel):
    """회고 생성 요청 스키마"""
    start_date: date = Field(..., description="시작 날짜")
    end_date: date = Field(..., description="종료 날짜")
    scope: Optional[str] = Field(None, description="프로젝트 범위 (선택사항)")


class WorkItem(BaseModel):
    """작업 항목"""
    title: str
    description: str
    assignee: Optional[str] = None
    source: str  # notion, jira, github, slack
    url: Optional[str] = None


class RetrospectiveResponse(BaseModel):
    """회고 생성 응답 스키마"""
    period: str
    summary: str
    work_items: List[WorkItem]
    insights: List[str]
    generated_at: str
