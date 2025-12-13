class ConvertMenuToMenuFoodItem < ActiveRecord::Migration[7.2]
  def up
    remove_column :menu_items, :price, :decimal, precision: 10, scale: 2

    if table_exists?(:menu_items_menus)
      drop_table :menu_items_menus
    end

    create_table :menu_food_items do |t|
      t.references :menu, null: false, foreign_key: true
      t.references :menu_item, null: false, foreign_key: true
      t.decimal :price, precision: 10, scale: 2, null: false

      t.timestamps

      t.index [:menu_id, :menu_item_id], unique: true
    end
  end

  def down
    drop_table :menu_food_items

    create_table :menu_items_menus, id: false do |t|
      t.bigint :menu_id, null: false
      t.bigint :menu_item_id, null: false
      t.index ["menu_id", "menu_item_id"], name: "index_menu_items_menus_on_menu_id_and_menu_item_id", unique: true
      t.index ["menu_id"], name: "index_menu_items_menus_on_menu_id"
      t.index ["menu_item_id"], name: "index_menu_items_menus_on_menu_item_id"
    end

    add_column :menu_items, :price, :decimal, precision: 10, scale: 2
  end
end
