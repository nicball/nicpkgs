{ config, pkgs, lib, ... }:

{
  nic.amd = {
    cpu.enable = true;
    gpu.enable = true;
    nct6687.enable = true;
  };

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
    KERNEL=="card*", KERNELS=="0000:15:00.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/igpu"
    KERNEL=="card*", KERNELS=="0000:03:00.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/dgpu"
  '';

  environment.variables.AQ_DRM_DEVICES = "/dev/dri/igpu:/dev/dri/dgpu";
}
