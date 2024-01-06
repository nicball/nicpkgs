pkgs:

{
  modifyDerivationOutput =
    drv:
    { buildInputs ? []
    , nativeBuildInputs ? []
    , extraCommands
    , ...
    }@args:
    pkgs.stdenv.mkDerivation (pkgs.lib.getDerivationName args // {
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
    pkgs.lib.modifyDerivationOutput drv (pkgs.lib.getDerivationName drv // {
      nativeBuildInputs = [ pkgs.makeWrapper ];
      extraCommands = ''
        mv $out/${path} $out/${path}-unwrapped
        makeWrapper $out/${path}-unwrapped $out/${path} ${args}
      '';
    });

  getDerivationName = drv:
    if builtins.hasAttr "pname" drv
      then { inherit (drv) pname version; }
      else { inherit (drv) name; };
}
