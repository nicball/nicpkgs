{ lib, pkgs, config, ... }:

{
  options = {
    nic.kitty = {
      enable = lib.mkEnableOption "kitty";
    };
  };

  config = lib.mkIf config.nic.kitty.enable {
    environment.systemPackages = [ pkgs.kitty ];
    environment.etc."xdg/kitty/kitty.conf".source = pkgs.replaceVars ./kitty.conf {
      fontSize = builtins.ceil (12 * config.nic.window-managers.scaling.factor);
    };
  };
}

