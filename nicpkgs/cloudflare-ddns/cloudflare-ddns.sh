function cf() {
  local method=$1
  local function=$2
  local query=$3
  local extra_args=("${@:4}")
  curl -s -X "$method" "https://api.cloudflare.com/client/v4/$function?$query" -H "X-Auth-Email: @authEmail@" -H "X-Auth-Key: @authKey@" -H "Content-Type: application/json" "${extra_args[@]}"
}
my_ip=$(curl --noproxy '*' -s -4 ifconfig.co)
zone_json=$(cf GET zones "name=@zoneName@")
zone_id=$(echo "$zone_json" | jq -r ".result[0].id")
record_json=$(cf GET "zones/$zone_id/dns_records" "name=@recordName@&type=A")
record_id=$(echo "$record_json" | jq -r ".result[0].id")
results=$(cf PATCH "zones/$zone_id/dns_records/$record_id" "" --data "{\"content\":\"$my_ip\"}")
log="@log@"
if [[ -n "$log" ]]; then
  {
    date
    echo "zone=$zone_json"
    echo "record=$record_json"
    echo "my_ip=$my_ip"
    echo "results=$results"
    echo
  } >> "$log"
fi
