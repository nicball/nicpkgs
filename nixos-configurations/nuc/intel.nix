{ pkgs, config, ... }:

{
  nic.intel.gpu.enable = true;

  systemd.services.auto-set-epp =
    let script = pkgs.writeShellScript "set-epp.sh" ''
      for i in /sys/devices/system/cpu/cpufreq/policy*; do
        echo "performance" > $i/energy_performance_preference
      done
      PATH="${pkgs.kmod}/bin:$PATH"
      ${pkgs.undervolt}/bin/undervolt -p1 15 64  -p2 15 0.00244140625
    ''; in {
      description = "Automatically set Intel PState EPP on startup";
      wantedBy = [ "multi-user.target" ];
      after = [ "cpufreq.service" ];
      serviceConfig = {
        ExecStart = script;
        Type = "oneshot";
      };
    };
}
