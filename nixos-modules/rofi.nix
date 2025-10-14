{ lib, pkgs, config, ... }:

{
  options = {
    nic.rofi = {
      enable = lib.mkEnableOption "rofi";
    };
  };

  config = lib.mkIf config.nic.rofi.enable {
    environment.systemPackages = [ pkgs.rofi ];
    environment.etc."xdg/rofi.rasi".source = pkgs.replaceVars ./rofi-config.rasi {
      themefile = pkgs.replaceVars ./rofi-theme.rasi {
        fontSize = builtins.ceil (12 * config.nic.window-managers.scaling.factor);
      };
    };
  };
}

