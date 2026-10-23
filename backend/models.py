from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


class Pet(BaseModel):
    id: Optional[int] = Field(None, alias="_id")
    name: str
    species: str
    breed: Optional[str] = None
    age_months: Optional[int] = None
    size: Optional[str] = None
    temperament: Optional[str] = None
    description: Optional[str] = None
    photo_url: Optional[str] = None
    center_id: int
    status: str = "available"
    arrival_date: Optional[str] = None

    class Config:
        populate_by_name = True


class Center(BaseModel):
    id: Optional[int] = Field(None, alias="_id")
    name: str
    location: str
    phone: Optional[str] = None
    capacity: Optional[int] = None

    class Config:
        populate_by_name = True


class Application(BaseModel):
    id: Optional[int] = Field(None, alias="_id")
    applicant_name: str
    applicant_email: str
    pet_id: int
    status: str = "pending"
    submitted_date: Optional[str] = None
    notes: Optional[str] = None

    class Config:
        populate_by_name = True


class ApplicationCreate(BaseModel):
    applicant_name: str
    applicant_email: str
    pet_id: int
    notes: Optional[str] = None
