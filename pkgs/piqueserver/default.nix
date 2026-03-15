{ nv-sources, lib, fetchurl, python312Packages, enet, concatText }:

with python312Packages;

let

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
  version = nv-sources.piqueserver.date;
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
