{ lib, config, pkgs, ... }:

{
  options.nic.window-managers.niri = {
    enable = lib.mkEnableOption "niri";
  };

  config = lib.mkIf config.nic.window-managers.niri.enable {
    nic.greetd.auto-login.start-command = "niri-session";
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gnome xdg-desktop-portal-gtk gnome-keyring ];
      configPackages = [ pkgs.niri ];
    };
    environment.systemPackages = with pkgs; [ niri xwayland-satellite ];
    environment.variables.NIRI_CONFIG = with config.nic.window-managers; pkgs.substituteAll {
      src = ./niri-config.kdl;
      cursorTheme = cursor-theme;
      cursorSize = cursor-size;
      playerctl = "${pkgs.playerctl}/bin/playerctl";
      wpctl = "${pkgs.wireplumber}/bin/wpctl";
      inherit browser;
    };

    systemd.user.services.swaybg = {
      enable = config.nic.window-managers.wallpaper.enable;
      wantedBy = [ "niri.service" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      requisite = [ "graphical-session.target" ];
      description = "Desktop wallpaper";
      serviceConfig = {
        ExecStart = "${pkgs.swaybg}/bin/swaybg -o '*' -i ${config.nic.window-managers.wallpaper.source} -m stretch";
        Restart = "on-failure";
      };
    };

    systemd.packages = [ pkgs.xwayland-satellite ];
    systemd.user.services.xwayland-satellite.wantedBy = [ "niri.service" ];

    systemd.user.services.xrdb = {
      enable = config.nic.window-managers.x-resources.enable;
      wantedBy = [ "xwayland-satellite.service" ];
      partOf = [ "xwayland-satellite.service" ];
      after = [ "xwayland-satellite.service" ];
      requisite = [ "xwayland-satellite.service" ];
      description = "Xresources";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/usr/bin/env 'DISPLAY=:0' ${pkgs.xorg.xrdb}/bin/xrdb ${config.nic.window-managers.x-resources.source}";
      };
    };
  };
}
