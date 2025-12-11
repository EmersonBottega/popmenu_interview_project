class MenuItem < ApplicationRecord
  belongs_to :menu

  validates :name, presence: true, uniqueness: { scope: :menu_id }
end
