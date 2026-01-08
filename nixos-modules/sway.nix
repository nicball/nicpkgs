{ lib, config, pkgs, ... }:

let
  cfg = config.nic.window-managers.sway;

  swayexec = pkgs.writeShellApplication {
    name = "swayexec";
    text = builtins.readFile ./swayexec.sh;
  };
in

{
  options = {
    nic.window-managers.sway = {
      enable = lib.mkEnableOption "sway";
      use-swayfx = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    nic.greetd.auto-login.start-command = "sway";
    programs.sway = {
      enable = true;
      package = if cfg.use-swayfx then pkgs.swayfx else pkgs.sway;
      wrapperFeatures.gtk = true;
      extraPackages = [];
    };
    xdg.portal.wlr.enable = true;
    environment.etc."sway/config".source = with config.nic.window-managers; pkgs.replaceVars ./sway-config {
      setWallpaper = lib.optionalString wallpaper.enable ''background ${wallpaper.source} fill'';
      sourceXrdb = lib.optionalString x-resources.enable ''exec_always "${pkgs.xorg.xrdb}/bin/xrdb ${x-resources.source}"'';
      cursorTheme = cursor-theme;
      cursorSize = cursor-size;
      swayfxConfig = lib.optionalString cfg.use-swayfx (builtins.readFile ./swayfx-config);
      inherit browser;
      playerctl = "${pkgs.playerctl}/bin/playerctl";
      wpctl = "${pkgs.wireplumber}/bin/wpctl";
      swayexec = "${swayexec}/bin/swayexec";
      screenshot = "${pkgs.screenshot}/bin/screenshot";
      dex = "${pkgs.dex}/bin/dex";
      # keep these verbatim because '@' conflicts with replace
      DEFAULT_AUDIO_SINK = null;
      DEFAULT_AUDIO_SOURCE = null;
    };
    nic.backlight.enable = true;
  };
}
