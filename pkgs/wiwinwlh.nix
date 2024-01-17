{ stdenv
, fetchFromGitHub
, haskellPackages
, pandoc
, glibcLocales
}:

stdenv.mkDerivation {
  pname = "wiwinwlh";
  version = "unstable-2021-06-29";
  src = fetchFromGitHub {
    owner = "sdiehl";
    repo = "wiwinwlh";
    rev = "59ccf63de431074bd202805d888b56de2d0c8ebb";
    sha256 = "sha256-0z/ZWi42cRvlL7YNy7s68Lg8Ij23Z/ljUTnD7ePq/JM=";
  };
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
