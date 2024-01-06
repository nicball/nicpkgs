{ stdenv, fetchFromGitHub, mdbook-epub }:

stdenv.mkDerivation {
  pname = "lean-doc";
  version = "unstable-2023-08-08";
  src = fetchFromGitHub {
    owner = "leanprover";
    repo = "lean4";
    rev = "e7a1512da8d6f9339766f3a269de56e546757fde";
    sha256 = "sha256-9oAUBNRvZxK8dBuxzH5GGhET5lyolecOHmbwywgyk4s=";
  };
  dontConfigure = true;
  dontBuild = true;
  nativeBuildInputs = [ mdbook-epub ];
  installPhase = ''
    runHook preInstall
    cd doc
    mkdir $out
    mdbook-epub --standalone true
    mv out/* $out/
    runHook postInstall
  '';
}

