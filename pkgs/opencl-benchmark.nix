{ stdenv, lib, opencl-headers, opencl-clhpp, ocl-icd }:

let nv = <nicpkgs>.nv-sources.${stdenv.hostPlatform.system}.opencl-benchmark; in

stdenv.mkDerivation rec {
  inherit (nv) pname version src;
  buildInputs = [ opencl-clhpp opencl-headers ocl-icd ];
  buildPhase = "g++ src/*.cpp -std=c++17 -pthread -O2 -lOpenCL -o OpenCL-Benchmark";
  installPhase = "mkdir $out/bin -p; mv OpenCL-Benchmark $out/bin/opencl-benchmark";
}
