{ config, pkgs, lib, ... }:

{
  imports = [
    ./common/passwords.nix
    ./common/misc-software.nix
    ./common/network.nix
  ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  time.timeZone = "Asia/Shanghai";
  # time.hardwareClockInLocalTime = true;
  nix.settings.substituters = [ "https://mirrors.ustc.edu.cn/nix-channels/store" "https://cache.nixos.org/" ];
  nixpkgs.config.allowUnfree = true;
  users.users.nicball = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "docker" "kvm" "networkmanager" "wireshark" "video" "input" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+HdY4yK36CaemcVluXu9/7MZ7VZ9syTnVLz3FSqUkL nicball"
    ];
  };
  system.stateVersion = "25.11";
}

