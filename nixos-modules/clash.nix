{ lib, pkgs, config, ... }:

let cfg = config.nic.clash; in

{
  options.nic.clash = {
    enable = lib.mkEnableOption "clash";
    config.source = lib.mkOption {
      type = lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.clash = {
      description = "Clash Daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.clash-meta}/bin/clash-meta -f ${cfg.config.source} -d /var/lib/clash";
        StateDirectory = "clash";
        WorkingDirectory = "/var/lib/clash";
        DynamicUser = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        PrivateClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";
        SystemCallFilter = [ "@system-service" "~@mount" ];
      };
    };

    networking.proxy = {
      httpProxy = "http://127.0.0.1:7890";
      httpsProxy = "http://127.0.0.1:7890";
      noProxy = "127.0.0.1,localhost";
    };
  };
}

