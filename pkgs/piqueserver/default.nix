{ fetchFromGitHub, python38Packages }:

with python38Packages;

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
  version = "1.1.1";
  src = fetchFromGitHub {
    owner = "piqueserver";
    repo = "piqueserver";
    rev = "b14f6f00ca021ef724cb72e975bd8228a25dcc89";
    sha256 = "sha256-LrbodG6lYAtaGjl5PDYnBKLKf23OmXOgxSZfWIZvCg4=";
  };
  patches = [ ./aiohttp.patch ];
  propagatedBuildInputs = [
    cython jinja2 toml pillow aiohttp packaging twisted pyenet
  ] ++ twisted.optional-dependencies.tls;
  doCheck = false;
}
