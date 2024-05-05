defmodule PactEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :pact_ex,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.11"},
      {:hackney, "~> 1.20"},
      {:jason, ">= 1.0.0"},
      {:rustler, "~> 0.34"},
      {:bandit, "~> 1.5.5", only: [:dev, :test]},
      {:plug, "~> 1.16.1", only: [:dev, :test]}
    ]
  end
end
