require "test_helper"

class MenuTest < ActiveSupport::TestCase

  test "should be valid with a name and restaurant" do
    menu = Menu.new(name: "New Menu", restaurant: restaurants(:one))
    assert menu.valid?
  end

  test "name must be present" do
    menu = Menu.new(name: nil, restaurant: restaurants(:one))
    assert_not menu.valid?
  end

  test "must belong to a restaurant" do
    menu = Menu.new(name: "Orphan Menu", restaurant: nil)
    assert_not menu.valid?
    assert_includes menu.errors[:restaurant], "must exist"
  end

  test "can have multiple menu items" do
    menu = menus(:one)
    item1 = menu_items(:one)
    item2 = menu_items(:two)

    menu.menu_items << item1
    menu.menu_items << item2

    assert_equal 2, menu.menu_items.count
    assert_includes menu.menu_items, item1
    assert_includes menu.menu_items, item2
  end
end
