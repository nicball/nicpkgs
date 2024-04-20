{ stdenv
, fetchurl
, autoPatchelfHook
, lib
, system
}:

let
  release = (lib.importJSON ./versions.json).${system}.headless.stable;
in

stdenv.mkDerivation rec {
  pname = "factorio-headless";
  inherit (release) version;
  src = fetchurl {
    inherit (release) name url sha256;
  };
  nativeBuildInputs = [ autoPatchelfHook ];
  preferLocalBuild = true;
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/{bin,share/factorio}
    cp -a data $out/share/factorio
    cp -a bin/x64/factorio $out/bin/factorio
  '';
}
