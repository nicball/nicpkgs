{ lib, stdenv, fetchFromGitHub, opencl-headers, opencl-clhpp, ocl-icd, OpenCL }:

stdenv.mkDerivation rec {
  pname = "OpenCL-Benchmark";
  version = "1.5";
  src = fetchFromGitHub {
    owner = "ProjectPhysX";
    repo = "OpenCL-Benchmark";
    rev = "v${version}";
    sha256 = "sha256-urn4mNmfX4HbUc9b8RvClRCeAa0ETnRSmidricq4ad8=";
  };
  patches = [ ./cl.patch ];
  buildInputs = [ opencl-clhpp ]
    ++ lib.optionals stdenv.isDarwin [ OpenCL ]
    ++ lib.optionals (!stdenv.isDarwin) [ opencl-headers ocl-icd ];
  buildPhase = "g++ src/*.cpp -std=c++17 -pthread -O2 -lOpenCL -o OpenCL-Benchmark";
  installPhase = "mkdir $out/bin -p; mv OpenCL-Benchmark $out/bin";
  meta.broken = true;
}
