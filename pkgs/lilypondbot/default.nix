{ writeShellApplication
, curl
, jq
, lilypond-unstable
, timidity
, ffmpeg
}:

writeShellApplication {
  name = "lilypondbot";
  runtimeInputs = [ curl jq lilypond-unstable timidity ffmpeg ];
  text = ''
    common=${./common.ly}
    ${builtins.readFile ./lilypondbot.sh}
  '';
}
