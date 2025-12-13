require "test_helper"

class MenuItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @menu_item = menu_items(:one)
    @menu = menus(:one)
    @menu_two = menus(:two)
  end

  test "should get index" do
    get menu_items_url, as: :json
    assert_response :success
  end

  test "should show menu item with its menus" do
    @menu_item.menus << @menu
    @menu_item.menus << @menu_two

    get menu_item_url(@menu_item), as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal @menu_item.name, json["name"]
    assert json["menus"].is_a?(Array)
    assert_equal 2, json["menus"].count
  end

  test "should create menu item" do
    assert_difference("MenuItem.count") do
      post menu_items_url, params: {
        menu_item: {
          name: "New Global Item",
          price: 10.00
        }
      }, as: :json
    end

    assert_response :created
  end

  test "should not create menu item with duplicate name" do
    duplicate_name = @menu_item.name

    assert_no_difference("MenuItem.count") do
      post menu_items_url, params: {
        menu_item: {
          name: duplicate_name,
          price: 1.00
        }
      }, as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_includes json["errors"].to_s, "Name has already been taken"
  end

end
