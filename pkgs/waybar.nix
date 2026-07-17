{ nv-sources, super, modemmanager, systemdSupport ? true }:

(super.waybar.override { cavaSupport = false; }).overrideAttrs (prev: {
  inherit (nv-sources.waybar) src;
  buildInputs = prev.buildInputs ++ [ modemmanager ];
})
