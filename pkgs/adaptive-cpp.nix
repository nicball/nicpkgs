{ fetchFromGitHub
, lib
, symlinkJoin
, stdenv
, cmake
, boost
, llvmPackages
, python3
}:

stdenv.mkDerivation rec {
  pname = "adaptive-cpp";
  version = "v24.02.0";
  src = fetchFromGitHub {
    owner = "AdaptiveCpp";
    repo = "AdaptiveCpp";
    rev = version;
    sha256 = "sha256-9TBc5XZwz1is8D6PMfxs/MAttjXe6SLXGO5BnXIF2T0=";
  };
  nativeBuildInputs = with llvmPackages; [ cmake boost llvm clang lld openmp libclang.dev ];
  buildInputs = [ python3 ];
  cmakeFlags = [
    "-DCLANG_INCLUDE_PATH=${llvmPackages.libclang.dev}/include"
  ];
}
