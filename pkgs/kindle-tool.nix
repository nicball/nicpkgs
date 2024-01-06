{ stdenv, fetchFromGitHub, pkg-config, zlib, libarchive, nettle }:

stdenv.mkDerivation {
  pname = "KindleTool";
  version = "1.6.5";
  src = fetchFromGitHub {
    owner = "NiLuJe";
    repo = "KindleTool";
    rev = "v1.6.5";
    sha256 = "sha256-Io+tfwgRAPEx+TQKZLBGrrHGAVS6ndgOOh+KlBh4t2U=";
  };
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ zlib libarchive nettle ];
  makeFlags = [
    "DESTDIR="
    "PREFIX=$(out)"
  ];
}
