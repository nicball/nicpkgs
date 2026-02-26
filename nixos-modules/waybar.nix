{ lib, pkgs, config, ... }:

{
  options = {
    nic.waybar = {
      enable = lib.mkEnableOption "waybar";
      wm = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
      };
    };
  };

  config =
    lib.mkIf config.nic.waybar.enable {
      programs.waybar.enable = true;
      environment.etc."xdg/waybar/config.jsonc".source = pkgs.replaceVars ./waybar-config.json {
        wm = config.nic.waybar.wm;
        xbacklight = "${pkgs.acpilight}/bin/xbacklight";
        pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
        rfkill = "${pkgs.util-linux}/bin/rfkill";
      };
      environment.etc."xdg/waybar/style.css".source = ./waybar-style.css;
    };
}
