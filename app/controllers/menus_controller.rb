class MenusController < ApplicationController
  def index
    menus = Menu.all
    render json: menus.to_json(include: :menu_items)
  end

  def show
    menu = Menu.find_by(id: params[:id])
    render json: menu.to_json(include: :menu_items)
  end
end
