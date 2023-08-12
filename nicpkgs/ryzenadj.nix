{ lib, stdenv, fetchFromGitHub, pciutils, cmake }:

stdenv.mkDerivation rec {
  pname = "ryzenadj";
  version = "unstable-2023-07-14";

  src = fetchFromGitHub {
    owner = "FlyGoat";
    repo = "RyzenAdj";
    rev = "7201ff25533698bfe3c402a87d479e02358bd929";
    sha256 = "sha256-znBKCmZTUP2oOcOWKCr7LyZDm9u5257ia0wzrpVq0ps=";
  };

  nativeBuildInputs = [ pciutils cmake ];

  installPhase = ''
    install -D libryzenadj.so $out/lib/libryzenadj.so
    install -D ryzenadj $out/bin/ryzenadj
  '';

  meta.platforms = [ "x86_64-linux" ];
}
