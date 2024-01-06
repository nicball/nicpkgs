{ lib, stdenv, linux, fetchFromGitHub, openssl, mokutil }:

let
    modDestDir = "$out/lib/modules/${linux.modDirVersion}/kernel/drivers/net/wireless/realtek/rtw89";
in

stdenv.mkDerivation {
  pname = "rtw89";
  version = "unstable-2023-10-26";
  src = fetchFromGitHub {
    owner = "lwfinger";
    repo = "rtw89";
    # rev = "6efcb8f06873053e63ddff85526ea8d3efcc8f22";
    # sha256 = "sha256-ied2vgEBetdJvt6r+9RmIh8rceH8QhY01zg6qejq3W0=";
    rev = "add37506180331f012d1b4292c65845771b9160f";
    sha256 = "sha256-JZSZ8BbMtwZ+046OJ6qjQrT9Y4JS/SX7vw84ikUSZQQ=";
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
