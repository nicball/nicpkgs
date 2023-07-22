{
  description = "Nicball's package collection";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };


  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let

        niclib = import ./niclib { inherit pkgs; };

        pkgs = nixpkgs.legacyPackages.${system};

        inherit (pkgs) lib;

        allPkgs = pkgs // nicpkgs // { inherit niclib; };

        # callPackage = fn: extraArgs:
        #   let f = if lib.isFunction fn then fn else import fn; in
        #   f ((builtins.intersectAttrs (lib.functionArgs f) allPkgs) // extraArgs);
        callPackage = lib.callPackageWith allPkgs;

        nicpkgs = import ./nicpkgs/all-packages.nix {
          inherit system pkgs niclib callPackage nixpkgs;
        };

      in rec {

        inherit niclib;

        packages = nicpkgs;

        homeModules = import ./home-modules { inherit callPackage; };

      }
    );
}
