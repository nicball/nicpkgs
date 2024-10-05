{ super, wrapDerivationOutput, lib, substituteAll, nicpkgs-scaling }:

let
  theme = substituteAll ({
    src = ./theme.rasi;
    fontSize = builtins.ceil (nicpkgs-scaling * 12);
  });
in

wrapDerivationOutput super.rofi-wayland "bin/rofi" "--add-flags '-theme ${theme}'"
