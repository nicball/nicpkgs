{ lib, buildGoModule, fetchFromGitHub, olm }:

buildGoModule {
  pname = "matrix-qq";
  version = "0.1.9";
  src = fetchFromGitHub {
    owner = "duo";
    repo = "matrix-qq";
    rev = "0.1.9";
    sha256 = "sha256-A35i4C0qmYSw02O/RD/RzJ3FsVDjjcAhOjaqfk8fVys=";
  };
  propagatedBuildInputs = [ olm ];
  vendorHash = "sha256-Haz08hkKNOilX2uBum+en9z97927kobj49bsLXow/Yo=";
}

