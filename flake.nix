{
  description = "Nicball's package collection";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/cf3f5c4def3c7b5f1fc012b3d839575dbe552d43";
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

        filter-pkgset-recursive = f: attrs:
          let go = f: prefixes: attrs:
            let first-level = lib.filterAttrs (k: v: k == "recurseForDerivations" || f (prefixes ++ [ k ]) v) attrs; in
            lib.mapAttrs (k: v: if is-recursive-pkgs v then go f (prefixes ++ [ k ]) v else v) first-level;
          in
          go f [] attrs;

        get-paths-recursive = ps:
          let
            flatten = prefix: ps:
              lib.concatMapAttrs
                (k: v:
                  if k == "recurseForDerivations" then
                    {}
                  else if is-recursive-pkgs v then
                    flatten "${prefix}.${k}" v
                  else
                    { "${prefix}.${k}" = v; })
                ps;
          in
          builtins.map (lib.removePrefix ".") (builtins.attrNames (flatten "" ps));

        filter-my-pkgs = ps:
          let
            skeleton = overlay dummy-pkgs {};
            dummy-pkgs = {
              lib = { inherit (lib) recurseIntoAttrs; };
              callPackage = fnOrPath: additionalArgs:
                let
                  fn = if builtins.isPath fnOrPath then import fnOrPath else fnOrPath;
                  args = lib.mapAttrs (k: v: dummy-pkgs.${k} or 42) (lib.functionArgs fn) // additionalArgs;
                in
                fn args;
            };
          in
          filter-pkgset-recursive (path: _: lib.hasAttrByPath path skeleton) ps;

        is-broken = lib.attrByPath [ "meta" "broken" ] false;

        is-good = system: p: lib.isDerivation p && !is-broken p && lib.meta.availableOn { inherit system; } p;

        is-recursive-pkgs = p: builtins.isAttrs p && (p.recurseForDerivations or false);

        filter-good-pkgs = system: ps: filter-pkgset-recursive (_: p: is-recursive-pkgs p || is-good system p) ps;

        add-push-to-cachix = system: pkgs: ps: ps // {
          push-to-cachix =
            let
              good-pkgs = filter-good-pkgs system ps;
              nameList = lib.concatMapStringsSep " " lib.escapeShellArg (get-paths-recursive good-pkgs);
            in
            pkgs.writeShellApplication {
              name = "push-to-cachix";
              runtimeInputs = with pkgs; [ jq nix ];
              text = ''
                bincache=''${1:?"Please tell me which binary cache to check."}
                cachixname=''${2:?"Please tell me which cachix to push to."}
                for name in ${nameList}; do
                  path=$(nix path-info --json .#"$name"^out 2>/dev/null | jq -r 'keys[]')
                  if nix path-info "$path" --store "$bincache" >/dev/null 2>&1; then
                    echo "$name already exists, skipping..."
                  else
                    echo "Building $name..."
                    nix build .#"$name"
                    nix path-info --recursive "$path" | cachix push "$cachixname"
                  fi
                done
              '';
            };
        };

        final-pkgs = system: pkgs: filter-good-pkgs system (add-push-to-cachix system pkgs (filter-my-pkgs pkgs));

      in {

        packages = final-pkgs system pkgs;

        packagesCross = builtins.mapAttrs (arch: cpkgs: final-pkgs arch cpkgs) pkgs.pkgsCross;

      }
    ) // {

      overlays.default = overlay;

      homeModules.default = import ./home-modules { inherit overlay; };

      nixosModules.default = import ./nixos-modules { inherit overlay; };

    };
}
