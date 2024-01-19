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

        lib = pkgs.lib;

        mypkgs = ps: builtins.intersectAttrs (overlay 42 42) ps;

        addEverything = pkgs: ps: ps // {
          everything = pkgs.symlinkJoin {
            name = "everything";
            paths = builtins.filter (v: !builtins.isFunction v) (lib.attrValues ps);
          };
        };

      in {

        packages = addEverything pkgs (mypkgs pkgs);

        packagesCross = builtins.mapAttrs (arch: cpkgs: addEverything cpkgs (mypkgs cpkgs)) pkgs.pkgsCross;

      }
    ) // {

      overlays.default = overlay;

      homeModules = import ./home-modules;

    };
}
