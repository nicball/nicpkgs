token=${TG_BOT_TOKEN:?TG_BOT_TOKEN not set}
api="https://api.telegram.org/bot"$token
call() {
  curl -s "${@:2}" "$api/$1"
}
log() {
  [[ -v DEBUG ]] && echo "$@" 1>&2
  return 0
}
offset=""
while true; do
  res="$(call "getUpdates?limit=1&offset=$offset")"
  if [[ "$(echo "$res" | jq .ok)" != true || "$(echo "$res" | jq '.result | length')" = 0 ]]; then
    log no update
    continue
  fi
  update="$(echo "$res" | jq .result[0])"
  offset="$(echo "$update" | jq .update_id)"
  offset=$((offset + 1))
  cid="$(echo "$update" | jq .message.chat.id)"
  mid="$(echo "$update" | jq .message.message_id)"
  text="$(echo "$update" | jq -r .message.text)"
  log "text:$text"
  if [[ "${text:0:8}" = "/perform" ]]; then
    score="${text:8}"
    if [[ "${score:0:11}" = "@mozhengbot" ]]; then
      score="${score:11}"
    fi
    log "score:$score"
    filebase=msg_"$cid"_"$mid"
    log "filebase:$filebase"
    printf '\\version "2.22.2" \\include "%s" \\score{ \\layout{} \\midi{} { %s } }' "$common" "$score" > "$filebase".ly
    log="$(lilypond -dbackend=eps -dresolution=300 --png -lERROR "$filebase".ly 2>&1; exit 0)"
    if [[ -n "$log" ]]; then
      call "sendMessage?chat_id=$cid&reply_to_message_id=$mid" -G --data-urlencode "text=$log"
    else
      call "sendPhoto?chat_id=$cid&reply_to_message_id=$mid" -F photo=@"$filebase".png
      timidity "$filebase".midi -Ow -o - | ffmpeg -loglevel error -i - "$filebase".mp3
      call "sendAudio?chat_id=$cid&reply_to_message_id=$mid" -F audio=@"$filebase".mp3
    fi
  fi
  sleep 0.1
  log "offset:$offset"
done
