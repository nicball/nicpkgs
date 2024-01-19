{ fetchFromGitHub
, rustPlatform
, openssl_1_1
, pkg-config
}:

rustPlatform.buildRustPackage rec {
  pname = "armake2";
  version = "0.3.0";
  src = fetchFromGitHub {
    owner = "KoffeinFlummi";
    repo = "armake2";
    rev = "2e66c9243ab08666a5689a5344517b5ddf9f8abe";
    sha256 = "sha256-gLvizbiKWsE2bpGLnSoLbqfm1cQUcnqS4l48GeF/W8k=";
  };
  cargoHash = "sha256-Y62c74xlpveietd+zP8uo14Q0A6h9fFdnPzCYf9RBO8=";
  buildInputs = [ openssl_1_1 ];
  nativeBuildInputs = [ pkg-config ];
  # cargoPatches = [ ./armake2.patch ];
}
