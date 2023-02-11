{ pkgs }:
{
    modifyDerivationOutput = drv: args:
        pkgs.stdenv.mkDerivation (args // {
            unpackPhase = ''
                runHook preUnpack
                cp -r ${drv} $out
                runHook postUnpack
            '';
        });
}
