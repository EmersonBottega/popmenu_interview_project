## 📘 Restaurant Menu API – Project Documentation
📌 Overview

This project is a RESTful API built with Ruby on Rails 7, designed to model a restaurant system containing:

- Restaurants
- Their menus
- The menu items belonging to each menu
- The implementation currently includes Level 1 (public read endpoints) and Level 2 (CRUD operations for restaurants).
---

### 🖥️ Development Environment

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

This level introduces the Restaurant model, enforces global uniqueness on MenuItem, and establishes the Many-to-Many (N:N) relationship between Menu and MenuItem
Available Endpoints:

- GET /restaurants – List all restaurants
- GET /restaurants/:id – Show restaurant details including menus and nested menu items
- POST /restaurants – Create a restaurant
- PUT /restaurants/:id – Update a restaurant
- DELETE /restaurants/:id - Delete a restaurant (Dependent destroy of Menus)
- GET /menus?restaurant_id=X - Lists menus filtered by a specific restaurant ID

N:N Association Endpoint:
- POST /menus/:id/add_item - Links an existing MenuItem to a specific Menu. Used to build the N:N association.

Example POST /menus/:id/add_item Payload
```json
{
  "menu_item_id": 123
}
```

Implemented Behavior:
- Global Uniqueness: MenuItem names are unique across the entire database.
- Association: MenuItem can be shared across multiple Menus within the same or different Restaurants.
- Menu Creation: Requires restaurant_id in the payload due to non-nested routes.
- Serialization: Responses for restaurants include nested menus and items for full context.
- Standard REST status codes (201, 200, 422, 204) are maintained.

---
## 🧠 Design Decisions & Reasoning

### Level 1

* Modeled **Menu** and **MenuItem** as first-class entities with clear responsibilities.
* Assumed that a Menu represents a logical grouping of items presented to customers (e.g., lunch, dinner).
* Implemented basic REST endpoints to expose model data.
* Prioritized model-level validations and unit tests to ensure data integrity early.

### Level 2

- Introduced the Restaurant model, allowing a Restaurant to have multiple Menus.
- Implemented the relationship between Menu and MenuItem as Many-to-Many (N:N) via a join table (has_and_belongs_to_many), fulfilling the requirement that a MenuItem can be on multiple Menus.
- Enforced global uniqueness on the MenuItem name (validates :name, uniqueness: true), aligning with the explicit Level 2 requirement that "MenuItem names should not be duplicated in the database" (implying global scope) and supports the idea of shared.
- Custom Endpoint (add_item): A custom POST /menus/:id/add_item was implemented to manage the linking of existing MenuItems to Menus, demonstrating control over the N:N association.

### Testing Strategy

* Focused on **unit tests** for models to validate associations and constraints (presence, uniqueness, relationships).
* Added **controller/integration tests** to verify REST endpoints and JSON responses.
* Relied on fixtures with explicit foreign key consistency to mirror realistic relational data.
* Ensured that each level’s behavior is validated independently, reflecting an iterative development approach.

### 📊 Unit Tests Explanation for Level 2

**1 - Model Tests (menu_item_test.rb and menu_test.rb)**

Primary Focus: Validations and Many-to-Many (N:N) Associations.

- test "name must be globally unique across all menu items" - Ensures the uniqueness: true validation works, preventing the creation of two MenuItems with the same name anywhere in the database.
- test "can belong to multiple menus" / test "can have multiple menu items" - Proves that the has_and_belongs_to_many relationship is correctly configured, allowing MenuItem objects to be shared and associated with multiple Menus.
- test "cannot be added to the same menu twice" - Confirms that the uniqueness constraint on the join table prevents the same item from being duplicated within a single Menu.

**2 - Controller Tests (menus_controller_test.rb)**

Primary Focus: HTTP Endpoints and N:N Relationship Integration.

- test "should add menu item to menu via add_item action" - Simulates the POST /menus/:id/add_item request using the route helper (add_item_menu_url). It verifies that the N:N link is created, the response is 200 OK, and the menu_items collection size increases correctly.
- test "should get index filtered by restaurant_id" - Ensures that MenusController#index correctly handles the ?restaurant_id=X query parameter, returning only the menus belonging to the specified restaurant.
- test "should not create menu without restaurant_id" - Confirms that the controller enforces the business rule requiring every Menu to be associated with a Restaurant upon creation.

## 🧠 Other assumptions

### 1. Non-Nested Routes

Even though menus and menu items belong to restaurants, Level 1 required a flat structure.
The project continues using non-nested routes to maintain consistency and simplicity.

### 2. Strong Parameters

Ensures consistent and secure API input:
```ruby
params.require(:restaurant).permit(:name)
```

### 3. Structured JSON Responses

The API was designed to return meaningful nested data when required:
```ruby
render json: @restaurant, include: { menus: { include: :menu_items } }
```

### 4. REST-Compliant Deletions

- DELETE /restaurants/:id returns:
- 204 No Content
- This is expected REST behavior, even though the entity is removed successfully.

> [!Important]
> - These decisions were made trying to keep the balance between realism, simplicity, and extensibility, while following the incremental progression requested in the project.
