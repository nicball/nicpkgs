{ buildGoModule
, nv-sources
}:

buildGoModule {
  inherit (nv-sources.transfersh) pname version src;
  vendorHash = "sha256-C8ZfUIGT9HiQQiJ2hk18uwGaQzNCIKp/Jiz6ePZkgDQ=";
}
