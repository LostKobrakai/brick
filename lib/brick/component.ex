defmodule Brick.Component do
  @moduledoc """
  Define a brick component.

  ## Example

      defmodule Component do
        # Allows any type supported by phoenix's format encoders
        use #{inspect(__MODULE__)}, type: :html
      end

  """
  alias Brick.Component.Sources

  @type variant :: atom
  @type variant_name :: String.t()
  @type source ::
          {:inline, String.t()}
          | {:template, String.t()}
          | {:combo, inline :: String.t(), template :: String.t()}

  @doc """
  Entry point to rendering the component.
  """
  @callback render(term, term) :: term

  @doc """
  Convert a variant name to the actual name with the component type appended.
  """
  @callback variant(variant) :: variant_name

  @doc """
  Show dependencies of the components (manged by `Brick.component/3`).
  """
  @callback dependencies() :: [{module, variant}]

  @doc """
  Return the source for the component.
  """
  @callback render_source(variant | variant_name) :: source

  @doc """
  A list of all variants the component defines.

  ## Example

      defmodule Component.Author do
        use #{inspect(__MODULE__)}, type: :html
        use Phoenix.HTML

        def render("default.html", %{name: name}) do
          content_tag :span, name, itemprop: "author"
        end

        def render("cite.html", %{name: name}) do
          content_tag :cite, name, itemprop: "author"
        end
      end

      Component.Author.variants()
      # [:default, :cite]

  """
  @callback variants :: [variant]

  @doc """
  Static config for the component. This is only needed for the extended idea
  behind `Brick` to have a component library.

  ## Example

      defmodule Component.Author do
        use #{inspect(__MODULE__)}, type: :html
        use Phoenix.HTML

        def render("default.html", %{name: name}) do
          content_tag :span, name, itemprop: "author"
        end

        def config(:default) do
          %{
            name: "My Component",
            description: "My fancy component is a component",
            context: %{
              name: "Example Author"
            }
          }
        end
      end
  """
  @callback config(variant) :: term

  @optional_callbacks [config: 1]

  @doc false
  defmacro __using__(opts) do
    type = Keyword.fetch!(opts, :type)
    type = ".#{type}"
    root = __CALLER__.file |> Path.dirname()

    quote do
      Module.register_attribute(__MODULE__, :brick_dependencies, accumulate: true)

      Module.register_attribute(__MODULE__, :brick_sources, accumulate: true)
      Module.register_attribute(__MODULE__, :brick_component, persist: true)
      @brick_component true
      @brick_type unquote(type)

      use Phoenix.View, root: unquote(root), path: ""

      @before_compile unquote(__MODULE__)
      @on_definition unquote(__MODULE__)

      @behaviour unquote(__MODULE__)

      def variant(variant) when is_atom(variant) or is_binary(variant),
        do: "#{variant}#{@brick_type}"
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    stored_sources = Module.get_attribute(env.module, :brick_sources)
    root = Module.get_attribute(env.module, :phoenix_root)
    path_for_name = Sources.get_template_paths_from_phoenix(root)
    sources = Sources.grouped_up_sources(stored_sources, path_for_name)

    source_functions =
      if Application.get_env(:brick, :compile_sources, false) do
        Enum.map(sources, fn {name, content} ->
          quote do
            def render_source(unquote(name)), do: unquote(Macro.escape(content))
          end
        end)
      else
        nil
      end

    links = Module.get_attribute(env.module, :brick_dependencies)

    type = Module.get_attribute(env.module, :brick_type)

    variants =
      Enum.map(Map.keys(sources), fn variant ->
        name = String.replace_trailing(variant, type, "")
        String.to_atom(name)
      end)

    quote do
      unquote(source_functions)

      def render_source(variant) when is_atom(variant) do
        variant
        |> variant()
        |> render_source()
      end

      # Must be at the end to be include all the data
      def dependencies, do: unquote(links)

      def variants, do: unquote(variants)
    end
  end

  # Observe for def render/2 or defp render_template/2 defintions and
  # ensure template types match and accumulate the names / date to
  # later be able to know which variants the component holds and how
  # those are defined: inline code or template source or both.
  @doc false
  def __on_definition__(env, :def, :render, [template, _], _, body)
      when is_binary(template) do
    check_template(env.module, template, :render)
    block = Keyword.get(body, :do)
    add_source(env.module, template, :render, Macro.to_string(block))
  end

  def __on_definition__(env, :defp, :render_template, [template, _], _, _body)
      when is_binary(template) do
    check_template(env.module, template, :render_template)
    add_source(env.module, template, :render_template, :load)
  end

  def __on_definition__(_, _, _, _, _, _), do: :ok

  # Ensure the type of the defined render function / template matches the type
  # defined for the component.
  defp check_template(module, template, name) do
    type = Module.get_attribute(module, :brick_type)

    unless Path.extname(template) == type do
      raise Brick.Component.TypeError, %{
        module: module,
        template: template,
        callback: "#{name}/2",
        expected: Path.rootname(template) <> type
      }
    end
  end

  defp add_source(module, template, type, body) do
    Module.put_attribute(module, :brick_sources, {template, {type, body}})
  end

  def get_config(module, variant) do
    if function_exported?(module, :config, 1) do
      module.config(variant)
    else
      %{}
    end
  end

  @doc false
  # Can only be used at compile time
  def put_dependency(module, dependancy, variant) do
    Module.put_attribute(module, :brick_dependencies, {dependancy, variant})
  end

  @doc false
  # Can only be used at compile time
  def is_component?(module) do
    names = Keyword.keys(module.__info__(:attributes))
    :brick_component in names
  end
end
