{
  description = "Nicball's package collection";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixos1909 = {
    url = "github:NixOS/nixpkgs/nixos-19.09";
    flake = false;
  };
  inputs.fvckbot.url = "github:nicball/fvckbot";

  outputs = { self, nixpkgs, flake-utils, nixos1909, fvckbot }:
    flake-utils.lib.eachDefaultSystem (system: {
      packages = {

        piqueserver =
          with (import nixos1909 { inherit system; });
          with python3Packages;
          let
            pyenet = buildPythonPackage rec {
              pname = "pyenet";
              version = "1.3.14";
              src = fetchPypi {
                inherit pname version;
                sha256 = "9d0f73db413fef67a18d5fda2f8d135ac4d126e46fe0929dca897b2a08a293e7";
              };
              doCheck = false;
              propagatedBuildInputs = [ cython ];
              meta = {};
            };
          in
            buildPythonPackage rec {
              pname = "piqueserver";
              version = "1.0.0";
              src = fetchPypi {
                inherit pname version;
                sha256 = "44a312191ee2be494052e94efdb49551aaaa305c86e2c5c643f5b831b99523e3";
              };
              propagatedBuildInputs = [
                cython jinja2 toml pillow aiohttp packaging twisted pyenet
              ] ++ twisted.extras.tls;
              doCheck = false;
              meta = {};
            };

        fvckbot = fvckbot.defaultPackage."${system}";

        terraria-server =
          with nixpkgs.legacyPackages."${system}";
          stdenv.mkDerivation rec {
            pname = "terraria-server";
            version = "1.4.3.6";
            urlVersion = lib.replaceChars [ "." ] [ "" ] version;
            src = fetchurl {
              url = "https://terraria.org/api/download/pc-dedicated-server/terraria-server-${urlVersion}.zip";
              sha256 = "sha256-OFI7U6Mqu09pIbgJQs0O+GS8jf1uVuhAVEJhYNYXrBE=";
            };
            nativeBuildInputs = [ unzip makeWrapper ];
            installPhase = ''
              runHook preInstall
              mkdir -p $out/bin
              rm Linux/System*
              rm Linux/Mono*
              rm Linux/monoconfig
              rm Linux/mscorlib.dll
              mkdir -p $out/share/Terraria
              cp -r Linux $out/share/Terraria/
              makeWrapper ${mono}/bin/mono $out/bin/terraria-server --argv0 terraria-server --add-flags "--server --gc=sgen -O=all $out/share/Terraria/Linux/TerrariaServer.exe"
              runHook postInstall
            '';
            meta = {};
          };

      };
    });
}
