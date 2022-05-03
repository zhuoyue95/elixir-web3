defmodule Web3.MixProject do
  use Mix.Project

  def project do
    [
      # :cubic
      app: :web3,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Web3",
      description: "Web3 Toolkit for Elixir",
      package: package()
    ]
  end

  defp package do
    [
      name: :web3,
      licenses: ["closed"],
      source_url: "",
      homepage_url: ""
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Web3.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:decimal, "~> 2.0"},
      {:tesla, "~> 1.4"},
      {:castore, "~> 0.1.16"},
      {:finch, "~> 0.11.0"},
      {:ex_keccak, "~> 0.4.0"},
      {:ex_secp256k1, "~> 0.5.0"},
      {:ex_rlp, "~> 0.5.4"}
    ]
  end
end
