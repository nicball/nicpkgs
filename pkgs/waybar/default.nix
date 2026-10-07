{ nv-sources, super
, modemmanager, systemdSupport ? true, window-manager ? "sway"
, makeBinaryWrapper, replaceVars
, acpilight, pavucontrol, util-linux
}:

let
  config = replaceVars ./config.json {
    wm = window-manager;
    xbacklight = "${acpilight}/bin/xbacklight";
    pavucontrol = "${pavucontrol}/bin/pavucontrol";
    rfkill = "${util-linux}/bin/rfkill";
  };
in

(super.waybar.override { cavaSupport = false; }).overrideAttrs (prev: {
  inherit (nv-sources.waybar) src;
  buildInputs = (prev.buildInputs or []) ++ [ modemmanager ];
  nativeBuildInputs = (prev.nativeBuildInputs or []) ++ [ makeBinaryWrapper ];
  postInstall = (prev.postInstall or "") + ''
    wrapProgram $out/bin/waybar --add-flags '--config ${config} --style ${./style.css}'
  '';
})
