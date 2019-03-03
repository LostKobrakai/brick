defmodule BrickTest do
  use ExUnit.Case
  doctest Brick

  test "greets the world" do
    assert Brick.hello() == :world
  end
end
