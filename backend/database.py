# Simple in-memory data store for the setup app.
#
# Deliberately storage-agnostic: the interview challenge brings its own
# database layer (and dependencies) when it is merged during the interview.

items = {
    1: {"id": 1, "name": "Sample Item 1", "description": "Test item"},
    2: {"id": 2, "name": "Sample Item 2", "description": "Another test item"},
}

categories = {
    1: {"id": 1, "name": "Category A"},
    2: {"id": 2, "name": "Category B"},
}


def init_db():
    """Reset the sample data."""
    items.clear()
    items.update(
        {
            1: {"id": 1, "name": "Sample Item 1", "description": "Test item"},
            2: {"id": 2, "name": "Sample Item 2", "description": "Another test item"},
        }
    )
    categories.clear()
    categories.update(
        {
            1: {"id": 1, "name": "Category A"},
            2: {"id": 2, "name": "Category B"},
        }
    )
