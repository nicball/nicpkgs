{ lib, pkgs, config, ... }:

{
  options = {
    nic.backlight = {
      enable = lib.mkEnableOption "backlight";
      group = lib.mkOption {
        type = lib.types.str;
        default = "video";
      };
    };
  };

  config = lib.mkIf config.nic.backlight.enable {
    environment.systemPackages = [ pkgs.acpilight ];
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp ${config.nic.backlight.group} /sys/class/backlight/%k/brightness"
      ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
    '';
  };
}

