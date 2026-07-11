{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usbhid" "sdhci_pci" "amdgpu" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-partuuid/2e84534f-1ef1-49ad-9730-3c4f30c3bd0d";
      fsType = "btrfs";
      options = [ "subvol=rootfs" "compress=zstd:8" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-partuuid/2e84534f-1ef1-49ad-9730-3c4f30c3bd0d";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd:8" "noatime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-partuuid/39967025-068f-405f-b7b3-bdba56a1f834";
      fsType = "vfat";
    };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    writebackDevice = "/dev/disk/by-partuuid/4b408272-0b71-4b16-ae31-78d8b38b2088";
  };

  services.fstrim.enable = false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
