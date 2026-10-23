{ stdenv
, rustPlatform
, openssl
, pkg-config
}:

let nv = <nicpkgs>.nv-sources.${stdenv.hostPlatform.system}.armake2; in

rustPlatform.buildRustPackage rec {
  inherit (nv) pname src;
  version = "unstable-${nv.date}";
  cargoLock = nv.cargoLock."Cargo.lock";
  buildInputs = [ openssl ];
  nativeBuildInputs = [ pkg-config ];
}
