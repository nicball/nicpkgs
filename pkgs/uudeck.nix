{ stdenv, fetchzip, makeWrapper }:

let workdir = "/var/lib/uudeck"; in

stdenv.mkDerivation rec {
  pname = "uudeck";
  version = "8.8.12";
  src = fetchzip {
    url = "http://uu.gdl.netease.com/uuplugin/steam-deck-plugin-x86_64/v${version}/uu.tar.gz";
    hash = "sha256-SUp8x+12/7F0ADhw0QEdMx8YHZ1nZzyU/Om3rkX7RXU=";
    stripRoot = false;
  };
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/{share/uudeck,bin}
    mv * $out/share/uudeck
    makeWrapper $out/share/uudeck/uuplugin $out/bin/uudeck \
      --run "! [ -d ${workdir} ] && { mkdir -p ${workdir}; cp $out/share/uudeck/uu.conf ${workdir}; }" \
      --chdir ${workdir}
  '';
}
