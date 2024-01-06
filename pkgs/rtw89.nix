{ lib, stdenv, linux, fetchFromGitHub, openssl, mokutil }:

let
    modDestDir = "$out/lib/modules/${linux.modDirVersion}/kernel/drivers/net/wireless/realtek/rtw89";
in

stdenv.mkDerivation {
  pname = "rtw89";
  version = "unstable-2024-01-06";
  src = fetchFromGitHub {
    owner = "lwfinger";
    repo = "rtw89";
    rev = "139b1477900f7f13f0c1111c8919a3bf4aeb4a80";
    sha256 = "sha256-V4ZbNBMc7Gy/E4HLusXhxCLLN1Enb9Ua4XSpS6XB29Q=";
  };
  hardeningDisable = [ "pic" "format" ];
  nativeBuildInputs = linux.moduleBuildDependencies ++ [ openssl mokutil ];
  makeFlags = linux.makeFlags ++ [
    "KVER=${linux.modDirVersion}"
    "KSRC=${linux.dev}/lib/modules/${linux.modDirVersion}/build"
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
