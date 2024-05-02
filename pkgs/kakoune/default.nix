{ lib
, kakoune-unwrapped
, kakounePlugins
, wrapKakoune
, wrapDerivationOutput
}:

let
  pkg = wrapDerivationOutput kakoune-unwrapped "bin/kak" "--set KAKOUNE_CONFIG_DIR ${./config}";
  kakoune-lsp = wrapDerivationOutput kakounePlugins.kakoune-lsp "bin/kak-lsp" "--add-flags '--config ${./kakoune-lsp.toml}'";
in

wrapKakoune pkg {
  plugins = with kakounePlugins; [
    parinfer-rust
    kakoune-state-save
    kakoune-lsp
    kak-ansi
  ];
} // {
  meta.mainProgram = "kak";
}
