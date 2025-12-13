class MenusController < ApplicationController
  before_action :set_menu, only: %i[show update destroy add_item]

  def index
    menus = Menu.all
    strong_params = params.permit(:restaurant_id)
    if strong_params[:restaurant_id].present?
      menus = menus.where(restaurant_id: strong_params[:restaurant_id])
    end
    render json: menus
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

  def add_item
    strong_params = params.permit(:menu_item_id)

    item = MenuItem.find_by(id: strong_params[:menu_item_id])

    if @menu.menu_items << item
      render json: @menu, include: :menu_items, status: :ok
    else
      render json: { error: "Could not add item to menu." }, status: :unprocessable_content
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "MenuItem not found." }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record&.errors&.full_messages }, status: :unprocessable_content
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
    strong_params = params.permit(:id)
    @menu = Menu.find_by(id: strong_params[:id])
  end

  def menu_params
    params.require(:menu).permit(:name, :description, :restaurant_id)
  end
end
