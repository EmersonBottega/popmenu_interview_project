require "test_helper"

class MenuItemTest < ActiveSupport::TestCase

  test "should be valid with required attributes" do
    item = MenuItem.new(name: "New Item", price: 10.00)
    assert item.valid?
  end

  test "name must be present" do
    item = MenuItem.new(name: nil, price: 1.00)
    assert_not item.valid?
  end

  test "name must be globally unique across all menu items" do
    existing_item = menu_items(:one)
    duplicate_item = MenuItem.new(name: existing_item.name, price: 5.00)

    assert_not duplicate_item.valid?
    assert_includes duplicate_item.errors[:name], "has already been taken"
  end

  test "can belong to multiple menus" do
    item = menu_items(:one)
    menu1 = menus(:one)
    menu2 = menus(:two)

    item.menus << menu1
    item.menus << menu2

    assert_equal 2, item.menus.count
    assert_includes item.menus, menu1
    assert_includes item.menus, menu2
  end

  test "cannot be added to the same menu twice" do
    item = menu_items(:one)
    menu = menus(:one)

    item.menus << menu

    assert_raises(ActiveRecord::RecordNotUnique) do
      item.menus << menu
    end
  end
end
