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


        addEverything = system: pkgs: ps: ps // {
          everything =
            let
              isBroken = lib.attrByPath [ "meta" "broken" ] false;
              goodPkgs = (builtins.filter (v: !isBroken v && lib.isDerivation v && lib.meta.availableOn { inherit system; } v) (lib.attrValues ps));
              pathList = builtins.map (drv: { inherit (drv) name; path = "${drv}"; }) goodPkgs;
            in pkgs.linkFarm "everything" pathList;
        };

      in {

        packages = addEverything system pkgs (mypkgs pkgs);

        packagesCross = builtins.mapAttrs (arch: cpkgs: addEverything arch cpkgs (mypkgs cpkgs)) pkgs.pkgsCross;

      }
    ) // {

      overlays.default = overlay;

      homeModules = import ./home-modules;

    };
}
