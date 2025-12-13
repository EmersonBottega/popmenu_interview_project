namespace :import do
  desc "Imports restaurant data from a JSON file"
  task restaurant_data: :environment do
    file_path = ENV["FILE"]
    unless file_path && File.exist?(file_path)
      puts "Usage: rake import:restaurant_data FILE=/path/to/restaurant_data.json"
      exit 1
    end

    puts "Starting import from #{file_path}..."
    data = JSON.parse(File.read(file_path))

    importer = RestaurantDataImporter.new(data)
    results = importer.import!

    puts "\nImport Results:"
    puts "Success: #{results[:success]}"
    puts "Error Message: #{results[:error_message]}" if results[:error_message].present?
    puts "\nItem Logs:"
    results[:item_logs].each do |log|
      puts "  [#{log[:result].upcase}] Menu: #{log[:menu]}, Item: #{log[:item]} - #{log[:message]}"
    end
    puts "----------------------"
  rescue JSON::ParserError
    puts "ERROR: Failed to parse JSON file."
  rescue => e
    puts "CRITICAL ERROR: #{e.message}"
  end
end
