require 'rails_helper'

RSpec.describe RestaurantDataImporter, type: :service do
  before do
    Restaurant.destroy_all
    Menu.destroy_all
    MenuItem.destroy_all
    MenuFoodItem.destroy_all
  end

  let(:sample_data) do
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

  subject(:importer) { described_class.new(sample_data) }

  describe '#import! with valid data' do
    it 'returns success true' do
      results = importer.import!
      expect(results[:success]).to be true
    end

    it 'creates all unique restaurants' do
      expect { importer.import! }.to change(Restaurant, :count).by(2)
      expect(Restaurant.pluck(:name)).to match_array(["Poppo's Cafe", "Casa del Poppo"])
    end

    it 'creates unique MenuItems across all restaurants' do
      expect { importer.import! }.to change(MenuItem, :count).by(6)
      expect(MenuItem.where(name: 'Burger').count).to eq(1)
    end

    it 'creates the correct number of MenuFoodItems (links with price)' do
      expect { importer.import! }.to change(MenuFoodItem, :count).by(8)
    end

    it 'handles same item with different prices correctly' do
      importer.import!
      burger_item = MenuItem.find_by!(name: 'Burger')

      poppos = Restaurant.find_by!(name: "Poppo's Cafe")

      lunch_menu = poppos.menus.find_by!(name: 'lunch')
      lunch_food_item = lunch_menu.menu_food_items.find_by!(menu_item: burger_item)
      expect(lunch_food_item.price.to_f).to eq(9.00)

      dinner_menu = poppos.menus.find_by!(name: 'dinner')
      dinner_food_item = dinner_menu.menu_food_items.find_by!(menu_item: burger_item)
      expect(dinner_food_item.price.to_f).to eq(15.00)
    end

    it 'handles "dishes" key correctly and creates MenuFoodItems' do
      importer.import!
      casa = Restaurant.find_by!(name: "Casa del Poppo")
      lunch_menu = casa.menus.find_by!(name: 'lunch')

      expect(lunch_menu.menu_food_items.count).to eq(2)
      expect(lunch_menu.menu_items.pluck(:name)).to match_array(['Chicken Wings', 'Burger'])
    end

    it 'returns a list of logs with success for successful items' do
      results = importer.import!
      success_logs = results[:item_logs].select { |log| log[:result] == 'success' }
      expect(success_logs.size).to eq(8)
      expect(success_logs.map { |log| log[:item] }).to include("Burger", "Lobster Mac & Cheese")
    end
  end

  describe '#import! with invalid data and validation handling' do
    let(:invalid_data) do
      {
        "restaurants": [
          {
            "name": "",
            "menus": [
              {
                "name": "lunch",
                "menu_items": [
                  { "name": "Bad Price Item", "price": -5.00 }
                ]
              }
            ]
          }
        ]
      }.with_indifferent_access
    end

    subject(:importer_invalid) { described_class.new(invalid_data) }

    it 'returns success false and rolls back the transaction' do
      expect { importer_invalid.import! }.to_not change(Restaurant, :count)

      results = importer_invalid.import!
      expect(results[:success]).to be false
      expect(results[:error_message]).to include("Transaction failed")

      expect(results[:item_logs]).to be_empty
    end

    it 'causes full rollback if internal item validation fails' do
      valid_restaurant_data = {
        "restaurants": [
          {
            "name": "Test Cafe",
            "menus": [
              {
                "name": "Test Menu",
                "menu_items": [
                  { "name": "Valid Item", "price": 5.00 },
                  { "name": "Negative Price Item", "price": -5.00 }
                ]
              }
            ]
          }
        ]
      }.with_indifferent_access

      importer_mixed = described_class.new(valid_restaurant_data)

      expect { importer_mixed.import! }.to_not change(MenuFoodItem, :count)

      results = importer_mixed.import!

      expect(results[:success]).to be false

      fail_log = results[:item_logs].find { |log| log[:result] == 'fail' }
      expect(fail_log).to_not be_nil
      expect(fail_log[:item]).to eq('Negative Price Item')
      expect(fail_log[:message]).to include("must be greater than or equal to 0")

      expect(MenuFoodItem.count).to eq(0)
      expect(Restaurant.count).to eq(0)
    end

    it 'logs failure and skips item if duplicate item name is found in the same JSON menu list' do
      MenuItem.create!(name: 'Pre-existing Item')

      fail_data = {
        "restaurants": [
          {
            "name": "Fail Cafe",
            "menus": [
              {
                "name": "Fail Menu",
                "menu_items": [
                  { "name": "Pre-existing Item", "price": 10.00 },
                  { "name": "Pre-existing Item", "price": 15.00 }
                ]
              }
            ]
          }
        ]
      }.with_indifferent_access

      importer_fail = described_class.new(fail_data)
      results = importer_fail.import!

      warning_log = results[:item_logs].find { |log| log[:item] == 'Pre-existing Item' && log[:result] == 'warning' }

      expect(warning_log).to_not be_nil

      expect(warning_log[:message]).to include("Duplicate item name in the same JSON menu list")

      expect(results[:success]).to be true

      expect(MenuFoodItem.count).to eq(1)
    end
  end
end
