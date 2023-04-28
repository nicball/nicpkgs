{ niclib
, pkgs
}:

niclib.wrapDerivationOutput pkgs.kakoune "bin/kak" "--set KAKOUNE_CONFIG_DIR ${./config}"
