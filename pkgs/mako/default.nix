{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config, scdoc
, systemd, pango, cairo, gdk-pixbuf, jq
, wayland, wayland-protocols
, wrapGAppsHook
, substituteAll, nicpkgs-scale
}:

let
  config = substituteAll ({
    src = ./config;
  } // lib.mapAttrs (k: v: builtins.ceil (nicpkgs-scale * v)) {
    fontSize = 10;
    width = 300;
    height = 100;
    padding = 6;
    margin = 10;
  });
in

stdenv.mkDerivation rec {
  pname = "mako";
  version = "1.7.1";

  src = fetchFromGitHub {
    owner = "emersion";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-/+XYf8FiH4lk7f7/pMt43hm13mRK+UqvaNOpf1TI6m4=";
  };

  depsBuildBuild = [ pkg-config ];
  nativeBuildInputs = [ meson ninja pkg-config scdoc wayland-protocols wrapGAppsHook ];
  buildInputs = [ systemd pango cairo gdk-pixbuf wayland ];

  mesonFlags = [
    "-Dzsh-completions=true"
    "-Dsd-bus-provider=libsystemd"
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : "${lib.makeBinPath [ systemd /* for busctl */ jq ]}"
      --add-flags "--config ${config}"
    )
  '';

  meta = with lib; {
    description = "A lightweight Wayland notification daemon";
    homepage = "https://wayland.emersion.fr/mako/";
    license = licenses.mit;
    maintainers = with maintainers; [ dywedir synthetica ];
    platforms = platforms.linux;
  };
}
