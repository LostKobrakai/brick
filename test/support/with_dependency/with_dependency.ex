defmodule Brick.ComponentTest.WithDependency do
  use Brick, namespace: Brick.ComponentTest
  use Brick.Component, type: :html

  def render("default.html", _assigns), do: component(ValidManual, :default, %{})
end
