{ stdenv, mdbook-epub }:

let nv = <nicpkgs>.nv-sources.${stdenv.hostPlatform.system}.rust-reference; in

stdenv.mkDerivation {
  inherit (nv) pname src;
  version = "unstable-${nv.date}";
  dontConfigure = true;
  dontBuild = true;
  nativeBuildInputs = [ mdbook-epub ];
  installPhase = ''
    runHook preInstall
    mkdir $out
    mdbook-epub --standalone
    mv book/* $out/
    runHook postInstall
  '';
}
