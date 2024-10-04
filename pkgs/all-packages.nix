self: super:

with self;

{

  nicpkgs-scale = 1.5;

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

  kakoune = callPackage ./kakoune {};

  lilypondbot = callPackage ./lilypondbot {};

  deepspeech = callPackage ./deepspeech.nix {};

  kindle-tool = callPackage ./kindle-tool.nix {};

  instaepub = callPackage ./instaepub {};

  kitty = callPackage ./kitty { inherit super; };

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

  waybar = callPackage ./waybar { inherit super; };

  rofi-wayland = callPackage ./rofi-wayland { inherit super; };

  alchitry-lab = callPackage ./alchitry-lab.nix {};

  InsydeImageExtractor = callPackage ./InsydeImageExtractor.nix {};

  flowerss-bot = callPackage ./flowerss-bot.nix {};

  pandoc-static = callPackage ./pandoc-static.nix {};

  mirai-console-loader = callPackage ./mirai-console-loader.nix {};

  matrix-qq = callPackage ./matrix-qq.nix {};

  mako = callPackage ./mako.nix { inherit super; };

  factorio-headless = callPackage ./factorio-headless {};

  factorio-bot =
    let flake = builtins.getFlake "github:nicball/midymidy-factorio-webservice/e58610d2e860c60f83578c18c0406964d3f4923a"; in
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

  ispc = callPackage ./ispc.nix { inherit super; };

  proton-ge-bin = callPackage ./proton-ge-bin.nix {};

  opencl-benchmark = callPackage ./opencl-benchmark { inherit (darwin.apple_sdk.frameworks) OpenCL; };

}
