{ lib
, kakoune-unwrapped
, kakounePlugins
, wrapKakoune
, wrapDerivationOutput
}:

let
  pkg = wrapDerivationOutput kakoune-unwrapped "bin/kak" "--set KAKOUNE_CONFIG_DIR ${./config}";
  kak-lsp = wrapDerivationOutput kakounePlugins.kak-lsp "bin/kak-lsp" "--add-flags '--config ${./kak-lsp.toml}'";
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
