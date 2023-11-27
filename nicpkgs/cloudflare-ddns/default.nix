{ writeShellApplication
, substituteAll
, curl
, jq
, lib
}:

{ auth-key ? "badkey"
, auth-email ? "nonexistent@example.com"
, zone-name ? "badzone"
, record-name ? "badrecord"
, enable-log ? false
, log-path ? ""
, enable-ipv4 ? true
, enable-ipv6 ? true
}:

writeShellApplication {
  name = "cloudflare-ddns";
  runtimeInputs = [ curl jq ];
  text = lib.concatStrings [
    ''
      function cf() {
        local method=$1
        local function=$2
        local query=$3
        local extra_args=("''${@:4}")
        curl -s -X "$method" "https://api.cloudflare.com/client/v4/$function?$query" -H "X-Auth-Email: ${auth-email}" -H "X-Auth-Key: ${auth-key}" -H "Content-Type: application/json" "''${extra_args[@]}"
      }
    ''

    (lib.optionalString enable-ipv4 ''
      my_ip=$(curl --noproxy '*' -s -4 ifconfig.co)
      zone_json=$(cf GET zones "name=${zone-name}")
      zone_id=$(echo "$zone_json" | jq -r ".result[0].id")
      record_json=$(cf GET "zones/$zone_id/dns_records" "name=${record-name}&type=A")
      record_id=$(echo "$record_json" | jq -r ".result[0].id")
      results=$(cf PATCH "zones/$zone_id/dns_records/$record_id" "" --data "{\"content\":\"$my_ip\"}")
      echo "$results" > /dev/null
    '')
    
    (lib.optionalString (enable-ipv4 && enable-log) ''
      {
        date
        echo "zone=$zone_json"
        echo "record=$record_json"
        echo "my_ip=$my_ip"
        echo "results=$results"
        echo
      } >> "${log-path}"
    '')

    (lib.optionalString enable-ipv6 ''
      my_ip6=$(curl --noproxy '*' -s -6 ifconfig.co)
      zone_json=$(cf GET zones "name=${zone-name}")
      zone_id=$(echo "$zone_json" | jq -r ".result[0].id")
      record_json=$(cf GET "zones/$zone_id/dns_records" "name=${record-name}&type=AAAA")
      record_id=$(echo "$record_json" | jq -r ".result[0].id")
      results=$(cf PATCH "zones/$zone_id/dns_records/$record_id" "" --data "{\"content\":\"$my_ip6\"}")
      echo "$results" > /dev/null
    '')

    (lib.optionalString (enable-ipv6 && enable-log) ''
      {
        date
        echo "zone=$zone_json"
        echo "record=$record_json"
        echo "my_ip6=$my_ip6"
        echo "results=$results"
        echo
      } >> "${log-path}"
    '')
  ];
}
