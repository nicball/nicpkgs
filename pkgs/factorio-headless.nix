{ stdenv
, fetchurl
, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  pname = "factorio-headless";
  version = "1.1.104";
  src = fetchurl {
    name = "factorio_headless_x64-${version}.tar.xz";
    url = "https://factorio.com/get-download/${version}/headless/linux64";
    sha256 = "sha256-jhM1OrI9V5idt7BllEEdMIhd4akj86mJ0SdJwavAFYM=";
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
