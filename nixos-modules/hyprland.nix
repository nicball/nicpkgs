{ lib, config, pkgs, ... }:

let

  cfg = config.nic.window-managers.hyprland;

  graphical-session-packages = packages: {
    packages = lib.forEach packages (name: pkgs.${name});
    user.services = builtins.listToAttrs (lib.forEach packages (name: lib.nameValuePair name {
      wantedBy = [ "graphical-session.target" ];
    }));
  };

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
    environment.systemPackages = with pkgs; [ hyprlock ];
    systemd = graphical-session-packages [ "hyprpolkitagent" "hyprpaper" "hypridle" ];
    environment.etc = {
      "xdg/hypr/hyprland.conf".source = with config.nic.window-managers; pkgs.replaceVars ./hyprland-config {
        sourceXrdb = lib.optionalString x-resources.enable ''exec-once = ${pkgs.xrdb}/bin/xrdb ${x-resources.source}'';
        inherit browser;
        playerctl = "${pkgs.playerctl}/bin/playerctl";
        wpctl = "${pkgs.wireplumber}/bin/wpctl";
        screenshot = "${pkgs.screenshot}/bin/screenshot";
        # keep these verbatim because '@' conflicts with replace
        DEFAULT_AUDIO_SINK = null;
        DEFAULT_AUDIO_SOURCE = null;
      };
      "xdg/hypr/hyprpaper.conf" = {
        enable = config.nic.window-managers.wallpaper.enable;
        text = with config.nic.window-managers; ''
          wallpaper {
            monitor =
            path = ${wallpaper.source}
          }
        '';
      };
      "xdg/hypr/hyprlock.conf".text = with config.nic.window-managers; ''
        $font = monospace
        animations {
            enabled = true
            bezier = linear, 1, 1, 0, 0
            animation = fadeIn, 1, 5, linear
            animation = fadeOut, 1, 5, linear
            animation = inputFieldDots, 1, 2, linear
        }
        ${lib.optionalString wallpaper.enable ''
        background {
            monitor =
            path = ${wallpaper.source}
            blur_passes = 3
        }
        ''}
        input-field {
          monitor =
          size = 20%, 5%
          outline_thickness = 3
          inner_color = rgba(0, 0, 0, 0.0) # no fill
          outer_color = rgba(33ccffee) rgba(00ff99ee) 45deg
          check_color = rgba(00ff99ee) rgba(ff6633ee) 120deg
          fail_color = rgba(ff6633ee) rgba(ff0066ee) 40deg
          font_color = rgb(143, 143, 143)
          fade_on_empty = false
          rounding = 15
          font_family = $font
          placeholder_text = Input password...
          fail_text = $PAMFAIL
          dots_spacing = 0.3
          position = 0, -20
          halign = center
          valign = center
        }
        label { # TIME
            monitor =
            text = $TIME
            font_size = 90
            font_family = $font
            position = -30, 0
            halign = right
            valign = top
        }
        label { # DATE
            monitor =
            text = cmd[update:60000] date +"%A, %d %B %Y"
            font_size = 25
            font_family = $font
            position = -30, -150
            halign = right
            valign = top
        }
      '';
      "xdg/hypr/hypridle.conf".text = ''
        general {
          lock_cmd = pidof hyprlock || hyprlock
          before_sleep_cmd = loginctl lock-session
        }
        listener {
          timeout = 300
          on-timeout = loginctl lock-session
        }
      '';
    };
    nic.backlight.enable = true;
  };
}

