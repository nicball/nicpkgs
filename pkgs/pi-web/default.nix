{ nv-sources, buildNpmPackage, google-fonts }:

buildNpmPackage {
  inherit (nv-sources.pi-web) pname version src;
  patches = [ ./font.patch ];
  npmDepsHash = "sha256-WWmrAjPrN1Nk2NrTJ9GFEBXp7Y1y/RZjMZxnJSQcNjY=";
  preBuild = ''
    ln -s ${google-fonts.override { fonts = [ "Noto Sans Mono" ]; }}/share/fonts/truetype/NotoSansMono\[wdth,wght\].ttf \
      ./app/noto-sans-mono.ttf
  '';
}
