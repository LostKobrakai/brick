defmodule Brick.ComponentTest.InvalidManual do
  use Brick.Component, type: :html

  def render("default.json", _assigns), do: "default"
end
