{ lib
, stdenvNoCC
, fetchzip
, writeScript
}:

stdenvNoCC.mkDerivation rec {
  pname = "proton-ge-bin";
  version = "GE-Proton9-14";

  src = fetchzip {
    url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";
    hash = "sha256-+nFF1VA9W1bySac4jXCa09HT970OZfayUYAp6kLVlEY=";
  };

  outputs = [ "out" "steamcompattool" ];

  buildCommand = ''
    runHook preBuild
    # Make it impossible to add to an environment. You should use the appropriate NixOS option.
    # Also leave some breadcrumbs in the file.
    echo "${pname} should not be installed into environments. Please use programs.steam.extraCompatPackages instead." > $out
    ln -s $src $steamcompattool
    runHook postBuild
  '';
}
