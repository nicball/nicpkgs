{
  description = "Nicball's package collection";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };


  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in rec {

        niclib = import ./niclib.nix { inherit pkgs; };

        packages =
          let
            allPkgs = pkgs // nicpkgs // { inherit niclib; };

            callPackage = pathOrFn: extra:
              let fn = if builtins.isFunction pathOrFn then pathOrFn else import pathOrFn; in
              fn ((builtins.intersectAttrs (builtins.functionArgs fn) allPkgs) // extra);

            nicpkgs = import ./all-packages.nix {
              inherit system pkgs niclib callPackage nixpkgs;
            };
          in
          nicpkgs;

      }
    );
}
