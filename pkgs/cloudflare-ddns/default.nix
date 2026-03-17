{ rustPlatform }:

rustPlatform.buildRustPackage {
  pname = "cloudflare-ddns";
  version = "0.1.0";
  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;
}
