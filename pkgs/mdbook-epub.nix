{ fetchFromGitHub
, rustPlatform
}:

# let rust-overlay = builtins.getFlake "github:oxalica/rust-overlay/073959f0687277a54bfaa3ac7a77feb072f88186"; in
# with (import nixpkgs { inherit system;  overlays = [ rust-overlay.overlays.default ]; });
rustPlatform.buildRustPackage {
  pname = "mdbook-epub";
  version = "unstable-2024-03-30";
  src = fetchFromGitHub {
    owner = "Michael-F-Bryan";
    repo = "mdbook-epub";
    rev = "cb441315f259df9938e24e1297c7fe48d039654f";
    sha256 = "sha256-Fa9Jc+WszJL8MjtsOWndjp7afMtQ5ObGgLCVX9aT8Uw=";
  };
  doCheck = false;
  cargoSha256 = "sha256-WO3tVevrT0CyvVAZ2+ELzZ6wh04qRlq8m3VNMtVeySQ=";
  # cargoPatches = [ ./mdbook-epub.patch ];
}
