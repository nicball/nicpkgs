{ lib, pkgs, config, ... }:

let

  cfg = config.nic.clash;

  exe = pkgs.writeShellScript "clash.sh" ''
    if [[ ! -e clash.yaml ]]; then
      cp $CREDENTIALS_DIRECTORY/clash.yaml.xz .
      ${pkgs.xz}/bin/xz -d clash.yaml.xz
    fi
    exec ${pkgs.clash-meta}/bin/clash-meta -f ./clash.yaml -d /var/lib/clash
  '';

in

{
  options.nic.clash = {
    enable = lib.mkEnableOption "clash";
    config-path = lib.mkOption {
      type = lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.clash = {
      description = "Clash Proxy Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];
      serviceConfig = {
        ExecStart = exe;
        StateDirectory = "clash";
        WorkingDirectory = "/var/lib/clash";
        DynamicUser = true;
        LoadCredential = "clash.yaml.xz:${cfg.config-path}";
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        # PrivateUsers = true;
        ProtectClock = true;
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

