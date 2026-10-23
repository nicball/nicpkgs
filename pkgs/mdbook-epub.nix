{ stdenv, rustPlatform }:

let nv = <nicpkgs>.nv-sources.${stdenv.hostPlatform.system}.mdbook-epub; in

rustPlatform.buildRustPackage {
  inherit (nv) pname version src;
  doCheck = false;
  cargoLock = nv.cargoLock."Cargo.lock";
}
