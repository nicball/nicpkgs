{ lib, pkgs, config, ... }:

{
  options = {
    nic.rofi-wayland = {
      enable = lib.mkEnableOption "rofi-wayland";
    };
  };

  config = lib.mkIf config.nic.rofi-wayland.enable {
    environment.systemPackages = [ pkgs.rofi-wayland ];
    environment.etc."xdg/rofi.rasi".source = pkgs.substituteAll {
      src = ./rofi-config.rasi;
      themefile = pkgs.substituteAll {
        src = ./rofi-theme.rasi;
        fontSize = builtins.ceil (12 * config.nic.window-managers.scaling.factor);
      };
    };
  };
}

