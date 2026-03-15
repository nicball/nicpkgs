{ nv-sources
, rustPlatform
}:

rustPlatform.buildRustPackage {
  inherit (nv-sources.mdbook-epub) pname version src;
  doCheck = false;
  cargoHash = "sha256-2R+CpQnSupn4oD5XnCWNgvmkg7+IHaDtOBvU7n40ix4=";
  cargoLock = nv-sources.mdbook-epub.cargoLock."Cargo.lock";
}
