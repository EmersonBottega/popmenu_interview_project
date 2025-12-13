# db/migrate/YYYYMMDDHHMMSS_fix_menu_item_association.rb

class FixMenuItemAssociation < ActiveRecord::Migration[7.2]
  def change
    remove_reference :menu_items, :menu, foreign_key: true
    create_table :menu_items_menus, id: false do |t|
      t.belongs_to :menu, null: false
      t.belongs_to :menu_item, null: false
    end
    add_index :menu_items_menus, [:menu_id, :menu_item_id], unique: true
    add_index :menu_items, :name, unique: true
  end
end
