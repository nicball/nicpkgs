{ ... }:

{
  networking = {
    useDHCP = true;
    dhcpcd.extraConfig = ''
      # nohook resolv.conf
      release
    '';
    wireless.enable = true;
    wireless.userControlled = true; # allow wpa_cli to connect
  };

  age.secrets."wireless-psk" = {
    file = ./wireless-psk.age;
    owner = "wpa_supplicant";
    group = "wpa_supplicant";
  };
  networking.wireless.secretsFile = config.age.secrets.wireless-psk.path;
  networking.wireless.networks = {
    Cain = {
      pskRaw = "ext:cain";
      # extraConfig = "bssid=F4:2A:7D:D3:3B:95";
    };
    # "226" = { psk = "226226226"; };
    "android-oneplusace" = { pskRaw = "ext:android_oneplusace"; };
    ustc-guest = {};
    ustcnet = {};
    eduroam = {
      extraConfig = ''
        pairwise=CCMP
        group=CCMP TKIP
        phase2="auth=MSCHAPv2"
      '';
      auth = ''
        eap=PEAP
        identity="nicball@ustc.edu.cn"
        password=ext:eduroam
      '';
    };
  };
}
