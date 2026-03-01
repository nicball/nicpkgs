{ lib, fetchFromGitHub, python311Packages }:

with python311Packages;

let

  pyenet = buildPythonPackage rec {
    pname = "pyenet";
    version = "1.3.14";
    src = fetchPypi {
      inherit pname version;
      sha256 = "9d0f73db413fef67a18d5fda2f8d135ac4d126e46fe0929dca897b2a08a293e7";
    };
    doCheck = false;
    propagatedBuildInputs = [ cython ];
  };

in

buildPythonPackage rec {
  pname = "piqueserver";
  version = "unstable-2024-01-16";
  src = fetchFromGitHub {
    owner = "piqueserver";
    repo = "piqueserver";
    rev = "ac41b4a435780ecaa12bb7c12c4810738296073d";
    sha256 = "sha256-IJ0448T26Vdy9QJR59N4m3RhTcvzRT+LcrdnVtoJfMc=";
  };
  patches = [ ./aiohttp.patch ];
  propagatedBuildInputs = [
    cython jinja2 toml pillow aiohttp packaging twisted pyenet
  ] ++ twisted.optional-dependencies.tls;
  doCheck = false;
  pyproject = true;
  build-system = [ setuptools ];
  meta = {
    platforms = lib.platforms.x86;
    broken = true;
  };
}
