{ overlay }:

{ lib, config, ... }:

{

  options = {
    nic = {
      scale-factor = lib.mkOption {
        type = lib.types.number;
        default = 1;
      };
      enable-overlay = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      set-nix-path = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      overlay = lib.mkOption {
        type = lib.types.anything;
        default = overlay;
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.nic.enable-overlay {
      nixpkgs.overlays = [
        # config.nic.overlay
        overlay
        (self: super: { nicpkgs-scale = config.nic.scale-factor; })
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
