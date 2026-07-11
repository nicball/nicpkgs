{ overlay }:

{ lib, config, ... }:

{
  imports = [
    (import ./overlay.nix { inherit overlay; })
    ./window-managers.nix
    ./waybar.nix
    ./greetd.nix
    ./kitty.nix
    ./dunst.nix
    ./rofi.nix
    ./kakoune.nix
    ./backlight.nix
    ./hexcore-link.nix
    ./cloudflare-ddns.nix
    ./instaepub.nix
    ./fish.nix
    ./clash.nix
    ./amd.nix
  ];

  options.nic = {
    set-nix-path = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    cachix = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.nic.set-nix-path {
      nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];
      nixpkgs.flake = {
        setFlakeRegistry = false;
        setNixPath = false;
      };
    })
    (lib.mkIf config.nic.cachix {
      nix.settings = {
        substituters = [ "https://nicpkgs.cachix.org" ];
        trusted-public-keys = [ "nicpkgs.cachix.org-1:OTCMJ8lLYwhnDhlkP0huok3hOnxV3u/YVDH9M0kPLqM=" ];
      };
    })
  ];
}
