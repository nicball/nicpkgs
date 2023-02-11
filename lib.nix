{ pkgs }:
rec {
    modifyDerivationOutput =
        drv:
        { pname
        , version
        , buildInputs ? []
        , nativeBuildInputs ? []
        , extraCommands
        }:
        pkgs.stdenv.mkDerivation {
            inherit pname version buildInputs nativeBuildInputs;
            dontUnpack = true;
            installPhase = ''
                runHook preInstall
                cp -r ${drv} $out
                chmod -R +w $out
                ${extraCommands}
                runHook postInstall
            '';
        };
    wrapDerivationOutput = drv: path: args:
        modifyDerivationOutput drv {
            inherit (drv) pname version;
            nativeBuildInputs = [ pkgs.makeWrapper ];
            extraCommands = ''
                mv $out/${path} $out/${path}-unwrapped
                makeWrapper $out/${path}-unwrapped $out/${path} ${args}
            '';
        };
}
