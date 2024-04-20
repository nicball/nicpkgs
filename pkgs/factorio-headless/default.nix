{ stdenv
, fetchurl
, autoPatchelfHook
, lib
, box64
, system
, makeWrapper
}:

let
  release = (lib.importJSON ./versions.json).x86_64-linux.headless.stable;
in

stdenv.mkDerivation rec {
  pname = "factorio-headless";
  inherit (release) version;
  src = fetchurl {
    inherit (release) name url sha256;
  };
  nativeBuildInputs = [ autoPatchelfHook ] ++ lib.optionals (system == "aarch64-linux") [ makeWrapper ];
  preferLocalBuild = true;
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/{bin,share/factorio}
    cp -a data $out/share/factorio
    cp -a bin/x64/factorio $out/bin/factorio
    ${lib.optionalString (system == "aarch64-linux") ''
      mv $out/bin/factorio $out/bin/.factorio-unwrapped
      makeWrapper ${box64}/bin/box64 $out/bin/factorio --add-flags "$out/bin/.factorio-unwrapped"
    ''}
  '';
}
