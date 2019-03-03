defmodule Brick.MixProject do
  use Mix.Project

  def project do
    [
      app: :brick,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
end
