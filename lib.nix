{ pkgs }:
{
    modifyDerivationOutput = drv: args:
        pkgs.stdenv.mkDerivation (args // {
            unpackPhase = ''
                runHook preUnpack
                cp -r ${drv} $out
                chmod -R +w $out
                runHook postUnpack
            '';
        });
}
