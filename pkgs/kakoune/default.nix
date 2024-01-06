{ lib
, kakoune-unwrapped
, kakounePlugins
, wrapKakoune
}:

let
  pkg = lib.wrapDerivationOutput kakoune-unwrapped "bin/kak" "--set KAKOUNE_CONFIG_DIR ${./config}";
  kak-lsp = lib.wrapDerivationOutput kakounePlugins.kak-lsp "bin/kak-lsp" "--add-flags '--config ${./kak-lsp.toml}'";
in

wrapKakoune pkg {
  plugins = with kakounePlugins; [
    parinfer-rust
    kakoune-state-save
    kak-lsp
    kak-ansi
  ];
} // {
  meta.mainProgram = "kak";
}
