defmodule PactEx.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :pact_ex,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  defp package do
    [
      files: [
        "lib",
        "native",
        "checksum-*.exs",
        "mix.exs"
      ],
      description: "",
      licenses: ["UNLICENSED"],
      links: %{}
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
      {:rustler_precompiled, "~> 0.4"},
      {:rustler, ">= 0.0.0", optional: true},
      {:bandit, "~> 1.5.7", only: [:dev, :test]},
      {:plug, "~> 1.16.1", only: [:dev, :test]}
    ]
  end
end
