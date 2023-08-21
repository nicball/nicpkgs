{ pkgs, callPackage, niclib, system, nixpkgs }:

{

  piqueserver = callPackage ./piqueserver {};

  terraria-server = callPackage ./terraria-server.nix {};

  armake2 = callPackage ./armake2 {};

  arma3-unix-launcher = callPackage ./arma3-unix-launcher.nix {};

  mdbook-epub = callPackage ./mdbook-epub.nix {};

  rust-reference = callPackage ./rust-reference.nix {};

  rust-async-book = callPackage ./rust-async-book {};

  wayland-book = callPackage ./wayland-book.nix {};

  rtw89 = pkgs.lib.makeOverridable (callPackage ./rtw89.nix {}) {};

  maven-j8 = with pkgs; maven.overrideAttrs (_: _: { jdk = jdk8; });

  kakoune = callPackage ./kakoune {};

  lilypondbot = callPackage ./lilypondbot {};

  deepspeech = callPackage ./deepspeech.nix {};

  kindle-tool = callPackage ./kindle-tool.nix {};

  emacs = pkgs.lib.makeOverridable (import ./emacs.nix { inherit nixpkgs system; }) {};

  instaepub = pkgs.lib.makeOverridable (callPackage ./instaepub {}) {};

  kitty = callPackage ./kitty {};

  screenshot = pkgs.lib.makeOverridable (callPackage ./screenshot {}) {};

  aria2 = pkgs.lib.makeOverridable (callPackage ./aria2 {}) {};

  cloudflare-ddns = pkgs.lib.makeOverridable (callPackage ./cloudflare-ddns {}) {};

  qq = niclib.wrapDerivationOutput pkgs.qq "bin/qq" ''
    --add-flags "--ozone-platform-hint=wayland"
  '';

  owncast = callPackage ./owncast.nix {};

  ufs-utils = callPackage ./ufs-utils.nix {};

  rime-table-bin-decompiler = callPackage ./rime-table-bin-decompiler.nix {};

  ryzenadj = callPackage ./ryzenadj.nix {};

  lean-doc = callPackage ./lean-doc.nix {};

  helix-doc = callPackage ./helix-doc.nix {};

}
