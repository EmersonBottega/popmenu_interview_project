require "test_helper"

class RestaurantTest < ActiveSupport::TestCase

  test "should be valid with required attributes" do
    restaurant = Restaurant.new(name: "Test Restaurant Name")
    assert restaurant.valid?
  end

  test "name must be present" do
    restaurant = Restaurant.new(name: nil)
    assert_not restaurant.valid?
    assert_includes restaurant.errors[:name], "can't be blank"
  end

  test "name must be unique" do
    existing_restaurant = restaurants(:one)
    new_restaurant = Restaurant.new(name: existing_restaurant.name)

    assert_not new_restaurant.valid?
    assert_includes new_restaurant.errors[:name], "has already been taken"
  end

  test "should destroy dependent menus" do
    restaurant = restaurants(:one)

    assert_difference('Menu.count', -restaurant.menus.count) do
      restaurant.destroy
    end
  end
end
