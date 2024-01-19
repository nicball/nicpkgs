{
  description = "Nicball's package collection";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let overlay = import ./pkgs/all-packages.nix; in
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; overlays = [ overlay ]; config.allowUnfree = true; }; in {

        lib = builtins.intersectAttrs (import ./lib 42) pkgs.lib;

        packages = pkgs.lib.filterAttrs (k: v: k != "lib") (builtins.intersectAttrs (overlay 42 42) pkgs);

        everything = pkgs.symlinkJoin { name = "everything"; paths = pkgs.lib.attrValues self.packages.${system}; };

      }
    ) // {

      overlays.default = overlay;

      homeModules = import ./home-modules;

    };
}
