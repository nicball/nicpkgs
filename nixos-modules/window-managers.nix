{ lib, pkgs, config, options, ... }:

let cfg = config.nic.window-managers; in

{
  imports = [
    ./sway.nix
    ./niri.nix
  ];

  options = {
    nic.window-managers = {
      enable = lib.mkEnableOption "window managers";
      scaling = {
        enable = lib.mkEnableOption "scaling";
        factor = lib.mkOption {
          type = lib.types.numbers.between 1 100;
          default = 1;
        };
        cursor = {
          enable = lib.mkEnableOption "scaling cursor";
          size = lib.mkOption {
            type = lib.types.number;
            default = 24;
          };
        };
      };
      x-resources.text = lib.mkOption {
        type = lib.types.nullOr lib.types.lines;
        description = "text of .Xresources";
      };
      x-resources.source = lib.mkOption {
        type = lib.types.path;
        description = "path of .Xresources";
      };
      cursor-theme = lib.mkOption {
        type = lib.types.str;
        default = "Adwaita";
      };
      cursor-size = lib.mkOption {
        type = lib.types.number;
        default = 24;
      };
      wallpaper = lib.mkOption {
        type = lib.types.path;
      };
    };
  };

  config = lib.mkIf cfg.enable
    (lib.mkMerge [

      ({
        # Do nothing when closing the lid with wall power
        services.logind.lidSwitchExternalPower = "ignore";

        nic.window-managers.x-resources.source = lib.mkIf (cfg.x-resources.text != null)
          (lib.mkDerivedConfig options.nic.window-managers.x-resources.text (pkgs.writeText ".Xresources"));

        environment.systemPackages = with pkgs; [
          pavucontrol swaylock
          swayimg adwaita-icon-theme nautilus glib
        ];

        nic.rofi-wayland.enable = true;

        nic.window-managers.x-resources.text = ''
          Xft.dpi: ${toString (builtins.ceil (96 * cfg.scaling.factor))}
          Xcursor.size: ${toString cfg.cursor-size}
        '';

        environment.variables = {
          XCURSOR_THEME = cfg.cursor-theme;
          XCURSOR_SIZE = cfg.cursor-size;
        };

      })

      (lib.mkIf cfg.scaling.enable {
        environment.variables = {
          # QT_WAYLAND_FORCE_DPI = toString (builtins.ceil (96 * cfg.scaling.factor));
          QT_AUTO_SCREEN_SCALE_FACTOR = 0;
          QT_ENABLE_HIGHDPI_SCALING = 0;
          QT_SCALE_FACTOR = toString cfg.scaling.factor;
        };
        nic.nicpkgs.scaling-factor = cfg.scaling.factor;
        programs.dconf.enable = true;
        programs.dconf.profiles.user.databases = [
          {
            settings = with lib.gvariant; {
              "org/gnome/desktop/interface" = {
                cursor-size = mkInt32 cfg.cursor-size;
                cursor-theme = mkString cfg.cursor-theme;
                text-scaling-factor = mkDouble cfg.scaling.factor;
              };
            };
          }
        ];
        nixpkgs.overlays = [ (self: super: { steam = super.steam.override { extraArgs = "-forcedesktopscaling ${toString cfg.scaling.factor}"; }; }) ];
        nic.window-managers.cursor-size = lib.mkIf cfg.scaling.cursor.enable (builtins.ceil (cfg.scaling.cursor.size * cfg.scaling.factor));
      })

    ]);
}
