{ lib, stdenv, fetchFromGitHub, pciutils, cmake }:

stdenv.mkDerivation rec {
  pname = "ryzenadj";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "FlyGoat";
    repo = "RyzenAdj";
    rev = "dac383e1cd23aa9b631e20dba6d26f1fdf223164";
    sha256 = "sha256-CT/vMHnA6dyo+S4aYABSccW5ARlwJsY0omlASJ2lMoI=";
  };

  nativeBuildInputs = [ pciutils cmake ];

  installPhase = ''
    install -D libryzenadj.so $out/lib/libryzenadj.so
    install -D ryzenadj $out/bin/ryzenadj
  '';

  meta.platforms = [ "x86_64-linux" ];
}
