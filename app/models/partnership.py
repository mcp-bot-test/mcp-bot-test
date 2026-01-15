"""
Partnership Model
"""
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base


class Partnership(Base):
    """Partnership model for 1:1 user matching"""
    __tablename__ = "partnerships"

    id = Column(Integer, primary_key=True, index=True)
    user1_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    user2_id = Column(Integer, ForeignKey("users.id"), nullable=True)  # Null until partner accepts
    invitation_code = Column(String(50), unique=True, index=True, nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    user1 = relationship("User", foreign_keys=[user1_id], back_populates="partnerships_as_user1")
    user2 = relationship("User", foreign_keys=[user2_id], back_populates="partnerships_as_user2")

    # Ensure unique partnership
    __table_args__ = (
        UniqueConstraint('user1_id', 'user2_id', name='unique_partnership'),
    )
