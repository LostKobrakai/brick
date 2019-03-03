defmodule Brick.Component.Sources do
  @moduledoc false
  @type path_lookup :: %{
          optional(Brick.Component.variant_name()) => Path.t()
        }

  @spec grouped_up_sources(list, path_lookup) :: %{
          optional(Brick.Component.variant_name()) => Brick.Component.source()
        }
  def grouped_up_sources(stored_sources, path_for_name) do
    sources = Enum.group_by(stored_sources, &elem(&1, 0), &elem(&1, 1))

    Map.new(sources, fn
      {name, [render: body]} ->
        {name, {:inline, body}}

      {name, [render_template: :load]} ->
        path = Map.fetch!(path_for_name, name)
        {name, {:template, File.read!(path)}}

      {name, [_, _] = list} ->
        inline = Keyword.fetch!(list, :render)
        path = Map.fetch!(path_for_name, name)
        {name, {:combo, inline, File.read!(path)}}
    end)
  end

  @spec get_template_paths_from_phoenix(Path.t()) :: path_lookup
  def get_template_paths_from_phoenix(root) do
    root
    |> Phoenix.Template.find_all()
    |> Map.new(&{Phoenix.Template.template_path_to_name(&1, root), &1})
  end
end
