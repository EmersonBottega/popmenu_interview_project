class AddRestaurantToMenus < ActiveRecord::Migration[7.2]
  class Restaurant < ApplicationRecord; end
  class Menu < ApplicationRecord; end

  def up
    default_restaurant = Restaurant.create!(name: 'Poppos', description: 'Restaurant')
    add_reference :menus, :restaurant, foreign_key: true
    Menu.update_all(restaurant_id: default_restaurant.id)
    change_column_null :menus, :restaurant_id, false
  end

  def down
    remove_reference :menus, :restaurant, foreign_key: true
  end
end

