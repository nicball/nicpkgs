{ lib, stdenv, fetchFromGitHub, opencl-headers, opencl-clhpp, ocl-icd }:

stdenv.mkDerivation rec {
  pname = "OpenCL-Benchmark";
  version = "unstable-2025-03-18";
  src = fetchFromGitHub {
    owner = "ProjectPhysX";
    repo = "OpenCL-Benchmark";
    rev = "3a6afef768dcf1435bc9a6def55d3827e1b4c11e";
    sha256 = "sha256-6hMjhlLoFOTocYuifdor7oZVlhFGuAO/2MoB+O5G9CY=";
  };
  buildInputs = [ opencl-clhpp opencl-headers ocl-icd ];
  buildPhase = "g++ src/*.cpp -std=c++17 -pthread -O2 -lOpenCL -o OpenCL-Benchmark";
  installPhase = "mkdir $out/bin -p; mv OpenCL-Benchmark $out/bin";
}
