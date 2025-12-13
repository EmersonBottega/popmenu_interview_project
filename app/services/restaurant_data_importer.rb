class RestaurantDataImporter
  def initialize(data)
    @data = data.to_h.with_indifferent_access # Ensures access via string or symbol
    @log = { success: true, item_logs: [] }
  end

  def import!
    @log = { success: true, item_logs: [] }

    ApplicationRecord.transaction do
      process_restaurants
    rescue StandardError => e
      @log[:success] = false
      @log[:error_message] = "Transaction failed: #{e.message}"
      raise ActiveRecord::Rollback
    end

    @log
  end

  private

  def process_restaurants
    @data[:restaurants].each do |restaurant_data|
      # Find or create the Restaurant
      restaurant = Restaurant.find_or_initialize_by(name: restaurant_data[:name])

      unless restaurant.persisted?
        restaurant.save!
        Rails.logger.info("Created new Restaurant: #{restaurant.name}")
      end

      process_menus(restaurant, restaurant_data[:menus])
    end
  end

  def process_menus(restaurant, menus_data)
    menus_data.each do |menu_data|
      # Find or create the Menu for this Restaurant
      menu = restaurant.menus.find_or_initialize_by(name: menu_data[:name])

      unless menu.persisted?
        menu.save!
        Rails.logger.info("Created new Menu: #{menu.name} for #{restaurant.name}")
      end

      # Handle both "menu_items" and "dishes" keys
      menu_items_key = menu_data.keys.find { |k| k.to_s.end_with?("items") || k.to_s == "dishes" }
      items_data = menu_data[menu_items_key] || []

      process_menu_items(menu, items_data)
    end
  end

  def process_menu_items(menu, items_data)
    # Using Set to track items already processed for this specific menu to handle the 'Chicken Wings' duplication
    processed_item_names = Set.new

    items_data.each_with_index do |item_data, index|
      item_name = item_data[:name]

      # Handle Duplicates in the JSON for the same menu, like: 'Chicken Wings'
      if processed_item_names.include?(item_name)
        log_warning(menu.name, item_name, "Duplicate item name in the same JSON menu list. Skipping.", index)
        next
      end
      processed_item_names << item_name

      # Find or Create MenuItem handling uniqueness across the database
      menu_item = MenuItem.find_or_initialize_by(name: item_name)

      if menu_item.new_record?
        begin
          menu_item.save!
          Rails.logger.info("Created new MenuItem: #{menu_item.name}")
        rescue ActiveRecord::RecordInvalid => e
          log_failure(menu.name, item_name, "Failed to create MenuItem (DB validation error): #{e.message}", index)
          # Stop processing this item, but continue with others
          next
        end
      end

      # Create the MenuFoodItem (the join record with price)
      price = item_data[:price]

      # Check if item is already on the menu
      if menu.menu_food_items.find_by(menu_item: menu_item)
        log_failure(menu.name, item_name, "Item already exists on this Menu. Skipping.", index)
        next
      end

      food_item = MenuFoodItem.new(
        menu: menu,
        menu_item: menu_item,
        price: price
      )

      begin
        food_item.save!
        log_success(menu.name, item_name, price)
      rescue ActiveRecord::RecordInvalid => e
        log_failure(menu.name, item_name, "Failed to link item and set price (DB validation error): #{e.message}", index)
        raise
      rescue StandardError => e
        raise e
      end
    end
  end

  def log_success(menu_name, item_name, price)
    @log[:item_logs] << {
      menu: menu_name,
      item: item_name,
      price: price,
      result: "success",
      message: "Successfully added/updated item to menu."
    }
  end

  def log_warning(menu_name, item_name, message, index)
    @log[:item_logs] << {
      menu: menu_name,
      item: item_name,
      index: index,
      result: 'warning',
      message: message
    }
    Rails.logger.warn("Import warning (Ignored) for Menu: #{menu_name}, Item: #{item_name}. Reason: #{message}")
  end

  def log_failure(menu_name, item_name, error_message, index)
    @log[:success] = false
    @log[:item_logs] << {
      menu: menu_name,
      item: item_name,
      index: index,
      result: "fail",
      message: error_message
    }
    Rails.logger.warn("Import warning for Menu: #{menu_name}, Item: #{item_name}. Reason: #{error_message}")
  end
end
