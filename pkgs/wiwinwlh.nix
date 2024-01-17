{ stdenv
, fetchFromGitHub
, haskellPackages
, pandoc
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
  installPhase = ''
    mkdir $out
    cp tutorial.epub $out/'What I Wish I Knew When Learning Haskell'.epub
    cp tutorial.md $out/
  '';
}
