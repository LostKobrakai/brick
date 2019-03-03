defmodule Brick.ComponentTest do
  use ExUnit.Case, async: true

  describe "only one type allowed" do
    test "success with manually defined function" do
      Code.compile_file("valid_manual/valid_manual.ex", root())
    end

    test "error with manually defined function" do
      msg = ~S"""
      Brick.Component does only support single type components.
      Brick.ComponentTest.InvalidManual tries to define "default.json" for render/2,
        expected: default.html
      """

      assert_raise Brick.Component.TypeError, msg, fn ->
        Code.compile_file("invalid_manual/invalid_manual.ex", root())
      end
    end

    test "success with template" do
      Code.compile_file("valid_template/valid_template.ex", root())
    end

    test "error with template" do
      msg = ~S"""
      Brick.Component does only support single type components.
      Brick.ComponentTest.InvalidTemplate tries to define "default.json" for render_template/2,
        expected: default.html
      """

      assert_raise Brick.Component.TypeError, msg, fn ->
        Code.compile_file("invalid_template/invalid_template.ex", root())
      end
    end
  end

  describe "variants/0" do
    test "single manually defined function" do
      [{module, _}] = Code.compile_file("valid_manual/valid_manual.ex", root())

      assert [:default] = module.variants()
    end

    test "single template" do
      [{module, _}] = Code.compile_file("valid_template/valid_template.ex", root())

      assert [:default] = module.variants()
    end
  end

  describe "render/0" do
    test "single manually defined function" do
      [{module, _}] = Code.compile_file("valid_manual/valid_manual.ex", root())

      assert "default" = module.render("default.html", %{})
    end

    test "single template" do
      [{module, _}] = Code.compile_file("valid_template/valid_template.ex", root())

      assert {:safe, ["default"]} = module.render("default.html", %{})
    end
  end

  describe "variant/0" do
    test "success" do
      [{module, _}] = Code.compile_file("valid_manual/valid_manual.ex", root())

      assert "default.html" = module.variant("default")
      assert "default.html" = module.variant(:default)
    end
  end

  describe "dependencies/0" do
    test "no dependencies" do
      [{module, _}] = Code.compile_file("valid_manual/valid_manual.ex", root())

      assert [] = module.dependencies()
    end

    test "with dependencies" do
      [{module, _}] = Code.compile_file("with_dependency/with_dependency.ex", root())

      assert [{Brick.ComponentTest.ValidManual, :default}] = module.dependencies()
    end
  end

  describe "render_source/1" do
    test "single manually defined function" do
      [{module, _}] = Code.compile_file("valid_manual/valid_manual.ex", root())

      source = ~S("default")
      assert {:inline, ^source} = module.render_source(:default)
    end

    test "single template" do
      [{module, _}] = Code.compile_file("valid_template/valid_template.ex", root())

      source = ~S(default)
      assert {:template, ^source} = module.render_source(:default)
    end

    test "combo" do
      [{module, _}] = Code.compile_file("combo/combo.ex", root())

      function = ~S[render_template("default.html", %{})]
      source = ~S(combo)
      assert {:combo, ^function, ^source} = module.render_source(:default)
    end
  end

  defp root do
    "test/support"
  end
end
