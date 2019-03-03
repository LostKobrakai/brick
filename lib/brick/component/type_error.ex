defmodule Brick.Component.TypeError do
  @moduledoc """
  Error when a component tries to define templates of different types to what was supposed to be the type of the component.
  """
  defexception [:message]

  @impl true
  def exception(%{
        module: module,
        template: template,
        expected: expected,
        callback: callback
      }) do
    msg = """
    Brick.Component does only support single type components.
    #{inspect(module)} tries to define #{inspect(template)} for #{callback},
      expected: #{expected}
    """

    %__MODULE__{message: msg}
  end
end
