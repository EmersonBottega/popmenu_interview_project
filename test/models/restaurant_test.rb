require "test_helper"

class RestaurantTest < ActiveSupport::TestCase
  test "is valid with valid attributes" do
    restaurant = Restaurant.new(name: "Poppo's Restaurant")
    assert restaurant.valid?
  end

  test "is invalid without a name" do
    restaurant = Restaurant.new(name: nil)
    assert_not restaurant.valid?
    assert_includes restaurant.errors[:name], "can't be blank"
  end

  test "is invalid with duplicated name" do
    Restaurant.create!(name: "Poppo's Cafe")
    duplicate = Restaurant.new(name: "Poppo's Cafe")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end
end
