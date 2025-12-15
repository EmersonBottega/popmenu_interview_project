require "test_helper"

class RestaurantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @restaurant = restaurants(:one)
    require "minitest/mock" unless defined?(MiniTest::Mock)
  end

  test "should get index" do
    get restaurants_url, as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal Restaurant.count, json_response.size
  end

  test "should create restaurant with valid params" do
    assert_difference("Restaurant.count") do
      post restaurants_url, params: { restaurant: { name: "New Test Restaurant", description: "Yummy food" } }, as: :json
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "New Test Restaurant", json_response["name"]
  end

  test "should not create restaurant with invalid params" do
    assert_no_difference("Restaurant.count") do
      post restaurants_url, params: { restaurant: { name: nil, description: "Missing name" } }, as: :json
    end

    assert_response :unprocessable_content
    json_response = JSON.parse(response.body)
    assert_not_empty json_response["errors"]
  end

  test "should show restaurant with nested menus and items" do
    get restaurant_url(@restaurant), as: :json
    assert_response :success
    json_response = JSON.parse(response.body)

    assert_equal @restaurant.name, json_response["name"]

    assert_not_empty json_response["menus"]
    daily_specials = json_response["menus"].find { |m| m["name"] == menus(:one).name }
    assert_not_nil daily_specials

    assert daily_specials.key?("menu_items"), "Should include menu_items in the menu"
    assert daily_specials["menu_items"].any? { |item| item["name"] == menu_items(:one).name }
  end

  test "should return 404 for non-existent restaurant on show" do
    get restaurant_url(id: 99999), as: :json
    assert_response :not_found
  end

  test "should update restaurant with valid params" do
    patch restaurant_url(@restaurant), params: { restaurant: { name: "Updated Diner Name" } }, as: :json
    assert_response :success
    @restaurant.reload
    assert_equal "Updated Diner Name", @restaurant.name
  end

  test "should not update restaurant with invalid params" do
    patch restaurant_url(@restaurant), params: { restaurant: { name: nil } }, as: :json
    assert_response :unprocessable_content
    @restaurant.reload
    assert_not_nil @restaurant.name
  end

  test "should destroy restaurant" do
    assert_difference("Restaurant.count", -1) do
      delete restaurant_url(@restaurant), as: :json
    end

    assert_response :no_content
  end
end
