{ config, pkgs, lib, ... }:

{
  nic.amd = {
    cpu.enable = true;
    gpu = {
      enable = true;
      overclocking = true;
    };
    nct6687.enable = true;
  };

  boot.kernelModules = [ "ntsync" ];

  # Fix dGPU fan spinning when suspended
  boot.kernelParams = [ "amdgpu.runpm=0" ];

  systemd.services.fancontrol = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    description = "fancontrol - Adjust case fans in relation to max temp of CPU and GPU";
    serviceConfig = {
      ExecStart = pkgs.writeShellScript "fancontrol" (builtins.readFile ./fancontrol.sh);
      Restart = "on-failure";
    };
  };

  services.udev.extraRules = ''
    KERNEL=="card*", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", ATTRS{vendor}=="0x1002", ATTRS{device}=="0x164e", SYMLINK+="dri/igpu"
    KERNEL=="card*", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", ATTRS{vendor}=="0x1002", ATTRS{device}=="0x731f", SYMLINK+="dri/dgpu"
  '';

  environment.variables.AQ_DRM_DEVICES = "/dev/dri/igpu:/dev/dri/dgpu";
}
