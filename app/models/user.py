"""
User Model
"""
from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base


class User(Base):
    """User model"""
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    username = Column(String(100), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    status_message = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True)
    is_online = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    tasks = relationship("Task", back_populates="owner", cascade="all, delete-orphan")
    partnerships_as_user1 = relationship(
        "Partnership",
        foreign_keys="Partnership.user1_id",
        back_populates="user1",
        cascade="all, delete-orphan"
    )
    partnerships_as_user2 = relationship(
        "Partnership",
        foreign_keys="Partnership.user2_id",
        back_populates="user2",
        cascade="all, delete-orphan"
    )
