{ self
, stdenv
, makeWrapper
}:

let

  getDerivationName = drv:
    if builtins.hasAttr "pname" drv
      then { inherit (drv) pname version; }
      else { inherit (drv) name; };

in

{
  fns = {
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
          cp -r ${drv} $out
          chmod -R +w $out
          ${extraCommands}
          runHook postInstall
        '';
      });

    wrapDerivationOutput = drv: path: args:
      self.modifyDerivationOutput drv (getDerivationName drv // {
        nativeBuildInputs = [ makeWrapper ];
        extraCommands = ''
          mv $out/${path} $out/${path}-unwrapped
          makeWrapper $out/${path}-unwrapped $out/${path} ${args}
        '';
      });
  };
}
