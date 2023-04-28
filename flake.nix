{
  description = "Nicball's package collection";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };


  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in rec {

        niclib = import ./niclib { inherit pkgs; };

        packages =
          let
            inherit (pkgs) lib;

            allPkgs = pkgs // nicpkgs // { inherit niclib; };

            callPackage = lib.callPackageWith allPkgs;

            nicpkgs = import ./nicpkgs/all-packages.nix {
              inherit system pkgs niclib callPackage nixpkgs;
            };
          in
          lib.filterAttrs (_: v: v != null) nicpkgs;

      }
    );
}
