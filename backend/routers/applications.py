from fastapi import APIRouter, HTTPException
from models import ApplicationCreate
from database import applications_collection, pets_collection
from datetime import datetime

router = APIRouter(tags=["applications"])


@router.post("/applications", response_model=dict)
def create_application(application: ApplicationCreate):
    # Check if pet exists and is available
    pet = pets_collection.find_one({"_id": application.pet_id})

    if not pet:
        raise HTTPException(status_code=404, detail="Pet not found")

    if pet["status"] != "available":
        raise HTTPException(status_code=400, detail="Pet is not available for adoption")

    # Get next application ID
    last_app = applications_collection.find_one(sort=[("_id", -1)])
    next_id = (last_app["_id"] + 1) if last_app else 1

    # Create application document
    app_doc = {
        "_id": next_id,
        "applicant_name": application.applicant_name,
        "applicant_email": application.applicant_email,
        "pet_id": application.pet_id,
        "status": "pending",
        "submitted_date": datetime.now().isoformat(),
        "notes": application.notes or "",
    }

    # Insert application
    applications_collection.insert_one(app_doc)

    # Update pet status to pending
    pets_collection.update_one(
        {"_id": application.pet_id}, {"$set": {"status": "pending"}}
    )

    return {
        "id": next_id,
        "message": "Application submitted successfully",
        "pet_name": pet["name"],
    }
