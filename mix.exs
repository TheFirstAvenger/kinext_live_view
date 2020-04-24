defmodule KinextLiveview.MixProject do
  use Mix.Project

  def project do
    [
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore.exs",
        list_unused_filters: true,
        plt_file: {:no_warn, "kinext_liveview.plt"}
      ],
      app: :kinext_liveview,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
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
      mod: {KinextLiveview.Application, []},
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
      {:kinext, "~> 0.2.0"},
      {:excoveralls, "~> 0.12.3", only: :test},
      {:credo, "~> 1.4.0-rc.2", only: :dev, runtime: false},
      {:mix_test_watch, "~> 1.0.2", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.21.3", only: :dev, runtime: false},
      {:phoenix, github: "phoenixframework/phoenix", override: true},
      {:phoenix_ecto, "~> 4.1.0"},
      {:ecto_sql, "~> 3.4.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_view, "~> 0.11.1"},
      {:floki, "~> 0.26.0", only: :test},
      {:phoenix_html, "~> 2.14.1"},
      {:phoenix_live_reload, "~> 1.2.1", only: :dev},
      {:phoenix_live_dashboard, github: "phoenixframework/phoenix_live_dashboard"},
      {:telemetry_metrics, "~> 0.4.2"},
      {:telemetry_poller, "~> 0.5.0"},
      {:gettext, "~> 0.17.4"},
      {:jason, "~> 1.2.0"},
      {:plug_cowboy, "~> 2.1.2"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
