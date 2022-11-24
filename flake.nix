{
  description = "Nicball's package collection";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixos1909 = {
    url = "github:NixOS/nixpkgs/nixos-19.09";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, nixos1909, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system: {
      packages = rec {

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

        fvckbot = (builtins.getFlake "github:nicball/fvckbot/24de6445b5c29f8bbc69f6cad20d097c17316ea0").defaultPackage."${system}";

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

        armake2 =
          with nixpkgs.legacyPackages."${system}";
          rustPlatform.buildRustPackage rec {
            pname = "armake2";
            version = "0.3.0";
            src = fetchFromGitHub {
              owner = "KoffeinFlummi";
              repo = "armake2";
              rev = "2e66c9243ab08666a5689a5344517b5ddf9f8abe";
              sha256 = "sha256-gLvizbiKWsE2bpGLnSoLbqfm1cQUcnqS4l48GeF/W8k=";
            };
            cargoHash = "sha256-04JqADSD1z6UwUMh57MqxWpmpBdSLtvf8SvYnF76kDY=";
            buildInputs = [ openssl ];
            nativeBuildInputs = [ pkg-config ];
            cargoPatches = [ ./armake2.patch ];
          };

        arma3-unix-launcher =
          with nixpkgs.legacyPackages."${system}";
          if system != "x86_64-linux" then null else
          let aulimg = builtins.fetchurl {
            url = "https://github.com/muttleyxd/arma3-unix-launcher/releases/download/commit-355/Arma_3_Unix_Launcher-x86_64.AppImage";
            sha256 = "sha256-Q82d1aBqufJErSTudvBUe4rxThrNE4Xydd7YrG9HcaU=";
          }; in
          stdenv.mkDerivation {
            pname = "arma3-unix-launcher";
            version = "6.6.6";
            nativeBuildInputs = [ makeWrapper ];
            dontUnpack = true;
            dontConfigure = true;
            dontBuild = true;
            installPhase = ''
              runHook preInstall
              mkdir -p $out/bin
              mkdir -p $out/share/arma3-unix-launcher
              cp ${aulimg} $out/share/arma3-unix-launcher/launcher.AppImage
              makeWrapper ${appimage-run}/bin/appimage-run $out/bin/arma3-unix-launcher --add-flags "$out/share/arma3-unix-launcher/launcher.AppImage"
              runHook postInstall
            '';
          };

        rust-reference = 
          with nixpkgs.legacyPackages."${system}";
          stdenv.mkDerivation {
            pname = "rust-reference";
            version = "6.6.6";
            src = fetchFromGitHub {
              owner = "rust-lang";
              repo = "reference";
              rev = "b74825d8f88b685e239ade00f00de68ba4cd63d4";
              sha256 = "sha256-NUfMatCl1cVJYZcwS3iOkRGGiaiRTC/U2G29EVhEIbI=";
            };
            dontConfigure = true;
            dontBuild = true;
            nativeBuildInputs = [ mdbook ];
            installPhase = ''
              runHook preInstall
              mdbook build
              mkdir $out
              mv book $out/
              runHook postInstall
            '';
          };

        chatterbot =
          # with (import nixos1909 { inherit system; });
          with nixpkgs.legacyPackages."${system}";
          with python37Packages;
          let
            mathparse = buildPythonPackage rec {
              pname = "mathparse";
              version = "0.1.2";
              src = fetchPypi {
                inherit pname version;
                sha256 = "58da83a32e1dbd16d0fa6fc28528e86b6fb2a9edcef107fdfe7aced48faf5de3";
              };
              doCheck = false;
              meta = {};
            };
            sqlalchemy = buildPythonPackage rec {
              pname = "SQLAlchemy";
              version = "1.3.24";
              src = fetchPypi {
                inherit pname version;
                sha256 = "ebbb777cbf9312359b897bf81ba00dae0f5cb69fba2a18265dcc18a6f5ef7519";
              };
              doCheck = false;
              meta = {};
            };
          in
          buildPythonPackage rec {
            pname = "ChatterBot";
            version = "1.0.8";
            src = fetchPypi {
              inherit pname version;
              sha256 = "867b61756f1e8d3ee43ff242389a71fd28c662ac7b668057ad452836341a78b9";
            };
            propagatedBuildInputs = [
              pytz mathparse python-dateutil sqlalchemy
            ];
            # doCheck = false;
            meta = {};
          };

       thu-checkin =
          with nixpkgs.legacyPackages."${system}";
          let python = python3.withPackages (p: with p; [ requests pillow pytesseract ]); in
          stdenv.mkDerivation {
            pname = "thu-checkin";
            version = "0.1.0";
            src = fetchFromGitHub {
              owner = "iBug";
              repo = "thu-checkin";
              rev = "2d52736322e552f2b779431f91b6bb978bef03c3";
              sha256 = "sha256-v0LrQgqB9bSbefuI6QuPjcgsqI7ieS9CbM65wv8F7MM=";
            };
            dontConfigure = true;
            dontBuild = true;
            installPhase = ''
              mkdir -p $out/bin $out/share/thu-checkin
              sed -i '22s/(.*)/("'${lib.escapeShellArgs [ (lib.escape [ "/" ] (toString ./thu-checkin.txt)) ]}'")/' ./thu-checkin.py
              cp ./thu-checkin.py $out/share/thu-checkin
              cat > $out/bin/thu-checkin <<EOF
              #!${bash}/bin/bash
              ${python}/bin/python $out/share/thu-checkin/thu-checkin.py
              EOF
              chmod +x $out/bin/thu-checkin
            '';
          };

        rtw89 =
          with nixpkgs.legacyPackages."${system}";
          let kernel = linuxKernel.packages.linux_6_0.kernel;
              modDestDir = "$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/realtek/rtw89";
          in
          stdenv.mkDerivation {
            pname = "rtw89";
            version = "9.9.9";
            src = fetchFromGitHub {
              owner = "lwfinger";
              repo = "rtw89";
              rev = "f963ec3d4d24c38ef725c422726b786376d3e233";
              sha256 = "sha256-sjL3+AmmQhptPhFjSUxToV5Q9m9WPDDx6AwC7By+KT8=";
            };
            hardeningDisable = [ "pic" "format" ];
            nativeBuildInputs = kernel.moduleBuildDependencies ++ [ openssl mokutil ];
            makeFlags = kernel.makeFlags ++ [
              "KVER=${kernel.modDirVersion}"
              "KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
            ];
            installPhase = ''
              runHook preInstall
              mkdir -p ${modDestDir}
              find . -name '*.ko' -exec cp --parents {} ${modDestDir} \;
              find ${modDestDir} -name '*.ko' -exec xz -f {} \;
              runHook postInstall
            '';
          };

        rtw89-firmware =
          with nixpkgs.legacyPackages."${system}";
          stdenv.mkDerivation {
            pname = "rtw89-firmware";
            inherit (rtw89) version src;
            dontBuild = true;
            installPhase = ''
              runHook preInstall
              mkdir -p $out/lib/firmware/rtw89
              cp rtw*.bin $out/lib/firmware/rtw89
              mkdir -p $out/lib/firmware/rtl_bt
              cp rtl*.bin $out/lib/firmware/rtl_bt
              runHook postInstall
            '';
          };

        wemeet = if system != "x86_64-linux" then null else
          with nixpkgs.legacyPackages."${system}";
          let nurpkgs = import (fetchFromGitHub {
            owner = "nix-community";
            repo = "nur-combined";
            rev = "d336fa98ac701595ae9e827b0101d95350a53593";
            sha256 = "sha256-hwz0hc5FVZanzFflbtInU7PW+DeiBy/JlF67BoZjhnM=";
          }) { nurpkgs = pkgs; inherit pkgs; }; in
          nurpkgs.repos.linyinfeng.wemeet;

        maven-j8 =
          with nixpkgs.legacyPackages."${system}";
          maven.overrideAttrs (_: _: { jdk = jdk8; });

        r8168 =
          with nixpkgs.legacyPackages."${system}";
          linuxPackages_6_0.r8168.overrideAttrs (self: super: rec {
            version = "8.051.02";
            name = "r8168-${linux_6_0.version}-${version}";
            src = ./r8168-8.051.02.tar.bz2;
            meta = super.meta // { broken = false; };
          });

      };
    });
}
