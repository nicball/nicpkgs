{ stdenv, pkg-config, zlib, libarchive, nettle }:

let nv = <nicpkgs>.nv-sources.${stdenv.hostPlatform.system}.kindle-tool; in

stdenv.mkDerivation {
  inherit (nv) pname version src;
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ zlib libarchive nettle ];
  makeFlags = [
    "DESTDIR="
    "PREFIX=$(out)"
  ];
}
