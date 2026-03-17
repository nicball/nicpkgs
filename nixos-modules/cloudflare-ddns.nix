{ config, pkgs, lib, ... }:

let

  cfg = config.nic.cloudflare-ddns;

in

{

  options.nic.cloudflare-ddns = {

    enable = lib.mkEnableOption "cloudflare-ddns";

    auth-token = lib.mkOption { type = lib.types.str; };

    zone-name = lib.mkOption { type = lib.types.str; };

    record-name = lib.mkOption { type = lib.types.str; };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "hourly";
    };

  };

  config = lib.mkIf cfg.enable {

    systemd.services.cloudflare-ddns = {
      description = "Cloudflare DNS Updater";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.cloudflare-ddns}/bin/cloudflare-ddns";
      };
      environment = {
        CF_AUTH_TOKEN = cfg.auth-token;
        CF_ZONE = cfg.zone-name;
        CF_RECORD = cfg.record-name;
      };
    };

    systemd.timers.cloudflare-ddns = {
      description = "Cloudflare DNS Updater";
      timerConfig.OnCalendar = cfg.interval;
      wantedBy = [ "timers.target" ];
    };

  };

}

