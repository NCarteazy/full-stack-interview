from pydantic import BaseModel, Field
from typing import Optional


class Item(BaseModel):
    """Generic item model - will be replaced during interview"""
    id: Optional[int] = Field(None, alias="_id")
    name: str
    description: Optional[str] = None
    
    class Config:
        populate_by_name = True


class Category(BaseModel):
    """Generic category model - will be replaced during interview"""
    id: Optional[int] = Field(None, alias="_id")
    name: str
    
    class Config:
        populate_by_name = True
