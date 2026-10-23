{ stdenv, lib, fetchurl, python312Packages, enet, concatText }:

with python312Packages;

let
  nv-sources = <nicpkgs>.nv-sources.${stdenv.hostPlatform.system};
  pyenet = buildPythonPackage rec {
    inherit (nv-sources.pyenet) pname version src;
    doCheck = false;
    buildInputs = [ enet cython_0 ];
    pyproject = true;
    build-system = [ setuptools ];
  };
in

buildPythonPackage rec {
  inherit (nv-sources.piqueserver) pname src;
  version = "0.1.0";
  dependencies = [
    jinja2 toml pillow aiohttp packaging twisted pyenet
  ] ++ twisted.optional-dependencies.tls;
  buildInputs = [ cython ];
  patches = [ ./deps.patch ];
  doCheck = false;
  pyproject = true;
  build-system = [ setuptools setuptools-scm ];
  meta = {
    platforms = lib.platforms.x86;
  };
}
