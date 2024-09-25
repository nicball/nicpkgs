{ lib, stdenv, linux, fetchFromGitHub, openssl, mokutil }:

let
  modDestDir = "$out/lib/modules/${linux.modDirVersion}/kernel/drivers/net/wireless/realtek/rtw89";
in

stdenv.mkDerivation {
  pname = "rtw89";
  version = "unstable-2024-08-25";
  src = fetchFromGitHub {
    owner = "lwfinger";
    repo = "rtw89";
    rev = "d1fced1b8a741dc9f92b47c69489c24385945f6e";
    sha256 = "sha256-Htu1TihKkUCNWw5LCf+cnGyCQsj0PuijlfAolug2MC8=";
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
