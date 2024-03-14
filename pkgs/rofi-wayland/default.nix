{ super, wrapDerivationOutput, lib, substituteAll, nicpkgs-scale }:

let
  theme = substituteAll ({
    src = ./theme.rasi;
  } // lib.mapAttrs (k: v: builtins.ceil (nicpkgs-scale * v)) {
    fontSize = 12;
    windowWidth = 480;
    smallPadding = 8;
    largePadding = 12;
  });
in

wrapDerivationOutput super.rofi-wayland "bin/rofi" "--add-flags '-theme ${theme}'"
