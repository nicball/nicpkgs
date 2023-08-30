{ niclib, pkgs }:

niclib.wrapDerivationOutput pkgs.waybar "bin/waybar" ''
  --add-flags '--config ${./waybar-config}' \
  --add-flags '--style ${./waybar-style.css}'
''
