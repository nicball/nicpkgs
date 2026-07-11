{ nicpkgs, inputs }:

{
  desktop = import ./desktop { inherit inputs nicpkgs; };
  nuc = import ./nuc { inherit inputs nicpkgs; };
}
