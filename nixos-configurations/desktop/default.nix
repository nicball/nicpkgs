{ nixpkgs, nix-index-database }:

nixpkgs.lib.nixosSystem rec {
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ../../nixos-modules
    nix-index-database.nixosModules.nix-index
  ];
}
