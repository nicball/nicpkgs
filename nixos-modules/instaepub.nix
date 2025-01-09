{ config, pkgs, lib, ... }:

let

  cfg = config.nic.instaepub;

  package = pkgs.instaepub.override {
    inherit (cfg)
      consumer-key
      consumer-secret
      username
      password
      output-dir
      auto-archive
      enable-pandoc
      enable-instapaper
      pandoc;
  };

in

{

  options.nic.instaepub = {

    enable = lib.mkEnableOption "instaepub";

    consumer-key = lib.mkOption { type = lib.types.str; };

    consumer-secret = lib.mkOption { type = lib.types.str; };

    username = lib.mkOption { type = lib.types.str; };

    password = lib.mkOption { type = lib.types.str; };

    output-dir = lib.mkOption { type = lib.types.str; };

    auto-archive = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    enable-instapaper = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    enable-pandoc = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "daily";
    };

    pandoc = lib.mkOption {
      type = lib.types.package;
      default = pkgs.pandoc;
    };

  };

  config = lib.mkIf cfg.enable {

    systemd.services.instaepub = {
      description = "InstaEpub - Fetch your instapaper as epub";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${package}/bin/instaepub";
      };
    };

    systemd.timers.instaepub = {
      description = "InstaEpub - Fetch your instapaper as epub";
      timerConfig.OnCalendar = cfg.interval;
      wantedBy = [ "timers.target" ];
    };

  };

}
