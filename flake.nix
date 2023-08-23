{
  description = "Nicball's package collection";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nur.url = "github:nix-community/NUR";
  };


  outputs = { self, nixpkgs, flake-utils, nur , ... }@inputs:
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

        nur-no-pkgs = import nur {
          inherit pkgs;
          nurpkgs = pkgs;
        };

        nicpkgs = import ./nicpkgs/all-packages.nix {
          inherit system pkgs niclib callPackage nixpkgs;
        };

      in rec {

        inherit niclib;

        packages = nicpkgs;

        homeModules = import ./home-modules { inherit callPackage; };

        nur = nur-no-pkgs;

      }
    );
}
