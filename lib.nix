{ pkgs }:
{
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
}
