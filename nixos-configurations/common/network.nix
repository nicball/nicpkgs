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
}
