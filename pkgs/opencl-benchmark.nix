{ lib, stdenv, fetchFromGitHub, opencl-headers, opencl-clhpp, ocl-icd }:

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
  version = "unstable-2025-03-18";
  src = fetchFromGitHub {
    owner = "ProjectPhysX";
    repo = "OpenCL-Benchmark";
    rev = "3a6afef768dcf1435bc9a6def55d3827e1b4c11e";
    sha256 = "sha256-6hMjhlLoFOTocYuifdor7oZVlhFGuAO/2MoB+O5G9CY=";
  };
  buildInputs = [ clhpp opencl-headers ocl-icd ];
  buildPhase = "g++ src/*.cpp -std=c++17 -pthread -O2 -lOpenCL -o OpenCL-Benchmark";
  installPhase = "mkdir $out/bin -p; mv OpenCL-Benchmark $out/bin";
}
