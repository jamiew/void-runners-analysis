#!/bin/bash

start_id=1
stop_id=10

# fetch our ship metadata
mkdir ships
for id in $(seq $start_id $stop_id); do
  file="ships/$id.json"
  if [ -e "$file" ]; then echo "$file already downloaded"; continue; fi
  curl -s https://voidrunners.io/api/ships/$id > "$file"
  sleep 0.25
done

# combine the json together for easier analysis
# FIXME id=1 not being put into the .ships array for some reason
output="json.json"
echo '{"ships": []}' > "$output"
jq '.ships += [inputs]' "$output" ships/*.json > "$output"
echo "$(jq length $output) entries in $output"

# convert it to a CSV
csv="csv.csv"
jq '.ships | map(.id), map(.stats .registered_color), map(.stats .capacity), map(.stats .efficiency), map(.stats .speed) | @csv' $output > "$csv"

