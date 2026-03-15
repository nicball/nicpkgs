{ lib, buildGoModule, nv-sources, olm }:

buildGoModule {
  inherit (nv-sources.matrix-qq) pname version src;
  buildInputs = [ olm ];
  vendorHash = "sha256-VLlW178B1a2mEwEb/aLZFYPVdC9hzQzI1gen+M8pg1I=";
  meta.broken = true; # libolm
}

