defmodule Fox.MixProject do
  use Mix.Project

  def project do
    [
      app: :fox,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Fox.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:argon2_elixir, "~> 3.0"},
      {:ecto_sql, "~> 3.6"},
      {:ex_money, "~> 5.12"},
      {:ex_money_sql, "~> 1.7"},
      {:gettext, "~> 0.18"},
      {:heroicons, "~> 0.3"},
      {:jason, "~> 1.2"},
      {:mockable, github: "torepettersen/mockable"},
      {:phoenix, "~> 1.6.10"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_dashboard, "~> 0.6"},
      {:phoenix_live_view, "~> 0.17.5"},
      {:plug_cowboy, "~> 2.5"},
      {:postgrex, ">= 0.0.0"},
      {:req, github: "torepettersen/req"},
      {:sage, "~> 0.6"},
      {:seqfuzz, "~> 0.2.0"},
      {:swoosh, "~> 1.3"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},

      # Dev dependencies
      {:esbuild, "~> 0.4", runtime: Mix.env() == :dev},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:rio, github: "torepettersen/rio", only: :dev, runtime: false},
      {:tailwind, "~> 0.1", runtime: Mix.env() == :dev},

      # Test dependencies
      {:assertions, "~> 0.19.0", only: :test},
      {:bypass, "~> 2.1", only: :test},
      {:ex_machina, "~> 2.7.0", only: :test},
      {:floki, ">= 0.30.0", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
