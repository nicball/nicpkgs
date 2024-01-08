{ lib, stdenv, linux, fetchFromGitHub, openssl, mokutil }:

let
    modDestDir = "$out/lib/modules/${linux.modDirVersion}/kernel/drivers/net/wireless/realtek/rtw89";
in

stdenv.mkDerivation {
  pname = "rtw89";
  version = "unstable-2024-01-07";
  src = fetchFromGitHub {
    owner = "lwfinger";
    repo = "rtw89";
    rev = "6dc9441698a7f2f79ff8f74c6ea3704c0c8feb61";
    sha256 = "sha256-iQF8+ufnqRxy+IttMRG4ZH7XXrvaCxPYuWNU/FwRxdc=";
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
    cp *.ko ${modDestDir}
    xz -f ${modDestDir}/*.ko
    runHook postInstall
  '';
  meta.platforms = lib.platforms.x86;
}
