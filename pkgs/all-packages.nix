self: super:

with self;

{

  nicpkgs-scaling = 1.5;

  piqueserver = callPackage ./piqueserver {};

  terraria-server = callPackage ./terraria-server.nix {};

  armake2 = callPackage ./armake2.nix {};

  arma3-unix-launcher = callPackage ./arma3-unix-launcher.nix {};

  mdbook-epub = callPackage ./mdbook-epub.nix {};

  rust-reference = callPackage ./rust-reference.nix {};

  rust-async-book = callPackage ./rust-async-book.nix {};

  wayland-book = callPackage ./wayland-book {};

  rtw89 = callPackage ./rtw89.nix {};

  maven-j8 = maven.overrideAttrs (_: _: { jdk = jdk8; });

  lilypondbot = callPackage ./lilypondbot {};

  deepspeech = callPackage ./deepspeech.nix {};

  kindle-tool = callPackage ./kindle-tool.nix {};

  instaepub = callPackage ./instaepub {};

  screenshot = callPackage ./screenshot {};

  aria2 = callPackage ./aria2 { inherit super; };

  cloudflare-ddns = callPackage ./cloudflare-ddns {};

  qq-wayland = wrapDerivationOutput qq "bin/qq" ''
    --add-flags "--ozone-platform-hint=wayland"
  '';

  ufs-utils = callPackage ./ufs-utils.nix {};

  rime-table-bin-decompiler = callPackage ./rime-table-bin-decompiler.nix {};

  lean-doc = callPackage ./lean-doc.nix {};

  helix-doc = callPackage ./helix-doc {};

  alchitry-lab = callPackage ./alchitry-lab.nix {};

  InsydeImageExtractor = callPackage ./InsydeImageExtractor.nix {};

  flowerss-bot = callPackage ./flowerss-bot.nix {};

  pandoc-static = callPackage ./pandoc-static.nix {};

  mirai-console-loader = callPackage ./mirai-console-loader.nix {};

  matrix-qq = callPackage ./matrix-qq.nix {};

  factorio-headless = callPackage ./factorio-headless {};

  factorio-bot =
    let flake = builtins.getFlake "github:MidyMidy-Factorio/midymidy-factorio-webservice/dca7b6657bcecf0e09c649bea36dda403c227d2c"; in
    (flake.overlays.default self super).midymidy-factorio-webservice;

  fvckbot =
    let flake = builtins.getFlake "github:nicball/fvckbot/61022c520ed573e2906dd505fed9af4cf1eb0542"; in
    (flake.overlays.default self super).fvckbot;

  wiwikwlh = callPackage ./wiwikwlh.nix {};

  transfersh = callPackage ./transfersh.nix {};

  inherit (callPackages ./wrap-derivation-output.nix { inherit self; })
    modifyDerivationOutput
    wrapDerivationOutput;

  torchvisionWithRocm = let p = python3Packages; in p.torchvision.override { torch = p.torchWithRocm; } // {
    meta.platforms = lib.platforms.x86;
    meta.broken = true;
  };

  rust-rfcs = callPackage ./rust-rfcs.nix {};

  rescript-language-server = callPackage ./rescript-language-server.nix {};

  monaco-ttf = callPackage ./monaco-ttf {};

  libjit = callPackage ./libjit.nix {};

  adaptive-cpp = callPackage ./adaptive-cpp.nix {};

  opencl-benchmark = callPackage ./opencl-benchmark { inherit (darwin.apple_sdk.frameworks) OpenCL; };

  xwayland-satellite = callPackage ./xwayland-satellite.nix {};

  kakounePlugins = lib.recurseIntoAttrs (callPackage ./kakoune-plugins { inherit super; });

  hexcore-link = callPackage ./hexcore-link.nix {};

  nutstore-client = callPackage ./nutstore-client.nix {};

  nutstore-nautilus = callPackage ./nutstore-nautilus.nix {};

  zen-browser = callPackage ./zen-browser {};

  rofi-wayland-unwrapped = callPackage ./rofi-wayland-unwrapped.nix { inherit super; };

  swayexec = callPackage ./swayexec {};

}
