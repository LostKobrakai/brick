defmodule Brick.ComponentTest.Combo do
  use Brick.Component, type: :html

  def render("default.html", _assigns) do
    render_template("default.html", %{})
  end
end
