{ lib, substituteAll, wrapDerivationOutput, fetchFromGitHub, super, wm ? "sway" }:

let config = substituteAll { src = ./config; inherit wm; }; in

wrapDerivationOutput super.waybar "bin/waybar" ''
  --add-flags '--config ${config}' \
  --add-flags '--style ${./style.css}'
''
