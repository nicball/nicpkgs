{ lib, wrapDerivationOutput, fetchFromGitHub, super }:

wrapDerivationOutput super.waybar "bin/waybar" ''
  --add-flags '--config ${./waybar-config}' \
  --add-flags '--style ${./waybar-style.css}'
''
