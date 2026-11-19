{ stdenv, buildNpmPackage, google-fonts }:

let nv = <nicpkgs>.nv-sources.${stdenv.hostPlatform.system}.pi-web; in

buildNpmPackage {
  inherit (nv) pname version src;
  patches = [ ./font.patch ];
  npmDepsHash = "sha256-5tnuixHqVoDj7079JchwrAhSjREZ5LpP1bz29H3oON0=";
  preBuild = ''
    ln -s ${google-fonts.override { fonts = [ "Noto Sans Mono" ]; }}/share/fonts/truetype/NotoSansMono\[wdth,wght\].ttf \
      ./app/noto-sans-mono.ttf
  '';
}
