require "test_helper"

class MenusControllerTest < ActionDispatch::IntegrationTest
  setup do
    @menu = menus(:one)
    @restaurant = restaurants(:one)
    @menu_item = menu_items(:one)
    @menu_item_two = menu_items(:two)
  end

  test "should get index" do
    get menus_url, as: :json
    assert_response :success
  end

  test "should get index filtered by restaurant_id" do
    other_restaurant = Restaurant.create!(name: "Other Restaurant")
    Menu.create!(name: "External Menu", restaurant: other_restaurant)

    expected_count = @restaurant.menus.count

    get menus_url, params: { restaurant_id: @restaurant.id }, as: :json
    assert_response :success
    json = JSON.parse(response.body)

    assert_equal expected_count, json.count
    assert json.all? { |m| m["restaurant_id"] == @restaurant.id }
  end

  test "should show menu with its menu items" do
    @menu.menu_items << @menu_item

    get menu_url(@menu), as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert json["menu_items"].is_a?(Array)
    assert_equal @menu_item.name, json["menu_items"].first["name"]
  end

  test "should create menu with restaurant_id" do
    assert_difference("Menu.count") do
      post menus_url, params: {
        menu: {
          name: "New Dinner Menu",
          restaurant_id: @restaurant.id
        }
      }, as: :json
    end

    assert_response :created
  end

  test "should not create menu without restaurant_id" do
    post menus_url, params: {
      menu: { name: "Invalid Menu" }
    }, as: :json

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_includes json["errors"].to_s, "Restaurant must exist"
  end

  test "should update menu" do
    put menu_url(@menu), params: {
      menu: { name: "Updated Menu Name" }
    }, as: :json

    assert_response :success
    @menu.reload
    assert_equal "Updated Menu Name", @menu.name
  end

  test "should destroy menu" do
    assert_difference("Menu.count", -1) do
      delete menu_url(@menu), as: :json
    end
    assert_response :no_content
  end

  test "should add menu item to menu via add_item action" do
    assert_equal 0, @menu.menu_items.count

    post add_item_menu_url(@menu), params: {
                                             menu_item_id: @menu_item.id
    }, as: :json

    assert_response :ok
    @menu.reload
    assert_equal 1, @menu.menu_items.count
    assert_includes @menu.menu_items, @menu_item

    post add_item_menu_url(@menu), params: {
                                             menu_item_id: @menu_item_two.id
    }, as: :json

    assert_response :ok
    @menu.reload
    assert_equal 2, @menu.menu_items.count
  end

  test "should not add non-existent menu item" do
    non_existent_id = 9999
    post add_item_menu_url(@menu), params: {
                                             menu_item_id: non_existent_id
    }, as: :json

    assert_response :not_found
  end
end
