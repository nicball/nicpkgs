{ pkgs, niclib }:

niclib.wrapDerivationOutput pkgs.rofi-wayland "bin/rofi" "--add-flags '-theme ${./theme.rasi}'"
