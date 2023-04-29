{ niclib
, pkgs
}:

niclib.wrapDerivationOutput pkgs.kitty "bin/kitty" ''
  --add-flags '--config ${./kitty.conf}'
''
