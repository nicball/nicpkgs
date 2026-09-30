{ buildGoModule, olm, nv-sources }:

buildGoModule rec {
  inherit (nv-sources.mautrix-telegram) pname version src;
  buildInputs = [ olm ];
  vendorHash = "sha256-qW/v/QmhQRF2SAMUNXE2mfVGVEp+DU3gESWVRKHqfGM=";
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
