{ nv-sources, lib, stdenv, opencl-headers, opencl-clhpp, ocl-icd }:

stdenv.mkDerivation rec {
  inherit (nv-sources.opencl-benchmark) pname version src;
  buildInputs = [ opencl-clhpp opencl-headers ocl-icd ];
  buildPhase = "g++ src/*.cpp -std=c++17 -pthread -O2 -lOpenCL -o OpenCL-Benchmark";
  installPhase = "mkdir $out/bin -p; mv OpenCL-Benchmark $out/bin";
}
