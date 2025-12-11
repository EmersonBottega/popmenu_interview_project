require "test_helper"

class RestaurantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @restaurant = restaurants(:one)
  end

  test "should get index" do
    get restaurants_url, as: :json
    assert_response :success
  end

  test "should show restaurant" do
    get restaurant_url(@restaurant), as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal @restaurant.name, json["name"]
  end

  test "should create restaurant" do
    assert_difference("Restaurant.count") do
      post restaurants_url, params: {
        restaurant: { name: "New Restaurant" }
      }, as: :json
    end

    assert_response :created
  end

  test "should not create restaurant without name" do
    post restaurants_url, params: {
      restaurant: { name: "" }
    }, as: :json

    assert_response :unprocessable_content
  end

  test "should update restaurant" do
    put restaurant_url(@restaurant), params: {
      restaurant: { name: "Updated Name" }
    }, as: :json

    assert_response :success

    @restaurant.reload
    assert_equal "Updated Name", @restaurant.name
  end

  test "should not update restaurant with invalid data" do
    put restaurant_url(@restaurant), params: {
      restaurant: { name: "" }
    }, as: :json

    assert_response :unprocessable_content
  end

  test "should destroy restaurant" do
    assert_difference("Restaurant.count", -1) do
      delete restaurant_url(@restaurant), as: :json
    end

    assert_response :no_content
  end
end
