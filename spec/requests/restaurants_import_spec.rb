require 'rails_helper'

RSpec.describe "Restaurants Import API", type: :request do
  before do
    Restaurant.destroy_all
    Menu.destroy_all
    MenuItem.destroy_all
    MenuFoodItem.destroy_all
  end

  let(:real_json_data) do
    {
      "restaurants": [
        {
          "name": "Poppo's Cafe",
          "menus": [
            {
              "name": "lunch",
              "menu_items": [
                { "name": "Burger", "price": 9.00 },
                { "name": "Small Salad", "price": 5.00 }
              ]
            },
            {
              "name": "dinner",
              "menu_items": [
                { "name": "Burger", "price": 15.00 },
                { "name": "Large Salad", "price": 8.00 }
              ]
            }
          ]
        },
        {
          "name": "Casa del Poppo",
          "menus": [
            {
              "name": "lunch",
              "dishes": [
                { "name": "Chicken Wings", "price": 9.00 },
                { "name": "Burger", "price": 9.00 },
                { "name": "Chicken Wings", "price": 9.00 }
              ]
            },
            {
              "name": "dinner",
              "dishes": [
                { "name": "Mega \"Burger\"", "price": 22.00 },
                { "name": "Lobster Mac & Cheese", "price": 31.00 }
              ]
            }
          ]
        }
      ]
    }.with_indifferent_access
  end

  let(:invalid_price_data) do
    {
      "restaurants": [
        {
          "name": "Fail Restaurant",
          "menus": [
            {
              "name": "lunch",
              "menu_items": [
                { "name": "Bad Item", "price": -5.00 }
              ]
            }
          ]
        }
      ]
    }.with_indifferent_access
  end

  let(:rollback_data) do
    {
      "restaurants": [
        {
          "name": nil,
          "menus": [
            { "name": "lunch", "menu_items": [{ "name": "Item", "price": 5.00 }] }
          ]
        }
      ]
    }.with_indifferent_access
  end

  describe "POST /restaurants/import" do
    let(:path) { import_restaurants_path }

    context "when importing the real, complex JSON data" do
      it "returns 200 OK and successfully imports all valid data" do
        post path, params: { restaurant_data: real_json_data }, as: :json

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body).with_indifferent_access

        expect(json_response[:success]).to be true

        expect(json_response[:item_logs].size).to eq(9)
        expect(json_response[:item_logs].select { |log| log[:result] == 'success' }.size).to eq(8)
        expect(json_response[:item_logs].select { |log| log[:result] == 'warning' }.size).to eq(1)

        expect(Restaurant.count).to eq(2)
        expect(MenuItem.count).to eq(6)
        expect(MenuFoodItem.count).to eq(8)

        burger = MenuItem.find_by!(name: 'Burger')
        poppos = Restaurant.find_by!(name: "Poppo's Cafe")

        lunch_menu = poppos.menus.find_by!(name: 'lunch')
        dinner_menu = poppos.menus.find_by!(name: 'dinner')

        expect(lunch_menu.menu_food_items.find_by(menu_item: burger).price).to eq(9.00)
        expect(dinner_menu.menu_food_items.find_by(menu_item: burger).price).to eq(15.00)
      end
    end

    context "when import has internal validation failure (Invalid Price)" do
      it "returns 422 Unprocessable Content and returns success: false" do
        post path, params: { restaurant_data: invalid_price_data }, as: :json

        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body).with_indifferent_access

        expect(json_response[:success]).to be false
        expect(json_response[:item_logs].first[:result]).to eq('fail')
        expect(json_response[:item_logs].first[:message]).to include("must be greater than or equal to 0")

        expect(Restaurant.count).to eq(0)
        expect(MenuItem.count).to eq(0)
      end
    end

    context "when a rollback is triggered (e.g., missing restaurant name)" do
      it "returns 422 Unprocessable Content and shows transaction failure" do
        post path, params: { restaurant_data: rollback_data }, as: :json

        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body).with_indifferent_access

        expect(json_response[:success]).to be false
        expect(json_response[:error_message]).to include("Transaction failed")

        expect(Restaurant.count).to eq(0)
        expect(MenuItem.count).to eq(0)
      end
    end

    context "when data format is incorrect or missing" do
      it "returns 400 Bad Request if params are missing" do
        post path, params: { wrong_key: {} }, as: :json

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body).with_indifferent_access
        expect(json_response[:error]).to include("Missing required parameter")
      end
    end
  end
end
