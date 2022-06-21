#!/bin/bash

start_id=1
stop_id=$(curl -s https://voidrunners.io/api/total-supply)
echo "start_id=$start_id stop_id=$stop_id"

# fetch our ship metadata
mkdir -p ships
for id in $(seq $start_id $stop_id); do
  file="ships/$id.json"
  if [ -e "$file" ]; then continue; fi
  curl -s https://voidrunners.io/api/ships/$id >"$file"
  echo -n "."
  sleep 0.25
done

# combine the json together for easier analysis
# FIXME id=1 not being put into the .ships array for some reason
output="json.json"
echo '{"ships": []}' >"$output"
# jq '.ships |= . + [inputs]' "$output" ships/*.json >"$output"
jq '.ships += [inputs]' "$output" ships/*.json >"$output"
echo "$(jq '.ships' $output | jq length) entries in $output"

# convert it to a CSV
csv="csv.csv"
# jq -r '.ships | map(.id), map(.stats .ship_class), map(.stats .registered_color), map(.stats .capacity), map(.stats .efficiency), map(.stats .speed) | @csv' $output > "$csv"
jq -r '.ships[] | [.id, .stats .ship_class, .stats .registered_color, .stats .capacity, .stats .efficiency, .stats .speed] | @csv' "$output" >"$csv"
