{ pkgs }:
{
    modifyDerivationOutput = drv: args:
        pkgs.stdenv.mkDerivation {
            inherit (args)
                pname version buildInputs nativeBuildInputs;
            installPhase = ''
                cp -r ${drv} $out
                chmod -R +w $out
                ${args.installPhase}
            '';
        };
}
