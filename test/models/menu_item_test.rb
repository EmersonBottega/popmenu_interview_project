require "test_helper"

class MenuItemTest < ActiveSupport::TestCase
  setup do
    @menu = Menu.create!(name: "Dinner")
  end

  test "valid menu item" do
    item = MenuItem.new(name: "Burger", price: 9.99, menu: @menu)
    assert item.valid?
  end

  test "invalid without name" do
    item = MenuItem.new(price: 10, menu: @menu)
    assert_not item.valid?
  end

  test "invalid without price" do
    item = MenuItem.new(name: "Burger", menu: @menu)
    assert_not item.valid?
  end
end
