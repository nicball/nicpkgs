{ lib, pkgs, fetchFromGitHub }:

{ meta.platforms = lib.platforms.x86; } // (

let nurpkgs = import (fetchFromGitHub {
  owner = "nix-community";
  repo = "nur-combined";
  rev = "d336fa98ac701595ae9e827b0101d95350a53593";
  sha256 = "sha256-hwz0hc5FVZanzFflbtInU7PW+DeiBy/JlF67BoZjhnM=";
}) { nurpkgs = pkgs; inherit pkgs; }; in

nurpkgs.repos.linyinfeng.wemeet

)
