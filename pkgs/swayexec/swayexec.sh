cmd=()
for i in "$@"; do
  cmd=("${cmd[@]}" "$(printf "%q" "$i")")
done
exe="$(mktemp /tmp/swayexec-XXXXXXXX.sh)"
chmod +x "$exe"
printf "#!/bin/sh\n%s\nrm %s" "${cmd[*]}" "$exe"> "$exe"
swaymsg exec -- "$exe"
