{ lib, wrapDerivationOutput, fetchFromGitHub, super }:

wrapDerivationOutput super.waybar "bin/waybar" ''
  --add-flags '--config ${./config}' \
  --add-flags '--style ${./style.css}'
''
