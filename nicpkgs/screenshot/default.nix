{ lib
, writeShellScriptBin
, grim
, slurp
, imagemagick
}:

lib.flip lib.makeOverridable {} (
  { scale ? "1"
  , output-dir ? "~/screenshots"
  , format ? "$(date +%Y-%m-%d_%H-%M-%S)"
  }:
  writeShellScriptBin "screenshot" ''
    fullscreen=false
    savetodisk=false
    for i; do
      case "$i" in
        --full)
          fullscreen=true
          ;;
        --save)
          savetodisk=true
          ;;
      esac
    done
    if $fullscreen; then
      ${grim}/bin/grim /tmp/latest-screenshot.png
    else
      file=$(mktemp /tmp/XXXXXXXXXXX-screenshot.png)
      ${grim}/bin/grim $file
      read w h x y < <(${slurp}/bin/slurp -f "%w %h %x %y")
      ${imagemagick}/bin/convert $file -crop $((w*${scale}))x$((h*${scale}))+$((x*${scale}))+$((y*${scale})) /tmp/latest-screenshot.png
      rm $file
    fi
    wl-copy --type image/png < /tmp/latest-screenshot.png
    if $savetodisk; then
      mkdir -p ${output-dir}
      cp /tmp/latest-screenshot.png ${output-dir}/${format}.png
    fi
  ''
)
