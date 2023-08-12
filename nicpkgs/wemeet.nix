{ lib, pkgs, fetchFromGitHub }:

{ meta.platforms = lib.platforms.x86; } // (

let nurpkgs = import (fetchFromGitHub {
  owner = "nix-community";
  repo = "nur-combined";
  rev = "38940c1ddf77b803aa2eaa3d20b3030b99f65cc6";
  sha256 = "sha256-sbL+QVfOJ11KH/UYVUEEfBQ18Xc/GGwLJurJvsJFXfc=";
}) { nurpkgs = pkgs; inherit pkgs; }; in

nurpkgs.repos.linyinfeng.wemeet

)
