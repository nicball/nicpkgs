{ stdenvNoCC
}:

stdenvNoCC.mkDerivation {
  pname = "monaco-ttf";
  version = "pirated";
  buildCommand = ''
    mkdir -p $out/share/fonts/truetype
    ln -s ${./Monaco.ttf} $out/share/fonts/truetype
  '';
}
