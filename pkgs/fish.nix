{ super }:

let cmds = ''
  # emacs style movements
  if status is-interactive
    bind alt-left prevd-or-backward-word
    bind alt-right nextd-or-forward-word
    bind alt-backspace backward-kill-word
    bind alt-delete kill-word
    bind ctrl-left backward-token
    bind ctrl-right forward-token
    bind ctrl-backspace backward-kill-token
    bind ctrl-h backward-kill-token
    bind ctrl-delete kill-token
    bind ctrl-alt-h backward-kill-word
  end
''; in

super.fish.overrideAttrs (final: prev: {
  postInstall = (prev.postInstall or "") + ''
    cat >> $out/etc/fish/config.fish <<EOF
    ${cmds}
    EOF
  '';
})
