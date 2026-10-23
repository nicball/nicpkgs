{ lib, buildGoModule, stdenv, olm }:

let nv = <nicpkgs>.nv-sources.${stdenv.hostPlatform.system}.matrix-qq; in

buildGoModule {
  inherit (nv) pname version src;
  buildInputs = [ olm ];
  vendorHash = "sha256-VLlW178B1a2mEwEb/aLZFYPVdC9hzQzI1gen+M8pg1I=";
}

