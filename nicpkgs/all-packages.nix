{ pkgs, callPackage, niclib, system, nixpkgs }:

with pkgs;

{

  piqueserver =
    #if true then null else
    let nixos1909 = fetchFromGitHub {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "75f4ba05c63be3f147bcc2f7bd4ba1f029cedcb1";
      sha256 = "sha256-GUKHrnng33luc6mUT3rDnZ3Hm+4MMEJpEchRIAQx7JQ=";
    }; in
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

  terraria-server =
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

  armake2 = pkgs.callPackage ./armake2 {};

  arma3-unix-launcher =
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

  mdbook-epub = callPackage ./mdbook-epub {};

  rust-reference = 
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

  rust-async-book = callPackage ./rust-async-book {};

  wayland-book =
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

  rtw89 =
    if system != "x86_64-linux" then null else
    lib.flip lib.makeOverridable {} (
      { kernel ? linux }:
      let
          modDestDir = "$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/realtek/rtw89";
      in
      stdenv.mkDerivation {
        pname = "rtw89";
        version = "9.9.9";
        src = fetchFromGitHub {
          owner = "lwfinger";
          repo = "rtw89";
          rev = "d6ca1625d5b4b32255c5b2d0d6f9d56ce3474fc2";
          sha256 = "sha256-V8VjQWKpE73XZyC45Ys5FYY5y61/C/K6OL8i7VM+duU=";
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
      }
    );

  wemeet =
    if system != "x86_64-linux" then null else
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

  kakoune = callPackage ./kakoune {};

  lilypondbot = pkgs.callPackage ./lilypondbot {};

  deepspeech =
    with python39Packages;
    buildPythonApplication rec {
      pname = "deepspeech";
      version = "0.9.3";
      src = fetchurl {
        "x86_64-linux" = {
          url = "https://files.pythonhosted.org/packages/d6/f3/75765fe49787f7ebead5e609801963323f47f05700fd9c78041abd9adaa1/deepspeech-0.9.3-cp39-cp39-manylinux1_x86_64.whl";
          sha256 = "e2e7295ba4997ab86b4fb1bd7a784319dfcdb508ce26638063515334c11fa05a";
        };
        "x86_64-darwin" = {
          url = "https://files.pythonhosted.org/packages/71/a2/3297556ce3f712b1f1dab947517d1307e6195fabd2d7589939cc023dbcca/deepspeech-0.9.3-cp39-cp39-macosx_10_10_x86_64.whl";
          sha256 = "e9251407bc9c51177739994941420d43afc18b972bb3f5296a2b1c11a2b92b06";
        };
      }.${system};
      format = "wheel";
      propagatedBuildInputs = [ numpy ];
      nativeBuildInputs = [ autoPatchelfHook ];
      buildInputs = [ stdenv.cc.cc.lib ];
      doCheck = false;
    };

  kindle-tool =
    stdenv.mkDerivation {
      pname = "KindleTool";
      version = "1.6.5";
      src = fetchFromGitHub {
        owner = "NiLuJe";
        repo = "KindleTool";
        rev = "v1.6.5";
        sha256 = "sha256-Io+tfwgRAPEx+TQKZLBGrrHGAVS6ndgOOh+KlBh4t2U=";
      };
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ zlib libarchive nettle ];
      makeFlags = [
        "DESTDIR="
        "PREFIX=$(out)"
      ];
    };

    emacs = 
      let
        eol = builtins.getFlake "github:nix-community/emacs-overlay/c470756d69bc9195d0ddc1fcd70110376fc93473";
        pkgs = import nixpkgs { inherit system; overlays = [ eol.overlay ]; };
      in
      with pkgs;
      lib.flip lib.makeOverridable {} (
        { plugins ? (p: with p; [ vterm ]) }:
        (emacsPackagesFor emacsPgtk).emacsWithPackages plugins
      );

    instaepub = callPackage ./instaepub {};

    kitty = callPackage ./kitty {};

    screenshot = callPackage ./screenshot {};

}
