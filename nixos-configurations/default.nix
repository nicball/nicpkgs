{ nixpkgs, nix-index-database }:

{
  desktop = import ./desktop { inherit nixpkgs nix-index-database; };
}
