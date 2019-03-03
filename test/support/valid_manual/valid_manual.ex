defmodule Brick.ComponentTest.ValidManual do
  use Brick.Component, type: :html

  def render("default.html", _assigns), do: "default"
end
