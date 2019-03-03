defmodule Brick do
  @moduledoc """
  Brick is a component library bases on `Phoenix.View` and `Phoenix.Template`.

  It's meant to be more strict in what it does no cater more to a component based
  workflow then `phoenix` does and also enable a few things, to not only allow
  components to be used to render data, but also create styleguides for them.
  """

  @doc """
  Import Brick and set the base namespace for the component macro.

  ## Example

      use #{inspect(__MODULE__)}, namespace: MyAppWeb.Components

  """
  defmacro __using__(opts) do
    namespace = Keyword.fetch!(opts, :namespace)

    quote do
      @brick_namespace unquote(namespace)

      import unquote(__MODULE__)
    end
  end

  defmacro component(module, variant \\ :default, assigns) do
    module = full_module(module, __CALLER__)
    Brick.Component.put_dependency(__CALLER__.module, module, variant)

    quote bind_quoted: [module: module, variant: variant, assigns: assigns] do
      Phoenix.View.render(module, module.variant(variant), assigns)
    end
  end

  def variants(module) do
    {_, _, names} = module.__templates__()
    Enum.map(names, fn name -> name |> Path.rootname() |> String.to_atom() end)
  end

  def components(application) do
    application
    |> Application.spec(:modules)
    |> Enum.filter(&Brick.Component.is_component?/1)
  end

  defmacro config(module, variant) do
    quote bind_quoted: [
            module: full_module(module, __CALLER__),
            variant: variant
          ] do
      Brick.Component.get_config(module, variant)
    end
  end

  defp full_module(module, env) do
    Module.concat(get_namespace(env.module), Macro.expand_once(module, env))
  end

  defp get_namespace(module) do
    Module.get_attribute(module, :brick_namespace)
  end
end
