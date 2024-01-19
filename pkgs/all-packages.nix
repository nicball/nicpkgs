self: super:

{

  piqueserver = self.callPackage ./piqueserver {};

  terraria-server = self.callPackage ./terraria-server.nix {};

  armake2 = self.callPackage ./armake2.nix {};

  arma3-unix-launcher = self.callPackage ./arma3-unix-launcher.nix {};

  mdbook-epub = self.callPackage ./mdbook-epub.nix {};

  rust-reference = self.callPackage ./rust-reference.nix {};

  rust-async-book = self.callPackage ./rust-async-book.nix {};

  wayland-book = self.callPackage ./wayland-book {};

  rtw89 = self.callPackage ./rtw89.nix { linux = self.linux_6_6; };

  maven-j8 = self.maven.overrideAttrs (_: _: { jdk = self.jdk8; });

  kakoune = self.callPackage ./kakoune {};

  lilypondbot = self.callPackage ./lilypondbot {};

  deepspeech = self.callPackage ./deepspeech.nix {};

  kindle-tool = self.callPackage ./kindle-tool.nix {};

  instaepub = self.callPackage ./instaepub {};

  kitty = self.callPackage ./kitty { inherit super; };

  screenshot = self.callPackage ./screenshot {};

  aria2 = self.callPackage ./aria2 { inherit super; };

  cloudflare-ddns = self.callPackage ./cloudflare-ddns {};

  qq-wayland = self.wrapDerivationOutput self.qq "bin/qq" ''
    --add-flags "--ozone-platform-hint=wayland"
  '';

  ufs-utils = self.callPackage ./ufs-utils.nix {};

  rime-table-bin-decompiler = self.callPackage ./rime-table-bin-decompiler.nix {};

  ryzenadj = self.callPackage ./ryzenadj.nix {};

  lean-doc = self.callPackage ./lean-doc.nix {};

  helix-doc = self.callPackage ./helix-doc {};

  waybar = self.callPackage ./waybar { inherit super; };

  rofi-wayland = self.callPackage ./rofi-wayland { inherit super; };

  alchitry-lab = self.callPackage ./alchitry-lab.nix {};

  InsydeImageExtractor = self.callPackage ./InsydeImageExtractor.nix {};

  flowerss-bot = self.callPackage ./flowerss-bot.nix {};

  pandoc-static = self.callPackage ./pandoc-static.nix {};

  mirai-console-loader = self.callPackage ./mirai-console-loader.nix {};

  matrix-qq = self.callPackage ./matrix-qq.nix {};

  mako = self.callPackage ./mako {};

  factorio-headless = self.callPackage ./factorio-headless.nix {};

  factorio-bot = (builtins.getFlake "github:nicball/midymidy-factorio-webservice/b25420b4b87439adda777f306c7e4d5efeb434aa").packages.${self.system}.default;

  fvckbot = (builtins.getFlake "github:nicball/fvckbot/ffe40ebe4f13aee58f79ce2bb4429aa0af65614a").packages.${self.system}.fvckbot;

  wiwinwlh = self.callPackage ./wiwinwlh.nix {};

  transfersh = self.callPackage ./transfersh.nix {};

  inherit ((self.callPackages ./wrap-derivation-output.nix { inherit self; }).fns)
    modifyDerivationOutput
    wrapDerivationOutput;

}
