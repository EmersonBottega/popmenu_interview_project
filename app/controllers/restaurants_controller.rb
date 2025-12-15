class RestaurantsController < ApplicationController
  before_action :set_restaurant, only: %i[show update destroy]

  def index
    render json: Restaurant.all
  end

  def show
    render json: @restaurant, include: { menus: { include: :menu_items } }
  end

  def create
    restaurant = Restaurant.new(restaurant_params)
    if restaurant.save
      render json: restaurant, status: :created
    else
      render json: { errors: restaurant.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    if @restaurant.update(restaurant_params)
      render json: @restaurant
    else
      render json: { errors: @restaurant.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    @restaurant.destroy
    head :no_content
  end

  def import
    data = params.require(:restaurant_data).permit!.to_h

    importer = RestaurantDataImporter.new(data)
    results = importer.import!

    if results[:success]
      render json: results, status: :ok
    else
      render json: results, status: :unprocessable_content
    end

  rescue ActionController::ParameterMissing => e
    Rails.logger.error "Import failed: Missing parameter: #{e.message}"
    render json: { error: "Missing required parameter: #{e.message}" }, status: :bad_request

  rescue => e
    Rails.logger.error "Import failed unexpectedly: #{e.message}"
    render json: { error: "An unexpected error occurred during import. Error: #{e.message}" }, status: :internal_server_error
  end

  private

  def set_restaurant
    strong_params = params.permit(:id)
    @restaurant = Restaurant.find_by(id: strong_params[:id])

    unless @restaurant
      render json: { error: "Restaurant not found" }, status: :not_found
    end
  end

  def restaurant_params
    params.require(:restaurant).permit(:name, :description)
  end
end
