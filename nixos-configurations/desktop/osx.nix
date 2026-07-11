{ pkgs, config, ... }:

{
  boot.extraModulePackages = [ config.boot.kernelPackages.vendor-reset ];
  boot.kernelParams = [
    "iommu=pt"
    "amd_iommu=on"
    "video=vesafb:off,efifb:off"
    "kvm.ignore_msrs=1"
    "kvm.report_ignored_msrs=0"
    "vfio-pci.ids=1002:731f,1002:ab38,1022:15b7"
    "vfio-pci.disable_vga=1"
  ];
  boot.kernelModules = [ "vendor-reset" "vfio" "vfio_iommu_type1" "vfio_pci" ];
  boot.initrd.kernelModules = [ "vendor-reset" "vfio" "vfio_iommu_type1" "vfio_pci" ];
  boot.extraModprobeConfig = ''
    options kvm ignore_msrs=1 report_ignored_msrs=0
    options vfio-pci ids=1002:731f,1002:ab38,1022:15b7 disable_vga=1
    softdep amdgpu pre: vfio-pci
    softdep drm pre: vfio-pci
  '';
  services.udev.extraRules = ''SUBSYSTEM=="vfio", MODE="0660", GROUP="kvm"'';
  security.pam.loginLimits = [
    {
      domain = "@kvm";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
  ];
}
