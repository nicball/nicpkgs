{ stdenv
, nv-sources
, haskellPackages
, pandoc
, glibcLocales
}:

stdenv.mkDerivation {
  inherit (nv-sources.wiwikwlh) pname src;
  version = "unstable-${nv-sources.wiwikwlh.date}";
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
