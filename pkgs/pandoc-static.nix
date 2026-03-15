{ stdenv, nv-sources }:

let

  version = nv-sources.pandoc-static-amd64.version;

  name = "pandoc-${version}";

  srcs = {
    "x86_64-linux" = nv-sources.pandoc-static-amd64.src;
    "aarch64-linunx" = nv-sources.pandoc-static-arm64.src;
  };

in

stdenv.mkDerivation {
  inherit (nv-sources.pandoc-static-amd64) version;
  pname = "pandoc";
  src = srcs.${stdenv.hostPlatform.system};
  buildPhase = ''
    mkdir $out
    mv * $out
  '';
  meta.platforms = builtins.attrNames srcs;
}
