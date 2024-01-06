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
    rev = "6a649147438bc884111eecb7cdf3879ee6cb5f9a";
    sha256 = "sha256-V4W/+LAQI0yOphhhvRooJBKXlvryNxppXMIigtn7wXA=";
  };
  doCheck = false;
  cargoSha256 = "sha256-NNYy/zO7SWbb/1qJ/5E3uHcxR3lI6Fj8WknK9YWBrO8=";
  # cargoPatches = [ ./mdbook-epub.patch ];
}
