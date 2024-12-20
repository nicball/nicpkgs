{ super, fetchFromGitHub, xcbutilkeysyms, pandoc }:

super.rofi-wayland-unwrapped.overrideAttrs (prev: {
  version = "unstale-2024-12-20";
  src = fetchFromGitHub {
    owner = "lbonn";
    repo = "rofi";
    rev = "0abd88784ba5b43c44ccb9e90e8ae0262862d47b";
    fetchSubmodules = true;
    hash = "sha256-Xm5UUktlMjiecRUaTIrSjPPYJHjWqfSpAQ0D0G4ldr4=";
  };
  patches = [];
  nativeBuildInputs = prev.nativeBuildInputs ++ [ pandoc ];
  buildInputs = prev.buildInputs ++ [ xcbutilkeysyms ];
})
