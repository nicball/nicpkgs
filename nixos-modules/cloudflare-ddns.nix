{ config, pkgs, lib, ... }:

let

  cfg = config.nic.cloudflare-ddns;

  package = with cfg; pkgs.cloudflare-ddns.override {
    inherit auth-key auth-email zone-name record-name enable-log log-path enable-ipv4 enable-ipv6;
  };

in

{

  options.nic.cloudflare-ddns = {

    enable = lib.mkEnableOption "cloudflare-ddns";

    auth-key = lib.mkOption { type = lib.types.str; };

    auth-email = lib.mkOption { type = lib.types.str; };

    zone-name = lib.mkOption { type = lib.types.str; };

    record-name = lib.mkOption { type = lib.types.str; };

    enable-log = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    log-path = lib.mkOption {
      type = lib.types.str;
      default = "";
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "hourly";
    };

    enable-ipv4 = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    enable-ipv6 = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

  };

  config = lib.mkIf cfg.enable {

    systemd.services.cloudflare-ddns = {
      description = "Cloudflare DNS Updater";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${package}/bin/cloudflare-ddns";
      };
    };

    systemd.timers.cloudflare-ddns = {
      description = "Cloudflare DNS Updater";
      timerConfig.OnCalendar = cfg.interval;
      wantedBy = [ "timers.target" ];
    };

  };

}

