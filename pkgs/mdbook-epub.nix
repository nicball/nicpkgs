{ nv-sources
, stdenv
}:

with (builtins.getFlake "github:NixOS/nixpkgs/e8be7818e19ada32105a8af937a6a473b38167ca").legacyPackages.${stdenv.system};

rustPlatform.buildRustPackage {
  inherit (nv-sources.mdbook-epub) pname version src;
  doCheck = false;
  cargoLock = nv-sources.mdbook-epub.cargoLock."Cargo.lock";
}
