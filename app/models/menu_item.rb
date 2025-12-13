class MenuItem < ApplicationRecord
  has_many :menu_food_items, dependent: :destroy
  has_many :menus, through: :menu_food_items

  validates :name, presence: true, uniqueness: true
end
