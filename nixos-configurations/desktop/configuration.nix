# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./misc-software.nix
    ./amd.nix
    ./desktop.nix
    ./network.nix
    ./private/passwords.nix
    ./brightness.nix
    # ./osx.nix
  ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # Time zone
  time.timeZone = "Asia/Shanghai";
  # Compatible with Windows
  # time.hardwareClockInLocalTime = true;

  # Nix channels
  nix.settings.substituters = [ "https://mirrors.ustc.edu.cn/nix-channels/store" "https://cache.nixos.org/" ];
  nixpkgs.config.allowUnfree = true;

  # Users
  users.users.nicball = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "docker" "kvm" "networkmanager" "wireshark" "video" "input" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCxtyU71qMEWzYBaa5aQzGCRlRsERuzc2sFshGA3tWewv3UfcZca27yQTGQnMCvqmObL4+zl0SikUTbQX7Pi4vo7U42EADdWJ4nHJ+/4kJ3s7xtYnlJAdkuS/fDZYsjDLxqEBMR5GCgtPvE8K2A3siBHW837J0fb8SuH7hUe0QnibCeHFPlNuY2OEAZBkUDsXhBz0jDd3D2rg7W1ALdHl+zFt+SimF4H0jOOssF893XfjXZw9C9DLbs0pKeWBJ8cMAf0ZSRFBcJMiiOqUbJQP0QyzVnwfJVX5WsAsebouClwK+tc7txX04BuJqefJbQ1t58cFFYwLQQKDCWwI5smNxqBVhjDSNf1i4ggmcIgaAnV6WWpV30+uObWWLQfox2zkNcxA0k6jkOfoJhkOjxRSFy588GNAstsXd6TgmaZI85RwAM1R9mO7FNrKGaEwpWjclaaml2/ZvnuaYW8mO0bySpYJPACk7O7hgj97BkJGlHdVixR9DSBnBVzHZ2ppQtsqM= nicball"
    ];
  };

  # Nix flakes
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  system.stateVersion = "21.11";

}
