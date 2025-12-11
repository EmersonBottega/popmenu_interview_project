### 📘 Restaurant Menu API – Project Documentation
📌 Overview

This project is a RESTful API built with Ruby on Rails 7, designed to model a restaurant system containing:

- Restaurants
- Their menus
- The menu items belonging to each menu
- The implementation currently includes Level 1 (public read endpoints) and Level 2 (CRUD operations for restaurants).
---

#### 🖥️ Development Environment

The project was developed and executed in the following environment:

Operating System: Windows 10 Pro

RubyMine IDE: 2024.3.2.1

Ruby: 3.2.9

Rails: 7.2.3

PostgreSQL:	16.x

This environment fully supports Rails 7 and its PostgreSQL integration.

---
### Level 1 — Read-Only Public Endpoints

These endpoints expose menu and menu item information to clients.

Available Endpoints:

- GET /menus – List all menus
- GET /menus/:id – Show menu details
- GET /menu_items – List all menu items
- GET /menu_items/:id – Show a specific menu item

Behavior:

- Menus include their menu items
- Controllers return JSON-formatted data
---
### Level 2 — Restaurant CRUD

Full CRUD operations for managing restaurants.

Available Endpoints:

- GET /restaurants – List all restaurants
- GET /restaurants/:id – Show restaurant details including menus and menu items
- POST /restaurants – Create a restaurant
- PUT /restaurants/:id – Update a restaurant
- DELETE /restaurants/:id – Delete a restaurant

Example Create Payload
```json
{
    "restaurant": {
        "name": "Poppo's Cafe"
    }
}
````

Implemented Behavior:

- JSON request handling using strong parameters

Standard REST status codes:

- 201 Created
- 200 OK
- 422 Unprocessable Entity
- 204 No Content for delete operations

Serialization includes:

- Menus
- Menu items belonging to each menu
---
🧠 Design Decisions & Reasoning
#### 1. Non-Nested Routes

Even though menus and menu items belong to restaurants, Level 1 required a flat structure.
The project continues using non-nested routes to maintain consistency and simplicity.

#### 2. Strong Parameters

Ensures consistent and secure API input:
```ruby
params.require(:restaurant).permit(:name)
```

#### 3. Structured JSON Responses

The API was designed to return meaningful nested data when required:
```ruby
render json: @restaurant, include: { menus: { include: :menu_items } }
```
#### 4. REST-Compliant Deletions

DELETE /restaurants/:id returns:

204 No Content


This is expected REST behavior, even though the entity is removed successfully.