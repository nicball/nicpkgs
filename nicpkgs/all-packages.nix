{ pkgs, callPackage, niclib, system, nixpkgs }:

{

  piqueserver = callPackage ./piqueserver {};

  terraria-server = callPackage ./terraria-server.nix {};

  armake2 = callPackage ./armake2 {};

  arma3-unix-launcher = callPackage ./arma3-unix-launcher.nix {};

  mdbook-epub = callPackage ./mdbook-epub.nix {};

  rust-reference = callPackage ./rust-reference.nix {};

  rust-async-book = callPackage ./rust-async-book.nix {};

  wayland-book = callPackage ./wayland-book.nix {};

  rtw89 = callPackage ./rtw89.nix {};

  maven-j8 = with pkgs; maven.overrideAttrs (_: _: { jdk = jdk8; });

  kakoune = callPackage ./kakoune {};

  lilypondbot = callPackage ./lilypondbot {};

  deepspeech = callPackage ./deepspeech.nix {};

  kindle-tool = callPackage ./kindle-tool.nix {};

  emacs = pkgs.lib.makeOverridable (import ./emacs.nix { inherit nixpkgs system; }) {};

  instaepub = callPackage ./instaepub {};

  kitty = callPackage ./kitty {};

  screenshot = callPackage ./screenshot {};

  aria2 = callPackage ./aria2 {};

  cloudflare-ddns = callPackage ./cloudflare-ddns {};

  qq = niclib.wrapDerivationOutput pkgs.qq "bin/qq" ''
    --add-flags "--ozone-platform-hint=wayland"
  '' // { license = pkgs.lib.licenses.free; };

  owncast = callPackage ./owncast.nix {};

  ufs-utils = callPackage ./ufs-utils.nix {};

  rime-table-bin-decompiler = callPackage ./rime-table-bin-decompiler.nix {};

  ryzenadj = callPackage ./ryzenadj.nix {};

  lean-doc = callPackage ./lean-doc.nix {};

  helix-doc = callPackage ./helix-doc.nix {};

  waybar = callPackage ./waybar {};

  rofi = callPackage ./rofi {};

  alchitry-lab = callPackage ./alchitry-lab.nix {};

  InsydeImageExtractor = callPackage ./InsydeImageExtractor.nix {};

  flowerss-bot = callPackage ./flowerss-bot.nix {};

  pandoc = callPackage ./pandoc.nix {};

  mirai-console-loader = callPackage ./mirai-console-loader.nix {};

  matrix-qq = callPackage ./matrix-qq.nix {};

  mako = callPackage ./mako {};

}
