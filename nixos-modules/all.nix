{ overlay }:

{ lib, config, ... }:

{

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
        scale-factor = lib.mkOption {
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
        (self: super: { nicpkgs-scale = config.nic.nicpkgs.scale-factor; })
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
