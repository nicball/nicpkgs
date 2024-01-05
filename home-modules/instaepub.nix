{ instaepub }:

{ config, pkgs, lib, ... }:

let

  cfg = config.services.instaepub;

  package = instaepub.override {
    inherit (cfg) consumer-key consumer-secret username password output-dir auto-archive pandoc;
  };

in

{

  options.services.instaepub = {

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

    systemd.user.services.instaepub = {
      Unit.Description = "InstaEpub - Fetch your instapaper as epub";
      Service = {
        Type = "oneshot";
        ExecStart = "${package}";
      };
    };

    systemd.user.timers.instaepub = {
      Unit.Description = "InstaEpub - Fetch your instapaper as epub";
      Timer.OnCalendar = cfg.interval;
      Install.WantedBy = [ "timers.target" ];
    };

  };

}
