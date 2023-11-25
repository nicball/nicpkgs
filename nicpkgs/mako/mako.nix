{ pkgs, niclib }:

let
  config = pkgs.writeText "mako-config" "font=mono 18";
in

niclib.wrapDerivationOutput pkgs.mako "bin/mako" "--add-flags '--config ${config}'"
