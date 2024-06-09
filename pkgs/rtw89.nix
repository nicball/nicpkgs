{ lib, stdenv, linux, fetchFromGitHub, openssl, mokutil }:

let
  modDestDir = "$out/lib/modules/${linux.modDirVersion}/kernel/drivers/net/wireless/realtek/rtw89";
in

stdenv.mkDerivation {
  pname = "rtw89";
  version = "unstable-2024-05-08";
  src = pkgs.fetchFromGitHub {
    owner = "lwfinger";
    repo = "rtw89";
    rev = "239cc6670a67a1e7b6f43bd681efdfedf6a53bb1";
    sha256 = "sha256-7rhZs9P9c/z1DcHLw0zhnwf6WvOOxRioJhC3k4h668A=";
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
