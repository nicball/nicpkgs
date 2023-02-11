{ pkgs }:
{
    modifyDerivationOutput = drv: args:
        pkgs.stdenv.mkDerivation (args // {
            unpackPhase = ''
                runHook preUnpack
                cp -rp ${drv} $out
                runHook postUnpack
            '';
        });
}
