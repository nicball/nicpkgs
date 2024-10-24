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
    ./rofi-wayland.nix
    ./kakoune.nix
    ./backlight.nix
    ./hexcore-link.nix
    ./cloudflare-ddns.nix
    ./instaepub.nix
  ];

  options.nic.set-nix-path = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.nic.set-nix-path {
    nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];
    nixpkgs.flake = {
      setFlakeRegistry = false;
      setNixPath = false;
    };
  };
}
