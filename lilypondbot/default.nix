{ writeShellApplication
, curl
, jq
, lilypond
, timidity
, ffmpeg
}:

writeShellApplication {
  name = "lilypondbot";
  runtimeInputs = [ curl jq lilypond timidity ffmpeg ];
  text = ''
    common=${./common.ly}
    ${builtins.readFile ./lilypondbot.sh}
  '';
}
