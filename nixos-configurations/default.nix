{ nicpkgs }:

{
  desktop = import ./desktop { inherit nicpkgs; };
  nuc = import ./nuc { inherit nicpkgs; };
}
