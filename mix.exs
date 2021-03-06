defmodule LockApi.Mixfile do

  @version "0.0.3"
  use Mix.Project

  def project do
    [
      app: :lock_api,
      version: @version,
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {LockApi.Application, []},
      extra_applications: [:logger, :runtime_tools, :simultaneous_access_lock]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:simultaneous_access_lock, path: "/Users/hugo.figueiredo/mystuff/openrepos/simultaneous_access_lock"},
      {:alchemetrics, "~> 0.3.0"},
    ]
  end
end
