{ lib, pkgs, config, ... }:

{
  options = {
    nic.waybar = {
      enable = lib.mkEnableOption "waybar";
      wm = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
    };
  };

  config =
    let
      wm = if config.nic.waybar.wm != null then config.nic.waybar.wm else
        (if config.nic.window-managers.niri.enable
          then "niri"
          else if config.nic.window-managers.sway.enable
            then "sway"
            else throw "waybar: unsupported wm");
    in
    lib.mkIf config.nic.waybar.enable {
      programs.waybar.enable = true;
      environment.etc."xdg/waybar/config.jsonc".source = pkgs.replaceVars ./waybar-config.json {
        inherit wm;
        xbacklight = "${pkgs.acpilight}/bin/xbacklight";
        pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
        rfkill = "${pkgs.util-linux}/bin/rfkill";
      };
      environment.etc."xdg/waybar/style.css".source = ./waybar-style.css;
    };
}
