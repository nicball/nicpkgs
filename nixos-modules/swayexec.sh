cmd=()
for i in "$@"; do
  cmd=("${cmd[@]}" "$(printf '%q' "$i")")
done
exe="$(mktemp /tmp/swayexec-XXXXXXXX.sh)"
chmod +x "$exe"
printf '#!/bin/sh\nexec &> %s.log\nexec %s\n' "$exe" "${cmd[*]}" > "$exe"
swaymsg exec -- "$exe"
