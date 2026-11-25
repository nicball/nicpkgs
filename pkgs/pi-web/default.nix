{ stdenv, buildNpmPackage, google-fonts }:

let nv = <nicpkgs>.nv-sources.${stdenv.hostPlatform.system}.pi-web; in

buildNpmPackage {
  inherit (nv) pname version src;
  patches = [ ./font.patch ];
  npmDepsHash = "sha256-vbXuQyHzmHP4VUFGPxI/f3WH9Paxwlk+ZR3JXWZjw2A=";
  preBuild = ''
    ln -s ${google-fonts.override { fonts = [ "Noto Sans Mono" ]; }}/share/fonts/truetype/NotoSansMono\[wdth,wght\].ttf \
      ./app/noto-sans-mono.ttf
  '';
}
