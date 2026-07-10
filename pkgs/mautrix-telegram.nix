{ buildGoModule, olm, nv-sources }:

buildGoModule rec {
  inherit (nv-sources.mautrix-telegram) pname version src;
  buildInputs = [ olm ];
  vendorHash = "sha256-+VDdJg5RZzMrphJ5SK+YbdENhPiHJpwGY/JqBJewtUo=";
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
