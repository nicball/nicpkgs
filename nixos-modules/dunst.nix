{ lib, pkgs, config, ... }:

{
  options = {
    nic.dunst = {
      enable = lib.mkEnableOption "dunst";
    };
  };

  config = lib.mkIf config.nic.dunst.enable {
    environment.systemPackages = [ pkgs.dunst ];
    environment.etc."xdg/dunst/dunstrc".source =
      let scale = x: toString (builtins.ceil (config.nic.window-managers.scaling.factor * x)); in
      pkgs.substituteAll {
        src = ./dunst-config;
        width = scale 300;
        height = scale 300;
        fontSize = scale 12;
        minIconSize = scale 36;
      };
  };
}

