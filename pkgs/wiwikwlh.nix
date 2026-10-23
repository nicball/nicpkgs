{ stdenv
, haskellPackages
, pandoc
, glibcLocales
}:

let nv = <nicpkgs>.nv-sources.${stdenv.hostPlatform.system}.wiwikwlh; in

stdenv.mkDerivation {
  inherit (nv) pname src;
  version = "unstable-${nv.date}";
  nativeBuildInputs = [ (haskellPackages.ghcWithPackages (p: [ p.pandoc ])) pandoc ];
  LOCALE_ARCHIVE = "${glibcLocales}/lib/locale/locale-archive";
  buildPhase = ''
    export LANG=en_US.UTF-8
    make
  '';
  installPhase = ''
    mkdir $out
    cp tutorial.epub $out/'What I Wish I Knew When Learning Haskell'.epub
  '';
}
