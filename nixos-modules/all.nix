{ overlay }:

{ lib, config, ... }:

{
  imports = [
    ./window-managers.nix
    ./waybar.nix
    ./greetd.nix
    ./kitty.nix
    ./dunst.nix
    ./rofi-wayland.nix
  ];

  options = {
    nic = {
      set-nix-path = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      nicpkgs = {
        enable-overlay = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        scaling-factor = lib.mkOption {
          type = lib.types.number;
          default = 1;
        };
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.nic.nicpkgs.enable-overlay {
      nixpkgs.overlays = [
        overlay
        (self: super: { nicpkgs-scaling = config.nic.nicpkgs.scaling-factor; })
      ];
    })
    (lib.mkIf config.nic.set-nix-path {
      nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];
      nixpkgs.flake = {
        setFlakeRegistry = false;
        setNixPath = false;
      };
    })
  ];

}
