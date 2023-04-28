{ fetchFromGitHub
, rustPlatform
}:

# let rust-overlay = builtins.getFlake "github:oxalica/rust-overlay/073959f0687277a54bfaa3ac7a77feb072f88186"; in
# with (import nixpkgs { inherit system;  overlays = [ rust-overlay.overlays.default ]; });
rustPlatform.buildRustPackage {
  pname = "mdbook-epub";
  version = "0.4.14-beta";
  src = fetchFromGitHub {
    owner = "Michael-F-Bryan";
    repo = "mdbook-epub";
    rev = "23b4f766700d08d404bb6d937f2c050381b76a06";
    sha256 = "sha256-gXQfQqtbRek74/EEH1ukCNM/7SXtWQh8B+lNZaTqfrI=";
  };
  doCheck = false;
  cargoSha256 = "sha256-f7g5e9TQca5ZoyD29kthwnygekbgliazGD/1ppddTuk=";
  cargoPatches = [ ./mdbook-epub.patch ];
}
