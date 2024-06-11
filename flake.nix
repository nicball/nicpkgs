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
          build-everything-unsubstitutable =
            let
              isBroken = lib.attrByPath [ "meta" "broken" ] false;
              isGood = p: lib.isDerivation p && !isBroken p && lib.meta.availableOn { inherit system; } p;
              goodPkgs = lib.filterAttrs (k: v: isGood v) ps;
              nameList = lib.concatMapStringsSep " " lib.escapeShellArg (lib.attrNames goodPkgs);
            in
            pkgs.writeShellApplication {
              name = "build-everything-unsubstitutable";
              runtimeInputs = with pkgs; [ jq nix ];
              text = ''
                bincache=''${1:?"Please tell me which binary cache to check"}
                build=''${2:-"nix build .#"}
                for name in ${nameList}; do
                  path=$(nix path-info --json .#"$name" 2>/dev/null | jq -r '.[0].path')
                  exist=$(nix path-info --json "$path" --store "$bincache" 2>/dev/null | jq '.[0].valid')
                  if $exist; then
                    echo "$name already exists, skipping..."
                  else
                    echo "Building $name..."
                    eval "$build'$name'"
                  fi
                done
              '';
            };
        };

      in {

        packages = addEverything system pkgs (mypkgs pkgs);

        packagesCross = builtins.mapAttrs (arch: cpkgs: addEverything arch cpkgs (mypkgs cpkgs)) pkgs.pkgsCross;

      }
    ) // {

      overlays.default = overlay;

      homeModules = import ./home-modules;

      nixosModules.all = import ./nixos-modules/all.nix { inherit overlay; };

    };
}
