defmodule Uber.MixProject do
  use Mix.Project

  def project do
    [
      app: :rinha,
      version: "0.0.1",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      elixirc_options: [debug_info: Mix.env() == :dev],
      build_embedded: Mix.env() not in [:dev, :test],
      start_permanent: Mix.env() not in [:dev, :test],
      aliases: aliases(),
      deps: deps()
    ]
  end

  defp aliases do
    [
      #
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.4.1"},
      {:nimble_parsec, "~> 1.3.1"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
