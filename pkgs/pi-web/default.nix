{ stdenv, buildNpmPackage, google-fonts }:

let nv = <nicpkgs>.nv-sources.${stdenv.hostPlatform.system}.pi-web; in

buildNpmPackage {
  inherit (nv) pname version src;
  patches = [ ./font.patch ];
  npmDepsHash = "sha256-7WD1AsVs7s5XAbZY/Vr3YNshCFwMzvP2v513f3Shf7c=";
  preBuild = ''
    ln -s ${google-fonts.override { fonts = [ "Noto Sans Mono" ]; }}/share/fonts/truetype/NotoSansMono\[wdth,wght\].ttf \
      ./app/noto-sans-mono.ttf
  '';
}
