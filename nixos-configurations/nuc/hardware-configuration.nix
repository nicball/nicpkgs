{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-partuuid/2c299ae1-1ecf-4841-bcd5-45a08ba4f29c";
    fsType = "btrfs";
    options = [ "compress=zstd:8" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partuuid/9b2a05ca-ecd2-4408-95b3-f5a0abd9ceb6";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  services.fstrim.enable = false;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
