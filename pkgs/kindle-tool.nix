{ nv-sources, stdenv, pkg-config, zlib, libarchive, nettle }:

stdenv.mkDerivation {
  inherit (nv-sources.kindle-tool) pname version src;
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ zlib libarchive nettle ];
  makeFlags = [
    "DESTDIR="
    "PREFIX=$(out)"
  ];
}
