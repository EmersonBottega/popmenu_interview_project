require "test_helper"

class MenuItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @menu_item = menu_items(:one)
  end

  test "should get index" do
    get menu_items_url, as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal MenuItem.count, json_response.size
  end

  test "should create menu item with valid params" do
    assert_difference("MenuItem.count") do
      post menu_items_url, params: { menu_item: { name: "Ice Cream", description: "Vanilla" } }, as: :json
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "Ice Cream", json_response["name"]
  end

  test "should not create menu item with invalid params (duplicate name)" do
    assert_no_difference("MenuItem.count") do
      post menu_items_url, params: { menu_item: { name: @menu_item.name, description: "Duplicate" } }, as: :json
    end

    assert_response :unprocessable_content
    json_response = JSON.parse(response.body)
    assert_not_empty json_response["errors"]
    assert_includes json_response["errors"], "Name has already been taken"
  end

  test "should show menu item with associated menus" do
    get menu_item_url(@menu_item), as: :json
    assert_response :success
    json_response = JSON.parse(response.body)

    assert_equal @menu_item.name, json_response["name"]
    assert_not_empty json_response["menus"]
    assert json_response["menus"].any? { |m| m["name"] == menus(:one).name }
  end

  test "should update menu item with valid params" do
    patch menu_item_url(@menu_item), params: { menu_item: { description: "Updated description" } }, as: :json
    assert_response :success
    @menu_item.reload
    assert_equal "Updated description", @menu_item.description
  end

  test "should destroy menu item" do
    assert_difference("MenuItem.count", -1) do
      delete menu_item_url(@menu_item), as: :json
    end

    assert_response :no_content
  end
end
