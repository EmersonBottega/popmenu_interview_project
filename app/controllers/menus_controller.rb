class MenusController < ApplicationController
  before_action :set_menu, only: %i[show update destroy]

  def index
    if params[:restaurant_id]
      render json: Menu.where(restaurant_id: params[:restaurant_id])
    else
      render json: Menu.all
    end
  end

  def show
    render json: @menu, include: :menu_items
  end

  def create
    menu = Menu.new(menu_params)
    if menu.save
      render json: menu, status: :created
    else
      render json: { errors: menu.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    if @menu.update(menu_params)
      render json: @menu
    else
      render json: { errors: @menu.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    @menu.destroy
    head :no_content
  end

  private

  def set_menu
    @menu = Menu.find(params[:id])
  end

  def menu_params
    params.require(:menu).permit(:name, :description, :restaurant_id)
  end
end
