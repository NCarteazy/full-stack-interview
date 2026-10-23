# Pet Adoption Center Interview Challenge

Welcome to the pet adoption center full-stack development challenge! You have **75 minutes** to complete this exercise.

## Project Overview

You've been provided with a basic Pet Adoption API built with FastAPI (Python) and a starter React TypeScript frontend. The system manages multiple adoption centers, their pets, and adoption applications.

## Current Setup

Your starter project includes:

- **Backend**: FastAPI with MongoDB
- **Frontend**: React TypeScript starter template
- **Data**: Pre-seeded with 3 adoption centers and several pets

You may install any additional packages / libraries that will help you in developing this.

### Getting Started

**Test the API**:

```bash
curl http://localhost:3001/pets
curl http://localhost:3001/centers
```

## Your Tasks

*Suggested pacing: aim to wrap up Phase 1 within the first 15 minutes, leaving ~60 minutes for Phase 2.*

### Phase 1: Backend Enhancement

**Implement the following API endpoint in `/backend/routers/pets.py`:**

1. **Pet Search Endpoint**
   - Extend this existing endpoint: `GET /pets` to support a query parameter containing a search term
   - This term should search pets by name OR breed (case-insensitive)
   - Only return available pets
   - Example 1: `/pets?search=golden` should find "Golden Retriever" pets
   - Example 2: `/pets?search=gol` should find pets with a name containing "gol" or the breed "Golden Retriever"

### Phase 2: Frontend Implementation

**Note: You can refer to `/DESIGN.png` for a design reference**

**Requirements:**

- Use TypeScript interfaces for all data
- Handle loading states while fetching data
- Display appropriate error messages
- Make it responsive and visually appealing
- This should look roughly like the `/DESIGN.png` file, exact details aren't important (color, spacing, etc.)

**Build a Pet Browser Interface:**

1. **Pet Listing Page**

   - Display pets in a card/grid layout
   - Show all of the following in a card: pet photo, name, breed, age (convert months to years/months), size, and adoption center
   - Add a search box that uses your search query API
   

2. **Adoption Application Modal**
   - Add an "Apply to Adopt" button on each pet card
   - Create a simple modal/form with fields:
     - Applicant name (required)
     - Email (required)
     - Notes/message (optional)
   - Submit application to `POST /applications` endpoint
   - Show success/error messages

   **Note:** submitting an application sets the pet's status to `pending`, so it will no longer appear in the available-pet list.

## Available Resources

**Existing API Endpoints:**

- `GET /pets` - List available pets with optional filters (species, size, center_id)
- `GET /centers` - List all adoption centers
- `GET /centers/{id}/pets` - Get pets for a specific center
- `POST /applications` - Submit adoption application

**Database Collections:**

- **pets**: id, name, species, breed, age_months, size, temperament, description, photo_url, center_id, status, arrival_date
- **centers**: id, name, location, phone, capacity
- **applications**: id, applicant_name, applicant_email, pet_id, status, submitted_date, notes

## Sample Pet Data

Your database includes pets like:

- Luna (Persian cat, 8 months, small, calm)
- Max (Golden Retriever, 24 months, large, energetic)
- Whiskers (Tabby cat, 60 months, medium, independent)
- Buddy (Labrador Mix, 18 months, large, playful)
