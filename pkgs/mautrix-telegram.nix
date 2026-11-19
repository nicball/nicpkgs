{ buildGoModule, olm, stdenv }:

let nv = <nicpkgs>.nv-sources.${stdenv.hostPlatform.system}.mautrix-telegram; in

buildGoModule rec {
  inherit (nv) pname version src;
  buildInputs = [ olm ];
  vendorHash = "sha256-byvTXR7gy6b/TIVfJ8bwMC/D9vqn6iwjoxBE1gkBNBc=";
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
