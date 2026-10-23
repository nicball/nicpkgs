let inherit (<nicpkgs>) inputs; in

inputs.nixpkgs.lib.nixosSystem rec {
  system = "x86_64-linux";
  modules = [
    <nicpkgs>.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index
    inputs.agenix.nixosModules.default
    ./hardware-configuration.nix
    ./desktop.nix
    ./services.nix
    ./intel.nix
    ../common.nix
    ({ ... }: { networking.hostName = "nixos-nuc"; })
  ];
}
