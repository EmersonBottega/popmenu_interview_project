require "test_helper"

class MenusControllerTest < ActionDispatch::IntegrationTest
  setup do
    @menu = Menu.create!(name: "Lunch")
    @item = MenuItem.create!(name: "Burger", price: 9.99, menu: @menu)
  end

  test "should get index" do
    get menus_url
    assert_response :success
  end

  test "should show menu" do
    get menu_url(@menu)
    assert_response :success
  end
end
