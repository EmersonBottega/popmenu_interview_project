class MenuItemsController < ApplicationController
  before_action :set_menu_item, only: %i[show update destroy]

  def index
    render json: MenuItem.all
  end

  def show
    render json: @menu_item, include: :menus
  end

  def create
    item = MenuItem.new(menu_item_params)
    if item.save
      render json: item, status: :created
    else
      render json: { errors: item.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    if @menu_item.update(menu_item_params)
      render json: @menu_item
    else
      render json: { errors: @menu_item.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    @menu_item.destroy
    head :no_content
  end

  private

  def set_menu_item
    strong_params = params.permit(:id)
    @menu_item = MenuItem.find_by(id: strong_params[:id])
  end

  def menu_item_params
    params.require(:menu_item).permit(:name, :description, :price)
  end
end
