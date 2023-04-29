{ cloudflare-ddns }:

{ config, pkgs, lib, ... }:

let

  cfg = config.services.cloudflare-ddns;

  package = with cfg; cloudflare-ddns.override {
    authKey = auth-key;
    authEmail = auth-email;
    zoneName = zone-name;
    recordName = record-name;
    log = log;
  };

in

{

  options.services.cloudflare-ddns = {

    enable = lib.mkEnableOption "cloudflare-ddns";

    auth-key = lib.mkOption { type = lib.types.str; };

    auth-email = lib.mkOption { type = lib.types.str; };

    zone-name = lib.mkOption { type = lib.types.str; };

    record-name = lib.mkOption { type = lib.types.str; };

    log = lib.mkOption {
      type = lib.types.str;
      default = "";
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "hourly";
    };

  };

  config = lib.mkIf cfg.enable {

    systemd.user.services.cloudflare-ddns = {
      Unit.Description = "Cloudflare DNS Updater";
      Service = {
        Type = "oneshot";
        ExecStart = "${package}/bin/cloudflare-ddns";
      };
    };

    systemd.user.timers.cloudflare-ddns = {
      Unit.Description = "Cloudflare DNS Updater";
      Timer.OnCalendar = cfg.interval;
      Install.WantedBy = [ "timers.target" ];
    };

  };

}

