locals_without_parens = [
  slot: 1,
  slot: 2,
  slot: 3
]

[
  locals_without_parens: locals_without_parens,
  import_deps: [:ecto, :phoenix],
  inputs: ["*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs}"],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  subdirectories: ["priv/*/migrations"]
]
