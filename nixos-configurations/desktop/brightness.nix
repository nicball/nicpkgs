{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.ddcutil ];
  boot.kernelModules = [ "i2c-dev" ];
  services.udev.extraRules = ''
    KERNEL=="i2c-*", SUBSYSTEM=="i2c-dev", ATTR{name}=="AMDGPU*", MODE="0660", GROUP="video"
  '';
}
