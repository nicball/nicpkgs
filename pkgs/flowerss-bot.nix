{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule {
  pname = "flowerss-bot";
  version = "0.8.4";
  src = fetchFromGitHub {
    owner = "indes";
    repo = "flowerss-bot";
    rev = "v0.8.4";
    sha256 = "sha256-WGXgZcj2vzgakerZWuueqQfEr7FlCSMME+g0GuO66ug=";
  };
  vendorSha256 = "sha256-nU+rCNt6xcnjTeO/fH1jDolFg+f8UMz8rbeaHEQQYGA=";
}
