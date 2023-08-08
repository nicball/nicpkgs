{ lib, stdenv, linux, fetchFromGitHub, openssl, mokutil }:

{ kernel ? linux }:

let
    modDestDir = "$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/realtek/rtw89";
in

stdenv.mkDerivation {
  pname = "rtw89";
  version = "unstable-2023-8-8";
  src = fetchFromGitHub {
    owner = "lwfinger";
    repo = "rtw89";
    rev = "6345e2d1987693aeed88711707bdab37fa39dd16";
    sha256 = "sha256-81K54AkO0FmB6MnUBanpLecWYNRi09KcAxuHaylXjXQ=";
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
