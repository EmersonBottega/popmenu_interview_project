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

  test "can have multiple menu items by explicitly creating join records" do
    menu = menus(:one)
    initial_count = menu.menu_items.count

    item1 = menu_items(:three)
    item2 = menu_items(:two)

    menu.menu_food_items.create!(menu_item: item1, price: 10.99)

    menu.menu_food_items.create!(menu_item: item2, price: 5.50)

    menu.reload

    assert_equal initial_count + 2, menu.menu_items.count

    assert_includes menu.menu_items, item1
    assert_includes menu.menu_items, item2
  end
end
