{ overlay }:

{ lib, config, ... }:

{
  options.nic.nicpkgs = {
    enable-overlay = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    scaling-factor = lib.mkOption {
      type = lib.types.number;
      default = 1;
    };
  };

  config = lib.mkIf config.nic.nicpkgs.enable-overlay {
    nixpkgs.overlays = [
      overlay
      (self: super: { nicpkgs-scaling = config.nic.nicpkgs.scaling-factor; })
    ];
  };
}
