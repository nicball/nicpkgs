{ lib, config, pkgs, ... }:

{
  options = {
    nic.window-managers.sway = {
      enable = lib.mkEnableOption "sway";
    };
  };

  config = lib.mkIf config.nic.window-managers.sway.enable {
    nic.greetd.auto-login.start-command = "sway";
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
      setWallpaper = lib.optionalString wallpaper.enable ''background ${wallpaper.source} stretch'';
      sourceXrdb = lib.optionalString x-resources.enable ''exec_always "${pkgs.xorg.xrdb}/bin/xrdb ${x-resources.source}"'';
      cursorTheme = cursor-theme;
      cursorSize = cursor-size;
    };
  };
}
