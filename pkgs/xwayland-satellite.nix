{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, xwayland
, xcb-util-cursor
, libxcb
, nix-update-script
, makeWrapper
}:

rustPlatform.buildRustPackage rec {
  pname = "xwayland-satellite";
  version = "unstable-2024-09-15";
  src = fetchFromGitHub {
    owner = "Supreeeme";
    repo = "xwayland-satellite";
    rev = "b962a0f33b503aa39c9cf6919f488b664e5b79b4";
    hash = "sha256-OANPb73V/RQDqtpIcbzeJ93KuOHKFQv+1xXC44Ut7tY=";
  };
  cargoHash = "sha256-82+ukrsqdC1+wETAGbmy6yYNAUeIi4sXbQWlSI08DOU=";
  cargoBuildFeatures = [ "systemd" ];

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    makeWrapper
  ];

  buildInputs = [
    libxcb
    xcb-util-cursor
  ];

  # disable Xwayland integration tests which need a running display server
  checkFlags = [
    "--exact"
    "--skip=copy_from_wayland"
    "--skip=copy_from_x11"
    "--skip=input_focus"
    "--skip=quick_delete"
    "--skip=reparent"
    "--skip=toplevel_flow"
    "--skip=bad_clipboard_data"
    "--skip=different_output_position"
    "--skip=funny_window_title"
  ];

  postInstall = ''
    wrapProgram $out/bin/xwayland-satellite \
      --prefix PATH : "${lib.makeBinPath [xwayland]}"
  '';

  meta = with lib; {
    mainProgram = "xwayland-satellite";
    platforms = platforms.linux;
  };
}
