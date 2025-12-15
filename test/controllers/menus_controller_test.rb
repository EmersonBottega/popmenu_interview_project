require "test_helper"

class MenusControllerTest < ActionDispatch::IntegrationTest
  setup do
    @menu = menus(:one)
    @restaurant = restaurants(:one)
    @new_menu_item = menu_items(:three)
    @existing_menu_item = menu_items(:one)
  end

  test "should get all menus index" do
    get menus_url, as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal Menu.count, json_response.size
  end

  test "should filter menus by restaurant_id" do
    get menus_url(restaurant_id: @restaurant.id), as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal @restaurant.menus.count, json_response.size
    assert json_response.all? { |m| m["restaurant_id"] == @restaurant.id }
  end

  test "should create menu with valid params" do
    assert_difference("Menu.count") do
      post menus_url, params: { menu: { name: "New Test Menu", description: "Drinks", restaurant_id: @restaurant.id } }, as: :json
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "New Test Menu", json_response["name"]
  end

  test "should not create menu with invalid params (missing restaurant_id)" do
    assert_no_difference("Menu.count") do
      post menus_url, params: { menu: { name: "Invalid Menu", description: "No restaurant" } }, as: :json
    end

    assert_response :unprocessable_content
    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "Restaurant must exist"
  end

  test "should show menu with associated menu_items" do
    get menu_url(@menu), as: :json
    assert_response :success
    json_response = JSON.parse(response.body)

    assert_equal @menu.name, json_response["name"]
    assert_not_empty json_response["menu_items"]
    assert json_response["menu_items"].any? { |item| item["name"] == @existing_menu_item.name }
  end

  test "should add item to menu successfully" do
    post add_item_menu_url(@menu), params: { menu_item_id: @new_menu_item.id, price: 12.50 }, as: :json

    assert_response :ok
    @menu.reload
    assert @menu.menu_items.exists?(@new_menu_item.id)
  end

  test "should return 404 if menu_item not found on add_item" do
    post add_item_menu_url(@menu), params: { menu_item_id: 99999, price: 10.00 }, as: :json

    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "MenuItem not found.", json_response["error"]
  end

  test "should return 422 if price is missing on add_item" do
    post add_item_menu_url(@menu), params: { menu_item_id: @new_menu_item.id }, as: :json

    assert_response :unprocessable_content
    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "Price can't be blank"
  end

  test "should return unprocessable_content if item is already on the menu (validation error)" do
    post add_item_menu_url(@menu), params: { menu_item_id: @existing_menu_item.id }, as: :json

    assert_response :unprocessable_content
    json_response = JSON.parse(response.body)
    assert_not_nil json_response["errors"]
  end

  test "should update menu with valid params" do
    patch menu_url(@menu), params: { menu: { name: "Updated Specials" } }, as: :json
    assert_response :success
    @menu.reload
    assert_equal "Updated Specials", @menu.name
  end

  test "should destroy menu" do
    assert_difference("Menu.count", -1) do
      delete menu_url(@menu), as: :json
    end

    assert_response :no_content
  end
end
