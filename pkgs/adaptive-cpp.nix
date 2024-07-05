{ fetchFromGitHub
, lib
, symlinkJoin
, stdenv
, cmake
, boost
, llvmPackages_17
, rocmPackages
, python3
, pkg-config
, spirv-headers
}:

let
  llvm-spirv-translator = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "SPIRV-LLVM-Translator";
    rev = "40dabe4c371d810bb4f41f561e1399326dc48f62";
    sha256 = "sha256-rvMAK39cLBZ20Xh6csjlROwCoVplaeJZMlugkVmpAkY=";
  };
  opencl-headers = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "OpenCL-Headers";
    rev = "c860bb551eeef9a47d56286a70cea903db3d6ed2";
    sha256 = "sha256-U/84ASA04zJDnXqCaDsqiEG+zd1f6KfsbKTukBNkRvE=";
  };
  opencl-clhpp = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "OpenCL-CLHPP";
    rev = "0bdbbfe5ecda42cff50c96cc5e33527f42fcbd45";
    sha256 = "sha256-bIm4tGqwWX0IPKH3BwLgkf0T7YFrkN6vemYvdPrqUpw=";
  };
in

stdenv.mkDerivation rec {
  pname = "adaptive-cpp";
  version = "v24.02.0";
  src = fetchFromGitHub {
    owner = "AdaptiveCpp";
    repo = "AdaptiveCpp";
    rev = version;
    sha256 = "sha256-9TBc5XZwz1is8D6PMfxs/MAttjXe6SLXGO5BnXIF2T0=";
  };
  nativeBuildInputs = lib.flatten [
    (with llvmPackages_17; [ cmake boost clang lld llvm openmp libclang.dev ])
    (with rocmPackages; [ hipcc hip-common clr ])
    # [ pkg-config ]
  ];
  buildInputs = [ python3 ];
  preConfigure = ''
    mkdir mydeps
    cp -r ${llvm-spirv-translator} mydeps/llvm-spirv-translator
    chmod +w -R mydeps
  '';
  cmakeFlags = [
    "-DCLANG_INCLUDE_PATH=${llvmPackages_17.libclang.dev}/include"
    "-DFETCHCONTENT_SOURCE_DIR_LLVMSPIRVTRANSLATOR=/build/source/mydeps/llvm-spirv-translator"
    "-DFETCHCONTENT_SOURCE_DIR_OCL-HEADERS=${opencl-headers}"
    "-DFETCHCONTENT_SOURCE_DIR_OCL-CXX-HEADERS=${opencl-clhpp}"
  ];
  LLVM_EXTERNAL_SPIRV_HEADERS_SOURCE_DIR = "${spirv-headers}";
  meta.broken = true;
}
