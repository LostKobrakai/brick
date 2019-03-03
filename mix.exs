defmodule Brick.MixProject do
  use Mix.Project

  @github "https://github.com/LostKobrakai/brick"

  def project do
    [
      name: "Brick",
      source_url: @github,
      app: :brick,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_html, "~> 2.11", optional: true},
      {:jason, "~> 1.0", optional: true},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Brick is a component library bases on Phoenix.View and Phoenix.Template."
  end

  defp package do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG*),
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => @github
      }
    ]
  end
end
