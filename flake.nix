{
  description = "Nicball's package collection";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };


  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let

        niclib = import ./niclib { inherit pkgs; };

        pkgs = nixpkgs.legacyPackages.${system};

        inherit (pkgs) lib;

        allPkgs = pkgs // nicpkgs // { inherit niclib; };

        callPackage = lib.callPackageWith allPkgs;

        nicpkgs = import ./nicpkgs/all-packages.nix {
          inherit system pkgs niclib callPackage nixpkgs;
        };

      in rec {

        inherit niclib;

        packages = lib.filterAttrs (_: v: v != null) nicpkgs;

        homeModules = import ./home-modules { inherit callPackage; };

      }
    );
}
