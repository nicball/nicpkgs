{ wrapDerivationOutput, super, lib, substituteAll, nicpkgs-scale }:

let
  style = substituteAll ({
    src = ./waybar-style.css;
  } // lib.mapAttrs (k: v: builtins.ceil (nicpkgs-scale * v)) {
    fontSize = 10;
    titleSize = 14;
    padding = 10;
    border = 2;
    borderRadius = 5;
    margin = 4;
  });
in

wrapDerivationOutput super.waybar "bin/waybar" ''
  --add-flags '--config ${./waybar-config}' \
  --add-flags '--style ${style}'
''
