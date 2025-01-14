{ writeShellApplication
, curl
, jq
, lilypond-unstable
, timidity
, ffmpeg
, imagemagick
}:

writeShellApplication {
  name = "lilypondbot";
  runtimeInputs = [ curl jq lilypond-unstable timidity ffmpeg imagemagick ];
  text = ''
    common=${./common.ly}
    ${builtins.readFile ./lilypondbot.sh}
  '';
}
