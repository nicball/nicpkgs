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

        filterMyPkgs = ps:
          let
            skeleton = builtins.intersectAttrs (overlay 42 42) ps;
            directPkgs = lib.filterAttrs (_: v: !isRecursivePkgs v) skeleton;
            subSets = lib.filterAttrs (_: isRecursivePkgs) skeleton;
            filteredSubSets = lib.mapAttrs (k: v: builtins.intersectAttrs (overlay dummyPkgs {}).${k} v) subSets;
            dummyPkgs = {
              lib = { inherit (lib) recurseIntoAttrs; };
              callPackage = fnOrPath: additionalArgs:
                let
                  fn = if builtins.isPath fnOrPath then import fnOrPath else fnOrPath;
                  args = lib.mapAttrs (k: v: 42) (lib.functionArgs fn) // additionalArgs;
                in
                fn args;
            };
          in
          directPkgs // filteredSubSets;

        isBroken = lib.attrByPath [ "meta" "broken" ] false;

        isGood = system: p: lib.isDerivation p && !isBroken p && lib.meta.availableOn { inherit system; } p;

        isRecursivePkgs = p: builtins.isAttrs p && (p.recurseForDerivations or false);

        filterGoodPkgs = system: ps:
          let
            directPkgs = lib.filterAttrs (_: isGood system) ps;
            subSets = lib.filterAttrs (_: isRecursivePkgs) ps;
            filteredSubSets = lib.mapAttrs (_: subps: lib.recurseIntoAttrs (lib.filterAttrs (_: isGood system) subps)) subSets;
          in
          directPkgs // filteredSubSets;

        addEverything = system: pkgs: ps: ps // {
          build-everything-unsubstitutable =
            let
              goodPkgs = filterGoodPkgs system ps;
              directPkgs = lib.filterAttrs (_: v: !isRecursivePkgs v) goodPkgs;
              subSets = lib.filterAttrs (_: isRecursivePkgs) goodPkgs;
              directNames = lib.attrNames directPkgs;
              indirectNames = lib.concatMap lib.id (lib.attrValues (lib.mapAttrs (k: v: builtins.map (vv: k + "." + vv) (lib.attrNames (lib.removeAttrs v [ "recurseForDerivations" ]))) subSets));
              nameList = lib.concatMapStringsSep " " lib.escapeShellArg (directNames ++ indirectNames);
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

        finalPkgs = system: pkgs: filterGoodPkgs system (addEverything system pkgs (filterMyPkgs pkgs));

      in {

        packages = finalPkgs system pkgs;

        packagesCross = builtins.mapAttrs (arch: cpkgs: finalPkgs arch cpkgs) pkgs.pkgsCross;

      }
    ) // {

      overlays.default = overlay;

      homeModules.default = import ./home-modules;

      nixosModules.default = import ./nixos-modules { inherit overlay; };

    };
}
