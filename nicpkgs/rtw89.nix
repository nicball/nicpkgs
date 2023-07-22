{ lib, stdenv, linux, fetchFromGitHub, openssl, mokutil }:

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
  meta.platforms = lib.platforms.x86;
}
