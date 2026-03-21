{ nv-sources
, rustPlatform
, openssl_1_1
, pkg-config
}:

let nv = nv-sources.armake2; in

rustPlatform.buildRustPackage rec {
  inherit (nv) pname src;
  version = "unstable-${nv.date}";
  cargoLock = nv.cargoLock."Cargo.lock";
  buildInputs = [ openssl_1_1 ];
  nativeBuildInputs = [ pkg-config ];
}
