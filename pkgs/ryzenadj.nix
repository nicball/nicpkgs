{ lib, stdenv, fetchFromGitHub, pciutils, cmake }:

stdenv.mkDerivation rec {
  pname = "ryzenadj";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "FlyGoat";
    repo = "RyzenAdj";
    rev = "ad7f6205d14a55581a0a38c83cabc95745779c8b";
    sha256 = "sha256-NpM/hJQwhw5lRiQlp/fKt8CqOxDN3MxYR9/z3UbnqaY=";
  };

  nativeBuildInputs = [ pciutils cmake ];

  installPhase = ''
    install -D libryzenadj.so $out/lib/libryzenadj.so
    install -D ryzenadj $out/bin/ryzenadj
  '';

  meta.platforms = [ "x86_64-linux" ];
}
