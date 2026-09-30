{ nv-sources
, rustPlatform
, openssl
, pkg-config
}:

let nv = nv-sources.armake2; in

rustPlatform.buildRustPackage rec {
  inherit (nv) pname src;
  version = "unstable-${nv.date}";
  cargoLock = nv.cargoLock."Cargo.lock";
  buildInputs = [ openssl ];
  nativeBuildInputs = [ pkg-config ];
}
