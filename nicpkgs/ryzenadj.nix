{ lib, stdenv, fetchFromGitHub, pciutils, cmake }:

stdenv.mkDerivation rec {
  pname = "ryzenadj";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "FlyGoat";
    repo = "RyzenAdj";
    rev = "4b558e75a4810f8e13375c8c3ae08025fec276ac";
    sha256 = "sha256-elIup39t1CssFFvfe7z/euUifGenWgpvdiogD4KixTA=";
  };

  nativeBuildInputs = [ pciutils cmake ];

  installPhase = ''
    install -D libryzenadj.so $out/lib/libryzenadj.so
    install -D ryzenadj $out/bin/ryzenadj
  '';

  meta.platforms = [ "x86_64-linux" ];
}
