{ super, kakounePlugins, kakoune-unwrapped, makeBinaryWrapper }:


super.kakoune.override {
  plugins = with kakounePlugins; [
    parinfer-rust
    kakoune-state-save
    kakoune-lsp
    kak-ansi
    kak-ispc
    kak-racket
    kak-rescript
    kak-nord
    kak-one-light
  ];
  kakoune = kakoune-unwrapped.overrideAttrs (final: prev: {
    nativeBuildInputs = (prev.nativeBuildInputs or []) ++ [ makeBinaryWrapper ];
    postInstall = (prev.postInstall or "") + ''
      wrapProgram $out/bin/kak --set-default KAKOUNE_CONFIG_DIR "${./config}"
    '';
  });
}
