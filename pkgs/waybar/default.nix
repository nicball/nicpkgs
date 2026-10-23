{ stdenv, super
, modemmanager, systemdSupport ? true, window-manager ? "hyprland"
, makeBinaryWrapper, replaceVars
, acpilight, pavucontrol, util-linux
}:

let
  nv = <nicpkgs>.nv-sources.${stdenv.hostPlatform.system}.waybar;
  config = replaceVars ./config.json {
    wm = window-manager;
    xbacklight = "${acpilight}/bin/xbacklight";
    pavucontrol = "${pavucontrol}/bin/pavucontrol";
    rfkill = "${util-linux}/bin/rfkill";
  };
in

(super.waybar.override { cavaSupport = false; }).overrideAttrs (prev: {
  inherit (nv) src;
  buildInputs = (prev.buildInputs or []) ++ [ modemmanager ];
  nativeBuildInputs = (prev.nativeBuildInputs or []) ++ [ makeBinaryWrapper ];
  postInstall = (prev.postInstall or "") + ''
    wrapProgram $out/bin/waybar --add-flags '--config ${config} --style ${./style.css}'
  '';
})
