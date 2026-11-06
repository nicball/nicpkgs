self: super:
let inherit (self) callPackage lib qt6Packages system; in
{
  nicpkgs-scaling           = 1;
  piqueserver               = callPackage (import ./piqueserver) {};
  terraria-server           = callPackage (import ./terraria-server.nix) {};
  armake2                   = callPackage (import ./armake2.nix) {};
  mdbook-epub               = callPackage (import ./mdbook-epub.nix) {};
  rust-reference            = callPackage (import ./rust-reference.nix) {};
  rust-async-book           = callPackage (import ./rust-async-book.nix) {};
  wayland-book              = callPackage (import ./wayland-book) {};
  lilypondbot               = callPackage (import ./lilypondbot) {};
  kindle-tool               = callPackage (import ./kindle-tool.nix) {};
  screenshot                = callPackage (import ./screenshot) {};
  aria2                     = callPackage (import ./aria2.nix) { inherit super; };
  cloudflare-ddns           = callPackage (import ./cloudflare-ddns) {};
  ufs-utils                 = callPackage (import ./ufs-utils.nix) {};
  rime-table-bin-decompiler = callPackage (import ./rime-table-bin-decompiler.nix) {};
  lean-doc                  = callPackage (import ./lean-doc.nix) {};
  helix-doc                 = callPackage (import ./helix-doc) {};
  alchitry-lab              = callPackage (import ./alchitry-lab.nix) {};
  InsydeImageExtractor      = callPackage (import ./InsydeImageExtractor.nix) {};
  flowerss-bot              = callPackage (import ./flowerss-bot.nix) {};
  pandoc-static             = callPackage (import ./pandoc-static.nix) {};
  mirai-console-loader      = callPackage (import ./mirai-console-loader.nix) {};
  matrix-qq                 = callPackage (import ./matrix-qq.nix) {};
  factorio-headless         = callPackage (import ./factorio-headless) {};
  factorio-bot              =
    let flake = builtins.getFlake "github:MidyMidy-Factorio/midymidy-factorio-webservice/880ebae6c941c06454c6f3f732b723596d3c9b35"; in
    (flake.overlays.default self super).midymidy-factorio-webservice;
  fvckbot                   =
    let flake = builtins.getFlake "github:nicball/fvckbot/61022c520ed573e2906dd505fed9af4cf1eb0542"; in
    (flake.overlays.default self super).fvckbot;
  wiwikwlh                  = callPackage (import ./wiwikwlh.nix) {};
  transfersh                = callPackage (import ./transfersh.nix) {};
  rust-rfcs                 = callPackage (import ./rust-rfcs.nix) {};
  rescript-language-server  = callPackage (import ./rescript-language-server.nix) {};
  monaco-ttf                = callPackage (import ./monaco-ttf) {};
  libjit                    = callPackage (import ./libjit.nix) {};
  adaptive-cpp              = callPackage (import ./adaptive-cpp.nix) {};
  opencl-benchmark          = callPackage (import ./opencl-benchmark.nix) {};
  kakounePlugins            = lib.recurseIntoAttrs (callPackage (import ./kakoune-plugins) { inherit super; });
  hexcore-link              = callPackage (import ./hexcore-link.nix) {};
  nutstore-client           = callPackage (import ./nutstore-client.nix) {};
  nutstore-nautilus         = callPackage (import ./nutstore-nautilus.nix) {};
  zen-browser               = callPackage (import ./zen-browser) {};
  uudeck                    = callPackage (import ./uudeck.nix) {};
  torrent-file-editor       = qt6Packages.callPackage (import ./torrent-file-editor.nix) {};
  obinskit                  = callPackage (import ./obinskit.nix) {};
  mautrix-telegram          = callPackage (import ./mautrix-telegram.nix) {};
  waybar                    = callPackage (import ./waybar) { inherit super; };
  pi-skills                 = lib.recurseIntoAttrs (callPackage (import ./pi-skills) {});
  qq                        = callPackage (import ./qq.nix) { inherit super; };
  kitty                     = callPackage (import ./kitty) { inherit super; };
  dunst                     = callPackage (import ./dunst) { inherit super; };
  fish                      = callPackage (import ./fish.nix) { inherit super; };
  kakoune                   = callPackage (import ./kakoune) { inherit super; };
  rofi                      = callPackage (import ./rofi) { inherit super; };
  pi-web                    = callPackage (import ./pi-web) {};
  pi-coding-agent           = callPackage (import ./pi-coding-agent.nix) {};
  instaepub                 = <nicpkgs>.inputs.instaepub.packages.${self.stdenv.hostPlatform.system}.instaepub;
}
