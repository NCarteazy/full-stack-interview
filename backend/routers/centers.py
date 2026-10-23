from fastapi import APIRouter, HTTPException
from models import Center, Pet
from database import centers_collection, pets_collection
from typing import List

router = APIRouter(tags=["centers"])  # Remove prefix="/centers"


@router.get("/centers", response_model=List[Center])  # Add /centers/ to route
def get_centers():
    centers = list(centers_collection.find())

    # Convert _id to id
    for center in centers:
        center["id"] = center["_id"]

    return centers


@router.get("/centers/{center_id}", response_model=Center)  # Add /centers/ to route
def get_center(center_id: int):
    center = centers_collection.find_one({"_id": center_id})
    if not center:
        raise HTTPException(status_code=404, detail="Center not found")

    center["id"] = center["_id"]
    return center


@router.get(
    "/centers/{center_id}/pets", response_model=List[Pet]
)  # Add /centers/ to route
def get_center_pets(center_id: int):
    # Verify center exists
    center = centers_collection.find_one({"_id": center_id})
    if not center:
        raise HTTPException(status_code=404, detail="Center not found")

    pets = list(pets_collection.find({"center_id": center_id, "status": "available"}))

    # Convert _id to id
    for pet in pets:
        pet["id"] = pet["_id"]

    return pets


@router.get("/{center_id}/stats")
def get_center_stats(center_id: int):
    """Get adoption statistics for a center"""
    center = centers_collection.find_one({"_id": center_id})
    if not center:
        raise HTTPException(status_code=404, detail="Center not found")

    total_pets = pets_collection.count_documents({"center_id": center_id})
    available_pets = pets_collection.count_documents(
        {"center_id": center_id, "status": "available"}
    )
    adopted_pets = pets_collection.count_documents(
        {"center_id": center_id, "status": "adopted"}
    )

    return {
        "center_id": center_id,
        "center_name": center["name"],
        "total_pets": total_pets,
        "available_pets": available_pets,
        "adopted_pets": adopted_pets,
        "capacity": center.get("capacity", 0),
        "occupancy_rate": (available_pets / center.get("capacity", 1)) * 100
        if center.get("capacity")
        else 0,
    }
