{ buildGoModule
, stdenv
}:

let nv = <nicpkgs>.nv-sources.${stdenv.hostPlatform.system}.transfersh; in

buildGoModule {
  inherit (nv) pname version src;
  vendorHash = "sha256-C8ZfUIGT9HiQQiJ2hk18uwGaQzNCIKp/Jiz6ePZkgDQ=";
}
