{ lib, wrapDerivationOutput, fetchFromGitHub, super }:

let
  waybar-old = (super.waybar.override {
    pipewireSupport = false;
    cavaSupport = false;
  }).overrideAttrs (self: super: {
    version = "0.9.24";
    src = fetchFromGitHub {
      owner = "Alexays";
      repo = "waybar";
      rev = "0.9.24";
      sha256 = "sha256-JhLKGzqZ8akWcyHTav2TGcGmXk9dy9Xj4+/oFCPeNU0=";
    };
    mesonFlags = lib.remove "-Dpipewire=disabled" super.mesonFlags;
  });
in

wrapDerivationOutput waybar-old "bin/waybar" ''
  --add-flags '--config ${./waybar-config}' \
  --add-flags '--style ${./waybar-style.css}'
''
