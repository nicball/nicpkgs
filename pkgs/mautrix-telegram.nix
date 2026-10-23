{ buildGoModule, olm, stdenv }:

let nv = <nicpkgs>.nv-sources.${stdenv.hostPlatform.system}.mautrix-telegram; in

buildGoModule rec {
  inherit (nv) pname version src;
  buildInputs = [ olm ];
  vendorHash = "sha256-JbnlJnCtIKC3rpO2mBa7DvEFeWuq9tpvN9H+MoQ5VV0=";
  ldflags = [
    "-s"
    "-w"
    "-X"
    "main.Tag=${version}"
  ];
  doCheck = false;
  meta = {
    mainProgram = "mautrix-telegram";
  };
}
