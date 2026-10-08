{ inputs, nicpkgs }:

inputs.nixpkgs.lib.nixosSystem rec {
  system = "x86_64-linux";
  modules = [
    nicpkgs.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index
    inputs.agenix.nixosModules.default
    ../common.nix
    ./hardware-configuration.nix
    ./amd.nix
    ./desktop.nix
    ./network.nix
    ./brightness.nix
    # ./osx.nix
    ({ ... }: { age.identityPaths = [ "/home/nicball/.ssh/id_ed25519" ]; })
  ];
}
