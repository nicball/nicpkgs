{ self
, stdenv
, makeWrapper
, lndir
}:

let

  getDerivationName = drv:
    if builtins.hasAttr "pname" drv
      then { inherit (drv) pname version; }
      else { inherit (drv) name; };

in

{
  modifyDerivationOutput =
    drv:
    { buildInputs ? []
    , nativeBuildInputs ? []
    , extraCommands
    , ...
    }@args:
    stdenv.mkDerivation (getDerivationName args // {
      inherit buildInputs nativeBuildInputs;
      dontUnpack = true;
      installPhase = ''
        runHook preInstall
        mkdir $out
        ${lndir}/bin/lndir -silent ${drv} $out
        ${extraCommands}
        runHook postInstall
      '';
      meta.platforms = drv.meta.platforms;
    });

  wrapDerivationOutput = drv: path: args:
    self.modifyDerivationOutput drv (getDerivationName drv // {
      nativeBuildInputs = [ makeWrapper ];
      extraCommands = ''
        mv $out/${path} $out/${path}-unwrapped
        makeWrapper $out/${path}-unwrapped $out/${path} ${args}
      '';
    });
}
