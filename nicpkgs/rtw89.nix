{ lib, stdenv, linux, fetchFromGitHub, openssl, mokutil }:

let
    modDestDir = "$out/lib/modules/${linux.modDirVersion}/kernel/drivers/net/wireless/realtek/rtw89";
in

stdenv.mkDerivation {
  pname = "rtw89";
  version = "unstable-2023-8-13";
  src = fetchFromGitHub {
    owner = "lwfinger";
    repo = "rtw89";
    rev = "a90a30a0eddca05ccb2496b106daca4a76b89b11";
    sha256 = "sha256-NuztcWB9dg2O5Sof0bilqfHL7H1c1vMuEqnESGC1Ll0=";
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
