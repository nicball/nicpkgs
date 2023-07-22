{ fetchFromGitHub, system }:

let nixos1909 = fetchFromGitHub {
  owner = "NixOS";
  repo = "nixpkgs";
  rev = "75f4ba05c63be3f147bcc2f7bd4ba1f029cedcb1";
  sha256 = "sha256-GUKHrnng33luc6mUT3rDnZ3Hm+4MMEJpEchRIAQx7JQ=";
}; in

with (import nixos1909 { inherit system; });

with python3Packages;

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
  version = "1.0.0";
  src = fetchPypi {
    inherit pname version;
    sha256 = "44a312191ee2be494052e94efdb49551aaaa305c86e2c5c643f5b831b99523e3";
  };
  propagatedBuildInputs = [
    cython jinja2 toml pillow aiohttp packaging twisted pyenet
  ] ++ twisted.extras.tls;
  doCheck = false;
}
