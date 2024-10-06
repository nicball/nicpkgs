{ lib, config, pkgs, ... }:

{
  options = {
    nic.window-managers.sway = {
      enable = lib.mkEnableOption "sway";
    };
  };

  config = lib.mkIf config.nic.window-managers.sway.enable {
    nic.greetd.start-command = "sway";
    programs.sway = {
      enable = true;
      package = pkgs.swayfx;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [ screenshot dex xorg.xrdb ];
    };
    nic.waybar.enable = true;
    xdg.portal.wlr.enable = true;
    environment.etc."sway/config".source = with config.nic.window-managers; pkgs.substituteAll {
      src = ./sway-config;
      inherit wallpaper;
      xresources = x-resources.source;
      cursorTheme = cursor-theme;
      cursorSize = cursor-size;
    };
  };
}
