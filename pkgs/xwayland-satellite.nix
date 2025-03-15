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
  version = "unstable-2024-11-22";
  src = fetchFromGitHub {
    owner = "Supreeeme";
    repo = "xwayland-satellite";
    rev = "02f30546264ff8407cbb39528b3a3cc3045e53c1";
    hash = "sha256-gWf9dX6DVx0ssK2G3yrFG9yMT9UU0mDwyD51z/Q6FTA=";
  };
  useFetchCargoVendor = true;
  cargoHash = "sha256-1IsKt+OfezILaDklHts74TnS0/FVogu6Ds/7JG+ataY=";
  buildFeatures = [ "systemd" ];

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    makeWrapper
  ];

  buildInputs = [
    libxcb
    xcb-util-cursor
  ];

  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/xwayland-satellite \
      --prefix PATH : "${lib.makeBinPath [xwayland]}"
    mkdir -p $out/lib/systemd/user
    substitute $src/resources/xwayland-satellite.service $out/lib/systemd/user/xwayland-satellite.service \
      --replace-fail '/usr/local/bin' "$out/bin"
  '';

  meta = with lib; {
    mainProgram = "xwayland-satellite";
    platforms = platforms.linux;
  };
}
