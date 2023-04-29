{ callPackage }:

{

  instaepub = callPackage ./instaepub.nix {};

  cloudflare-ddns = callPackage ./cloudflare-ddns.nix {};

}
