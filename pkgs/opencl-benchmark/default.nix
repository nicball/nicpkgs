{ lib, stdenv, fetchFromGitHub, opencl-headers, opencl-clhpp, ocl-icd, OpenCL }:

let
  clhpp = opencl-clhpp.overrideAttrs rec {
    version = "2024.10.24";
    src = fetchFromGitHub {
      owner = "KhronosGroup";
      repo = "OpenCL-CLHPP";
      rev = "v${version}";
      sha256 = "sha256-b5f2qFJqLdGEMGnaUY8JmWj2vjZscwLua4FhgC4YP+k=";
    };
  };
in

stdenv.mkDerivation rec {
  pname = "OpenCL-Benchmark";
  version = "unstable-2025-02-11";
  src = fetchFromGitHub {
    owner = "ProjectPhysX";
    repo = "OpenCL-Benchmark";
    rev = "c98008254c0ae7ff4c288614ea70cfaa7db6d3ed";
    sha256 = "sha256-tZ6yFs5sG1SwNIncTLW/qw2VfwC3azCft+df4naC6P4=";
  };
  buildInputs = [ clhpp ]
    ++ lib.optionals stdenv.isDarwin [ OpenCL ]
    ++ lib.optionals (!stdenv.isDarwin) [ opencl-headers ocl-icd ];
  buildPhase = "g++ src/*.cpp -std=c++17 -pthread -O2 -lOpenCL -o OpenCL-Benchmark";
  installPhase = "mkdir $out/bin -p; mv OpenCL-Benchmark $out/bin";
}
