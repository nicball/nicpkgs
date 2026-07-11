{ config, pkgs, lib, ... }:

let

  cfg = config.nic.amd;

  set-perf-level = level: assert (lib.assertOneOf "set-perf-level" level [ 1 0 ]); ''
    for i in /sys/devices/system/cpu/cpufreq/policy*; do
      echo ${if level == 1 then "performance" else "power"} > $i/energy_performance_preference
    done
    echo ${if level == 1 then "balanced" else "low-power"} > /sys/firmware/acpi/platform_profile
  '';

in

{
  options.nic.amd = {

    cpu = {
      enable = lib.mkEnableOption "AMD CPU";
      manage-performance-profile = lib.mkEnableOption "Automatically set EPP and platform profile";
    };

    gpu = {
      enable = lib.mkEnableOption "AMD GPU";
      overclock = lib.mkEnableOption "AMD GPU overclocking";
    };

    ryzenadj.enable = lib.mkEnableOption "ryzenadj";

    nct6687.enable = lib.mkEnableOption "AMD B650 chipsets";

  };

  config = lib.mkMerge [

    (lib.mkIf cfg.cpu.enable {
      powerManagement.cpuFreqGovernor = "powersave";
      boot.kernelParams = [
        "initcall_blacklist=acpi_cpufreq_init"
        "amd_pstate=active"
      ];
    })

    (lib.mkIf cfg.cpu.enable && cfg.cpu.manage-performance-profile {

      services.acpid = {
        enable = true;
        acEventCommands = ''
          vals=($1)
          case ''${vals[3]} in
            00000000)
              ${set-perf-level 0}
            ;;
            00000001)
              ${set-perf-level 1}
            ;;
          esac
        '';
      };

      systemd.services.amd-set-epp =
        let script = pkgs.writeShellScript "amd-set-epp.sh" ''
          if ${pkgs.acpi}/bin/acpi -a | grep off-line > /dev/null; then
            ${set-perf-level 0}
          else
            ${set-perf-level 1}
          fi
        '';
        in {
          description = "Automatically set AMD PState EPP on startup";
          wantedBy = [ "multi-user.target" ];
          after = [ "cpufreq.service" ];
          serviceConfig = {
            ExecStart = script;
            Type = "oneshot";
          };
        };

    })

    (lib.mkIf cfg.gpu.enable {
      environment.systemPackages = with pkgs; [ radeontop lact ];
      systemd.packages = [ pkgs.lact ];
      systemd.services.lactd.wantedBy = [ "multi-user.target" ];
      hardware.graphics.extraPackages = [ pkgs.rocmPackages.clr.icd ];
      boot.kernelParams = lib.optionals cfg.gpu.overclocking [ "amdgpu.ppfeaturemask=0xffffffff" ];
    })

    (lib.mkIf cfg.ryzenadj.enable {
      boot.kernelParams = [ "iomem=relaxed" ];
      boot.kernelModules = [ "ryzen_smu" ];
      boot.extraModulePackages = with config.boot.kernelPackages; [ ryzen-smu ];
      environment.systemPackages = [ pkgs.ryzenadj ];
    })

    (lib.mkIf cfg.nct6687.enable {
      boot.kernelModules = [ "nct6687" ];
      boot.extraModulePackages = with config.boot.kernelPackages; [ nct6687d ];
    })
  ];

}
