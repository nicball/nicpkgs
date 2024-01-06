{ lib, stdenv, boost, cmake, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "rime-table-bin-decompiler";
  version = "unstable-2022-10-30";
  src = fetchFromGitHub {
    owner = "kitty-panics";
    repo = "rime-table-bin-decompiler";
    rev = "c722c060f77c3895564d40bd7e3f44a2b315ee7c";
    sha256 = "sha256-2j9c9m4DvsI7jb6RnGiVtzig2qSVRCZEJL47h0Qe09o=";
  };
  nativeBuildInputs = [ cmake boost ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp ./rime-table-decompiler $out/bin
    runHook postInstall
  '';
}
