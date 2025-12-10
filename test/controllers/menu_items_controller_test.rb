require "test_helper"

class MenuItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @menu = Menu.create!(name: "Lunch")
    @item = MenuItem.create!(name: "Burger", price: 9.99, menu: @menu)
  end

  test "should get index" do
    get menu_items_url
    assert_response :success
  end

  test "should show item" do
    get menu_item_url(@item)
    assert_response :success
  end
end
