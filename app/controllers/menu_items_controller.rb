class MenuItemsController < ApplicationController
  def index
    menu_items = MenuItem.all
    render json: menu_items
  end

  def show
    item = MenuItem.find_by(id: params[:id])
    render json: item
  end
end
