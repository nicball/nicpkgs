{ buildGoModule, olm, nv-sources }:

buildGoModule rec {
  inherit (nv-sources.mautrix-telegram) pname version src;
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
