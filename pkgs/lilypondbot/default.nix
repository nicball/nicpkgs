{ writeShellApplication
, curl
, jq
, lilypond
, timidity
, ffmpeg
, lib
}:

writeShellApplication {
  name = "lilypondbot";
  runtimeInputs = [ curl jq lilypond timidity ffmpeg ];
  text = ''
    common=${./common.ly}
    ${builtins.readFile ./lilypondbot.sh}
  '';
  meta.platforms = lib.platforms.x86;
}
