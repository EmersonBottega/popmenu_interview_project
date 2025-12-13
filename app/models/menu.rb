class Menu < ApplicationRecord
  belongs_to :restaurant

  has_many :menu_food_items, dependent: :destroy
  has_many :menu_items, through: :menu_food_items

  validates :name, presence: true
end
