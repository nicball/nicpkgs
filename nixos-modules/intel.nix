{ lib, pkgs, config, ... }:

let cfg = config.nic.intel; in

{
  options.nic.intel = {
    gpu.enable = lib.mkEnableOption "Intel GPU";
  };

  config = lib.mkIf cfg.gpu.enable {
    hardware.graphics.extraPackages = with pkgs; [ intel-media-driver intel-compute-runtime-legacy1 ];
    environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
    environment.systemPackages = with pkgs; [ intel-gpu-tools ];
  };
}
