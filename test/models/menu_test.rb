require "test_helper"

class MenuTest < ActiveSupport::TestCase
  test "valid menu" do
    menu = Menu.new(name: "Lunch Menu")
    assert menu.valid?
  end

  test "invalid without name" do
    menu = Menu.new
    assert_not menu.valid?
  end
end
