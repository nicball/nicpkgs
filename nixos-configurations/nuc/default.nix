{ inputs, nicpkgs }:

inputs.nixpkgs.lib.nixosSystem rec {
  system = "x86_64-linux";
  modules = [
    nicpkgs.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index
    ({ ... }: { nixpkgs.overlays = [ (_: _: { instaepub = inputs.instaepub.packages.x86_64-linux.instaepub;  }) ]; })
    ./hardware-configuration.nix
    ./desktop.nix
    ./services.nix
    ./intel.nix
    ../common.nix
    ({ ... }: { networking.hostName = "nixos-nuc"; })
  ];
}
