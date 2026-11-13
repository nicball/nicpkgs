{ lib, pkgs, config, ... }:

{
  options = {
    nic.keychron.enable = lib.mkEnableOption "keychron";
  };

  config = lib.mkIf config.nic.keychron.enable {
    services.udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", MODE="0660", GROUP="input"
      KERNEL=="event*", SUBSYSTEM=="input", ENV{ID_VENDOR_ID}=="3434", ENV{ID_INPUT_JOYSTICK}=="*?", ENV{ID_INPUT_JOYSTICK}=""
    '';
  };
}

