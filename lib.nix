{ pkgs }:
{
    modifyDerivationOutput =
        drv:
        { pname
        , version
        , buildInputs ? []
        , nativeBuildInputs ? []
        , installPhase ? "runHook preInstall; runHook postInstall"
        }@args:
        pkgs.stdenv.mkDerivation {
            inherit pname version buildInputs nativeBuildInputs;
            installPhase = ''
                cp -r ${drv} $out
                chmod -R +w $out
                ${args.installPhase}
            '';
        };
}
