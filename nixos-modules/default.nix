{ overlay }:

{ lib, config, ... }:

{
  imports = [
    (import ./overlay.nix { inherit overlay; })
    ./window-managers.nix
    ./greetd.nix
    ./backlight.nix
    ./hexcore-link.nix
    ./clash.nix
    ./amd.nix
    ./intel.nix
  ];

  options.nic = {
    cachix = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.nic.cachix {
      nix.settings = {
        substituters = [ "https://nicpkgs.cachix.org" ];
        trusted-public-keys = [ "nicpkgs.cachix.org-1:OTCMJ8lLYwhnDhlkP0huok3hOnxV3u/YVDH9M0kPLqM=" ];
      };
    })
  ];
}
