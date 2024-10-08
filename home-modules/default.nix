{ overlay }:

{ lib, config, ... }:

{
  imports = [
    (import ./overlay.nix { inherit overlay; })
    ./cloudflare-ddns.nix
    ./instaepub.nix
    ./kakoune.nix
  ];

  options.nic.set-nix-path = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.nic.set-nix-path {
    home.sessionVariables.NIX_PATH = "nixpkgs=flake:nixpkgs";
  };
}
