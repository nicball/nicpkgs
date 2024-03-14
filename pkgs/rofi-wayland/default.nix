{ super, wrapDerivationOutput, lib, substituteAll, nicpkgs-scale }:

let
  theme = substituteAll ({
    src = ./theme.rasi;
    fontSize = builtins.ceil (nicpkgs-scale * 12);
  });
in

wrapDerivationOutput super.rofi-wayland "bin/rofi" "--add-flags '-theme ${theme}'"
