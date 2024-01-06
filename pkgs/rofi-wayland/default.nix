{ super, lib }:

lib.wrapDerivationOutput super.rofi-wayland "bin/rofi" "--add-flags '-theme ${./theme.rasi}'"
