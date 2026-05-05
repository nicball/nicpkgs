{ buildGoModule, olm, nv-sources }:

buildGoModule rec {
  inherit (nv-sources.mautrix-telegram) pname version src;
  buildInputs = [ olm ];
  vendorHash = "sha256-mQ6zvEK6YcR71zLGD1n9xZzXqiXtKIs43rxeP278Ln0=";
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
