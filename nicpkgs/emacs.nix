{ nixpkgs, system }:

let
  eol = builtins.getFlake "github:nix-community/emacs-overlay/c470756d69bc9195d0ddc1fcd70110376fc93473";
  pkgs = import nixpkgs { inherit system; overlays = [ eol.overlay ]; };
in

with pkgs;

{ plugins ? (p: with p; [ vterm ]) }:

(emacsPackagesFor emacsPgtk).emacsWithPackages plugins
