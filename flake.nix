{
  description = "Nicball's package collection";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixos1909 = {
    url = "github:NixOS/nixpkgs/nixos-19.09";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, nixos1909, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system: let pkgs = nixpkgs.legacyPackages.${system}; in rec {
      lib = import ./lib.nix { inherit pkgs; };
      packages = pkgs.lib.filterAttrs (_: v: v != null) rec {

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
          with pkgs;
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
          with pkgs;
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
          with pkgs;
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

        mdbook-epub =
          # let rust-overlay = builtins.getFlake "github:oxalica/rust-overlay/073959f0687277a54bfaa3ac7a77feb072f88186"; in
          # with (import nixpkgs { inherit system;  overlays = [ rust-overlay.overlays.default ]; });
          with pkgs;
          rustPlatform.buildRustPackage {
            pname = "mdbook-epub";
            version = "0.4.14-beta";
            src = fetchFromGitHub {
              owner = "Michael-F-Bryan";
              repo = "mdbook-epub";
              rev = "23b4f766700d08d404bb6d937f2c050381b76a06";
              sha256 = "sha256-gXQfQqtbRek74/EEH1ukCNM/7SXtWQh8B+lNZaTqfrI=";
            };
            doCheck = false;
            cargoSha256 = "sha256-f7g5e9TQca5ZoyD29kthwnygekbgliazGD/1ppddTuk=";
            cargoPatches = [ ./mdbook-epub.patch ];
          };

        rust-reference = 
          with pkgs;
          stdenv.mkDerivation {
            pname = "rust-reference";
            version = "6.6.6";
            src = fetchFromGitHub {
              owner = "rust-lang";
              repo = "reference";
              rev = "3ae62681ff236d5528ef7c8c28ba7c6b2ecc6731";
              sha256 = "sha256-EEEa0uxmMXzYTo753eVAYUXekztbkR5CL5eK4XytOU8=";
            };
            dontConfigure = true;
            dontBuild = true;
            nativeBuildInputs = [ mdbook-epub ];
            installPhase = ''
              runHook preInstall
              mkdir $out
              mdbook-epub --standalone
              mv book $out/
              runHook postInstall
            '';
          };

        rust-async-book =
          with pkgs;
          stdenv.mkDerivation {
            pname = "rust-async-book";
            version = "6.6.6";
            src = fetchFromGitHub {
              owner = "rust-lang";
              repo = "async-book";
              rev = "e224ead5275545acc00fa82d94ba6d6f377c8563";
              sha256 = "sha256-lzUljczQ7hPZAVi+bFXth0sDTX+C/W1f/iBiK3gPtO0=";
            };
            dontConfigure = true;
            dontBuild = true;
            patches = [ ./rust-async-book.patch ];
            nativeBuildInputs = [ mdbook mdbook-epub ];
            installPhase = ''
              runHook preInstall
              mkdir $out
              mdbook build
              mv book $out/
              runHook postInstall
            '';
          };

        wayland-book =
          with pkgs;
          stdenv.mkDerivation {
            pname = "wayland-book";
            version = "6.6.6";
            src = fetchgit {
              url = "https://git.sr.ht/~sircmpwn/wayland-book";
              rev = "9023e006f51a37b4ee84b42966aeeaa4f6fd44c5";
              sha256 = "sha256-I8bhpzisH2veHdCtEBC06eIQrVZk8BDvWhb8JDdWiwg=";
            };
            dontConfigure = true;
            dontBuild = true;
            nativeBuildInputs = [ mdbook-epub ];
            installPhase = ''
              runHook preInstall
              mkdir $out
              mdbook-epub --standalone
              mv book $out/
              runHook postInstall
            '';
          };

        thu-checkin =
          with pkgs;
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
          if system != "x86_64-linux" then null else
          with pkgs;
          let kernel = linuxKernel.packages.linux_6_1.kernel;
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
          if system != "x86_64-linux" then null else
          with pkgs;
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

        wemeet =
          if system != "x86_64-linux" then null else
          with pkgs;
          let nurpkgs = import (fetchFromGitHub {
            owner = "nix-community";
            repo = "nur-combined";
            rev = "d336fa98ac701595ae9e827b0101d95350a53593";
            sha256 = "sha256-hwz0hc5FVZanzFflbtInU7PW+DeiBy/JlF67BoZjhnM=";
          }) { nurpkgs = pkgs; inherit pkgs; }; in
          nurpkgs.repos.linyinfeng.wemeet;

        maven-j8 =
          with pkgs;
          maven.overrideAttrs (_: _: { jdk = jdk8; });

        kakoune =
          with pkgs;
          lib.wrapDerivationOutput pkgs.kakoune "bin/kak" "--set KAKOUNE_CONFIG_DIR ${./kak-config}";

        lilypondbot =
          with pkgs;
          writeShellApplication {
            name = "lilypondbot";
            runtimeInputs = [ curl jq lilypond timidity ffmpeg ];
            text = ''
              common=${./common.ly}
              ${builtins.readFile ./lilypondbot.sh}
            '';
          };
      };
    });
}
