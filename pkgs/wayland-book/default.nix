{ stdenv, mdbook-epub }:

let nv = <nicpkgs>.nv-sources.${stdenv.hostPlatform.system}.wayland-book; in

stdenv.mkDerivation {
  inherit (nv) pname src;
  version = "unstable-${nv.date}";
  patches = [ ./ccpng.patch ];
  dontConfigure = true;
  dontBuild = true;
  nativeBuildInputs = [ mdbook-epub ];
  installPhase = ''
    runHook preInstall
    mkdir $out
    mdbook-epub --standalone
    mv book/*.epub $out/
    runHook postInstall
  '';
  meta.broken = true;
}
