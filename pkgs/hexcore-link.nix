{ lib, stdenv, fetchzip, makeWrapper, steam-run }:

stdenv.mkDerivation {
  pname = "hexcore-link";
  version = "v2.5.9";
  src = fetchzip {
    url = "https://s5.hexcore.xyz/releases/software/hexcore-link/linux/tar/HexcoreLink_2.5.9_x64.tar.gz";
    sha256 = "sha256-9uXbdT1foohz/efMmGOizEO5oC/3S77YJ9uZcSMB9GI=";
  };
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin $out/share/hexcore-link
    cp -r * $out/share/hexcore-link
    makeWrapper ${steam-run}/bin/steam-run $out/bin/hexcore-link \
      --chdir $out/share/hexcore-link \
      --add-flags $out/share/hexcore-link/hexcore-link
  '';
  meta.platforms = lib.platforms.x86;
}
