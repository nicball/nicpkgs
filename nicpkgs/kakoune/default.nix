{ niclib
, pkgs
}:

with pkgs;

let
  pkg = niclib.wrapDerivationOutput kakoune-unwrapped "bin/kak" "--set KAKOUNE_CONFIG_DIR ${./config}";
in

wrapKakoune pkg { plugins = [ kakounePlugins.parinfer-rust ]; }
