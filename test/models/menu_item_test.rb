require "test_helper"

class MenuItemTest < ActiveSupport::TestCase

  test "should be valid with required attributes" do
    item = MenuItem.new(name: "New Item")
    assert item.valid?
  end

  test "name must be present" do
    item = MenuItem.new(name: nil)
    assert_not item.valid?
  end

  test "name must be globally unique across all menu items" do
    existing_item = menu_items(:one)
    duplicate_item = MenuItem.new(name: existing_item.name)

    assert_not duplicate_item.valid?
    assert_includes duplicate_item.errors[:name], "has already been taken"
  end

  test "can belong to multiple menus" do
    item = menu_items(:three)
    menu1 = menus(:one)
    menu2 = menus(:two)

    item.menu_food_items.create!(menu: menu1, price: 9.99)
    item.menu_food_items.create!(menu: menu2, price: 5.50)

    item.reload

    assert_equal 2, item.menus.count
    assert_includes item.menus, menu1
    assert_includes item.menus, menu2
  end

  test "cannot be added to the same menu twice" do
    item = menu_items(:three)
    menu = menus(:one)

    item.menu_food_items.create!(menu: menu, price: 10.00)

    assert_raises(ActiveRecord::RecordInvalid) do
      item.menu_food_items.create!(menu: menu, price: 12.00)
    end

    assert_equal 1, item.menus.count
  end
end
