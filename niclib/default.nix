{ pkgs }:
rec {
    modifyDerivationOutput =
        drv:
        { buildInputs ? []
        , nativeBuildInputs ? []
        , extraCommands
        , ...
        }@args:
        pkgs.stdenv.mkDerivation (getDrvName args // {
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
        modifyDerivationOutput drv (getDrvName drv // {
            nativeBuildInputs = [ pkgs.makeWrapper ];
            extraCommands = ''
                mv $out/${path} $out/${path}-unwrapped
                makeWrapper $out/${path}-unwrapped $out/${path} ${args}
            '';
        });

    getDrvName = drv:
        if pkgs.lib.hasAttrByPath [ "pname" ] drv
            then { inherit (drv) pname version; }
            else { inherit (drv) name; };
}
