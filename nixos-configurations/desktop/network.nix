{ pkgs, config, ... }:

{
  networking.hostName = "nixos-desktop";

  age.secrets."clash.yaml".file = ./clash.yaml.age;
  nic.clash = {
    enable = true;
    config-path = config.age.secrets."clash.yaml".path;
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
