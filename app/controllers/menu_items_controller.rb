class MenuItemsController < ApplicationController
  before_action :set_menu_item, only: %i[show update destroy]

  def index
    if params[:menu_id]
      render json: MenuItem.where(menu_id: params[:menu_id])
    else
      render json: MenuItem.all
    end
  end

  def show
    render json: @menu_item
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
    @menu_item = MenuItem.find(params[:id])
  end

  def menu_item_params
    params.require(:menu_item).permit(:name, :description, :price, :menu_id)
  end
end
