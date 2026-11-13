{ lib, pkgs, config, ... }:

{
  options = {
    nic.hexcore-link.enable = lib.mkEnableOption "hexcore-link";
  };

  config = lib.mkIf config.nic.hexcore-link.enable {
    environment.systemPackages = [ pkgs.hexcore-link ];
    services.udev.extraRules = ''
      # For ANNE PRO
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5710", MODE="0660", GROUP="input"
      KERNEL=="hidraw*", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5710", MODE="0660", GROUP="input"
      # For ANNE PRO 2
      SUBSYSTEM=="usb", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="8008", MODE="0660", GROUP="input"
      KERNEL=="hidraw*", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="8008", MODE="0660", GROUP="input"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="8009", MODE="0660", GROUP="input"
      KERNEL=="hidraw*", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="8009", MODE="0660", GROUP="input"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="a292", MODE="0660", GROUP="input"
      KERNEL=="hidraw*", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="a292", MODE="0660", GROUP="input"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="a293", MODE="0660", GROUP="input"
      KERNEL=="hidraw*", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="a293", MODE="0660", GROUP="input"
      # For HEXCORE
      SUBSYSTEM=="usb", ATTRS{idVendor}=="3311", MODE="0660", GROUP="input"
      KERNEL=="hidraw*", ATTRS{idVendor}=="3311", MODE="0660", GROUP="input"
      # BLE
      KERNELS=="*:000D:F0E0.*" SUBSYSTEMS=="hid" DRIVERS=="hid-generic", MODE="0660", GROUP="input"
      KERNELS=="*:07D7:0000.*" SUBSYSTEMS=="hid" DRIVERS=="hid-generic", MODE="0660", GROUP="input"
    '';
  };
}
