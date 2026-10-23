from fastapi import APIRouter, HTTPException
from models import Pet
from database import pets_collection, centers_collection
from typing import List, Optional

router = APIRouter(tags=["pets"])


@router.get("/pets", response_model=List[Pet])
def get_pets(
    species: Optional[str] = None,
    size: Optional[str] = None,
    center_id: Optional[int] = None,
):
    # Build query filter
    query_filter: dict = {"status": "available"}
    if species:
        query_filter["species"] = species
    if size:
        query_filter["size"] = size
    if center_id is not None:
        query_filter["center_id"] = center_id

    pets = list(pets_collection.find(query_filter))

    # Convert MongoDB _id to id for response
    for pet in pets:
        pet["id"] = pet["_id"]

    return pets


@router.get("/pets/{pet_id}", response_model=Pet)
def get_pet(pet_id: int):
    pet = pets_collection.find_one({"_id": pet_id})
    if not pet:
        raise HTTPException(status_code=404, detail="Pet not found")

    pet["id"] = pet["_id"]
    return pet
