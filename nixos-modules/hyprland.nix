{ lib, config, pkgs, ... }:

let
  cfg = config.nic.window-managers.hyprland;
in

{
  options = {
    nic.window-managers.hyprland = {
      enable = lib.mkEnableOption "hyprland";
    };
  };

  config = lib.mkIf cfg.enable {
    nic.greetd.auto-login.start-command = "uwsm start hyprland-uwsm.desktop";
    nic.waybar.wm = "hyprland";
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };
    systemd = {
      packages = with pkgs; [ hyprpolkitagent hyprpaper ];
      user.services = {
        hyprpolkitagent.wantedBy = [ "graphical-session.target" ];
        hyprpaper.wantedBy = [ "graphical-session.target" ];
      };
    };
    environment.etc."xdg/hypr/land".source = with config.nic.window-managers; pkgs.replaceVars ./hyprland-config {
      sourceXrdb = lib.optionalString x-resources.enable ''exec-once = ${pkgs.xrdb}/bin/xrdb ${x-resources.source}'';
      inherit browser;
      swaylock = "${pkgs.swaylock}/bin/swaylock";
      playerctl = "${pkgs.playerctl}/bin/playerctl";
      wpctl = "${pkgs.wireplumber}/bin/wpctl";
      screenshot = "${pkgs.screenshot}/bin/screenshot";
      # keep these verbatim because '@' conflicts with replace
      DEFAULT_AUDIO_SINK = null;
      DEFAULT_AUDIO_SOURCE = null;
    };
    environment.etc."xdg/hypr/paper" = {
      enable = config.nic.window-managers.wallpaper.enable;
      source = with config.nic.window-managers; pkgs.replaceVars ./hyprpaper-config {
        wallpaper = "${wallpaper.source}";
      };
    };
    nic.backlight.enable = true;
  };
}

