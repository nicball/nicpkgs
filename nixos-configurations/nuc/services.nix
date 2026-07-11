{ config, pkgs, lib, ... }:

let
  sandboxing-config = {
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateTmp = true;
    PrivateUsers = true;
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

  make-service = { sandboxing ? true, dir ? null, dynamic-user ? true, proxy ? false, ... }@args:
    let
      merge = lib.foldl' lib.recursiveUpdate {};
      passthru = lib.filterAttrs (k: v: !builtins.hasAttr k (lib.functionArgs make-service)) args;
    in
    merge [
      (lib.optionalAttrs sandboxing {
        serviceConfig = sandboxing-config;
      })
      (lib.optionalAttrs dynamic-user {
        serviceConfig.DynamicUser = true;
      })
      (lib.optionalAttrs (dir != null) {
        serviceConfig = {
          StateDirectory = dir;
          WorkingDirectory = "/var/lib/" + dir;
        };
      })
      (lib.optionalAttrs proxy {
        environment = config.networking.proxy.envVars;
      })
      ({
        serviceConfig.Restart = "always";
        wantedBy = [ "multi-user.target" ];
      })
      passthru
    ];

in

{
  # imports = [ ./factorio.nix ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  nic.clash = {
    enable = true;
    config.source = ./private/clash.yaml;
  };

  users.users.nicball.extraGroups = [ "www" ];

  systemd.services.mautrix-telegram = make-service {
    description = "Mautrix Telegram Bridge";
    dir = "mautrix-telegram";
    proxy = true;
    after = [ "synapse.service" ];
    partOf = [ "synapse.service" ];
    requires = [ "synapse.service" ];
    serviceConfig.ExecStart = "${pkgs.mautrix-telegram}/bin/mautrix-telegram";
  };
  nixpkgs.config.permittedInsecurePackages = [ "olm-3.2.16" ];

  # systemd.user.services.matrix-qq = {
  #   Unit = {
  #     Description = "Mautrix Telegram Bridge";
  #     After = [ "synapse.service" "qsign.service" ];
  #     PartOf = [ "synapse.service" ];
  #     Requires = [ "synapse.service" "qsign.service" ];
  #   };
  #   serviceConfig = {
  #     ExecStart = "${pkgs.matrix-qq}/bin/matrix-qq";
  #     WorkingDirectory = "${config.home.homeDirectory + "/matrix-qq"}";
  #   };
  #   Install.WantedBy = [ "default.target" ];
  # };

  # systemd.user.services.qsign = {
  #   Unit = {
  #     Description = "QQ signing server";
  #     PartOf = [ "matrix-qq.service" ];
  #   };
  #   serviceConfig = {
  #     ExecStart = "${pkgs.jre}/bin/java -jar ./unidbg-fetch-qsign-1.2.1-all.jar --basePath=./txlib/8.9.63";
  #     WorkingDirectory = config.home.homeDirectory + "/qsign";
  #   };
  # };

  systemd.services.synapse = make-service {
    description = "Synapse Matrix Home Server";
    dir = "synapse";
    proxy = true;
    after = [ "network.target" ];
    serviceConfig = {
      MemoryDenyWriteExecute = false;
      ExecStart =
        "${pkgs.matrix-synapse}/bin/synapse_homeserver -c homeserver.yaml";
    };
  };

  # systemd.user.services.minecraft = {
  #   description = "Minecraft Server";
  #   serviceConfig = {
  #     Type = "oneshot";
  #     WorkingDirectory = "${config.home.homeDirectory + "/mc"}";
  #     ExecStart = "${pkgs.tmux}/bin/tmux new -s minecraft -d '${pkgs.jre_headless}/bin/java -Dhttp.proxyHost=127.0.0.1 -Dhttp.proxyPort=7890 -Dhttps.proxyHost=127.0.0.1 -Dhttps.proxyPort=7890 -Xmx3072M -jar ./fabric*.jar nogui'";
  #     ExecStop = "${pkgs.tmux}/bin/tmux kill-session -t minecraft";
  #     RemainAfterExit = true;
  #   };
  #   Install.WantedBy = [ "default.target" ];
  # };

  # systemd.user.services.frpc = {
  #   description = "Fast Reverse Proxy Client";
  #   Service.ExecStart = "${pkgs.frp}/bin/frpc -c ${./private/frpc.ini}";
  #   Install.WantedBy = [ "default.target" ];
  # };

  systemd.services.cloudflared = make-service {
    description = "Cloudflare Argo Tunnel";
    dir = "cloudflared";
    after = [ "network.target" ];
    serviceConfig.ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token ${import ./private/cloudflared-token.nix}";
  };

  systemd.services.caddy =
    let configFile = pkgs.writeText "caddy-config" ''
      {
        skip_install_trust
      }
      flake.run, :80 {
        reverse_proxy /jsonrpc http://localhost:6800
        file_server * browse {
          root /srv/www
          hide .*
        }
      }
      m.flake.run {
        reverse_proxy http://localhost:8008
      }
      instaepub.flake.run {
        reverse_proxy http://localhost:8086
      }
      bw.flake.run {
        reverse_proxy http://localhost:8000
      }
      owncast.flake.run {
        reverse_proxy http://localhost:8082
      }
      ping.flake.run {
        header {
          Cache-Control no-store
        }
        respond "Pong!"
      }
    '';
    in make-service {
      description = "Caddy HTTP Server";
      dir = "caddy";
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.caddy}/bin/caddy run --adapter caddyfile --config ${configFile}";
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        PrivateUsers = false;
      };
      environment.XDG_DATA_HOME = "/var/lib";
    };
  users.users.caddy = {
    isSystemUser = true;
    group = "caddy";
  };
  users.groups.caddy = {};

  # systemd.user.services.transfersh = {
  #   description = "Easy and fast file sharing from the command-line";
  #   serviceConfig = {
  #     ExecStart = "${pkg.tranfersh}/bin/transfer.sh";
  #     Environment = [
  #       "LISTENER=:8081"
  #       "TEMP_PATH=/tmp/"
  #       "PROVIDER=local"
  #       "BASEDIR=${config.home.homeDirectory + "/transfersh"}"
  #       "LOG=${config.home.homeDirectory + "/transfersh/.log"}"
  #     ];
  #   };
  #   Install.WantedBy = [ "default.target" ];
  # };

  nic.cloudflare-ddns = {
    enable = true;
  } // import ./private/cloudflare-ddns.nix;

  systemd.services.aria2d =
    let
      dir = "/srv/www/files";
      update-trackers = pkgs.writeShellScript "update-trackers.sh" ''
        set -o pipefail
        export https_proxy="${config.networking.proxy.httpsProxy}"
        PATH="${pkgs.curl}/bin:$PATH"
        url="https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_best.txt"
        if curl --no-progress-meter "$url" | sed '/^$/d' | tr '\n' ',' > ${dir}/.trackers.new
        then
          mv ${dir}/.trackers.new ${dir}/.trackers
        else
          echo WARNING: cannot update bt trackers.
          rm ${dir}/.trackers.new
        fi
      '';
    in
    make-service {
      description = "Aria2 Daemon";
      after = [ "network.target" ];
      serviceConfig = {
        ProtectSystem = "full";
        WorkingDirectory = dir;
        ReadWritePaths = dir;
        ExecStartPre = update-trackers;
        ExecStart =
          let
            aria2 = pkgs.aria2.override ({
              server-mode = true;
              inherit dir;
            } // import ./private/aria2d.nix);
          in
          ''/bin/sh -c 'exec ${aria2}/bin/aria2c --bt-tracker="$(< ${dir}/.trackers)"' '';
      };
    };
  users.users.aria2d ={
    isSystemUser = true;
    group = "aria2d";
  };
  users.groups.aria2d = {};

  systemd.services.instaepub = make-service {
    description = "InstaEpub - Fetch webpages as epub.";
    after = [ "network.target" ];
    proxy = true;
    dir = "instaepub";
    serviceConfig = {
      ExecStart = "${pkgs.instaepub}/bin/instaepub";
    };
  };

  systemd.services.crawler = make-service {
    description = "Web Crawler";
    dir = "16k-crawler";
    proxy = true;
    wantedBy = [];
    serviceConfig = {
      Type = "oneshot";
      Restart = "no";
      ExecStart = "${pkgs.python3.withPackages (p: [ p.requests ])}/bin/python3 bot.py";
    };
  };

  systemd.timers.crawler = {
    description = "Timer for Web Crawler";
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "hourly";
  };

  # systemd.services.nodebb = make-service {
  #   description = "NodeBB forum";
  #   dir = "nodebb";
  #   requires = [ "redis-nodebb.service" ];
  #   after = [ "redis-nodebb.service" ];
  #   serviceConfig = {
  #     ExecStart = "/var/lib/nodebb/nodebb start";
  #     ExecStop = "/var/lib/nodebb/nodebb stop";
  #     Type = "oneshot";
  #     Restart = "no";
  #     RemainAfterExit = true;
  #   };
  #   environment.PATH = "${pkgs.nodejs}/bin";
  # };

  # services.redis.servers.nodebb = {
  #   enable = true;
  #   port = 6379;
  # };

  services.vaultwarden = {
    enable = true;
    config = {}; # use .env file
  };
  systemd.services.vaultwarden.serviceConfig.WorkingDirectory = "/var/lib/vaultwarden";

  networking.firewall = {
    allowedTCPPorts = [ 80 443 1935 25565 5900 5901 9090 7890 ];
    allowedUDPPortRanges = [ { from = 6881; to = 6999; } ];
    allowedTCPPortRanges = [ { from = 6881; to = 6999; } ];
  };

}
