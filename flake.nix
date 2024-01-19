{
  description = "Nicball's package collection";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:

    let overlay = import ./pkgs/all-packages.nix; in

    flake-utils.lib.eachDefaultSystem (system:
      let

        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [ "openssl-1.1.1w" ];
          };
        };

        nolib = pkgs.lib.filterAttrs (k: v: k != "lib");

        mypkgs = ps: nolib (builtins.intersectAttrs (overlay 42 42) ps);

        addEverything = ps: ps // {
          everything = pkgs.symlinkJoin { name = "everything"; paths = pkgs.lib.attrValues ps; };
        };

      in {

        lib = builtins.intersectAttrs (import ./lib 42) pkgs.lib;

        packages = addEverything (mypkgs pkgs);

        packagesCross = builtins.mapAttrs (arch: cpkgs: addEverything (mypkgs cpkgs)) pkgs.pkgsCross;

      }
    ) // {

      overlays.default = overlay;

      homeModules = import ./home-modules;

    };
}
