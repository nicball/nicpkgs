{ stdenv, fetchFromGitHub, mdbook-epub }:

stdenv.mkDerivation {
  pname = "helix-doc";
  version = "unstable-2023-08-11";
  src = fetchFromGitHub {
    owner = "helix-editor";
    repo = "helix";
    rev = "ee3171cc54052bc8d3569cc04bd9f6a57b43afca";
    sha256 = "sha256-EeMn5KYej0NmCf3ghOjq2s8axjaKfqurak5FzScGTO0=";
  };
  dontConfigure = true;
  dontBuild = true;
  nativeBuildInputs = [ mdbook-epub ];
  installPhase = ''
    runHook preInstall
    cd book
    mkdir $out
    mdbook-epub --standalone true
    mv book/*.epub $out/
    runHook postInstall
  '';
}


