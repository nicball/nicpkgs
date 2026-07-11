{ pkgs, ... }:

{
  networking.hostName = "nixos-desktop";

  nic.clash = {
    enable = true;
    config.source = ./private/clash.yaml;
  };

  networking.firewall.allowedTCPPorts = [
    47989 47984 48010  # sunshine
    53317 # localsend
  ];

  networking.firewall.allowedUDPPorts = [
    47998 47999 48000 # sunshine
    53317 # localsend
  ];
}
