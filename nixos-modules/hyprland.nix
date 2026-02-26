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
    nic.greetd.auto-login.start-command = "hyprland";
    nic.waybar.wm = "hyprland";
    programs.hyprland.enable = true;
    systemd.packages = [ pkgs.hyprpolkitagent ];
    environment.etc."xdg/hypr/land".source = with config.nic.window-managers; pkgs.replaceVars ./hyprland-config {
      sourceXrdb = lib.optionalString x-resources.enable ''exec-once = ${pkgs.xorg.xrdb}/bin/xrdb ${x-resources.source}'';
      cursorTheme = cursor-theme;
      cursorSize = cursor-size;
      inherit browser;
      hyprpaper = "${pkgs.hyprpaper}/bin/hyprpaper";
      swaylock = "${pkgs.swaylock}/bin/swaylock";
      playerctl = "${pkgs.playerctl}/bin/playerctl";
      wpctl = "${pkgs.wireplumber}/bin/wpctl";
      screenshot = "${pkgs.screenshot}/bin/screenshot";
      dex = "${pkgs.dex}/bin/dex";
      # keep these verbatim because '@' conflicts with replace
      DEFAULT_AUDIO_SINK = null;
      DEFAULT_AUDIO_SOURCE = null;
    };
    environment.etc."xdg/hypr/paper" = {
      enable = config.nic.window-managers.wallpaper.enable;
      source = with config.nic.window-managers; pkgs.replaceVars ./hyprpaper-config {
        wallpaper = wallpaper.source;
      };
    };
    nic.backlight.enable = true;
  };
}

