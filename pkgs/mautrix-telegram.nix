{ buildGoModule, olm, nv-sources }:

buildGoModule rec {
  inherit (nv-sources.mautrix-telegram) pname version src;
  buildInputs = [ olm ];
  vendorHash = "sha256-bmpTm1/6Z+kAFGAJ70ohBz8+n8JZk7mZyCfX0+FB/fE=";
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
