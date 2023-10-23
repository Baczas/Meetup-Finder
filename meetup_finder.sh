#!/bin/bash

keyword="pizza"
city="Gdansk"
events_found=false


for ((i=0; i<date_range; i++)); do

start_date=$(date -d "$date + $((i-1)) day" "+%Y-%m-%dT18:00:00-04:00")
end_date=$(date -d "$date + $i day" "+%Y-%m-%dT17:59:00-04:00")


url="https://www.meetup.com/find/?source=EVENTS&eventType=inPerson&keywords=$keyword&location=pl--$city&customStartDate=$start_date&customEndDate=$end_date"

page_content=$(curl -s "$url")

event_urls=$(echo "$page_content" | grep -o -P 'href="https://www.meetup.com/[^"]+/events/[0-9]+/"' | sort | uniq | cut -d '"' -f 2 | cut -d '"' -f 1)

for event_url in $event_urls; do
  echo "Event URL: $event_url"
  events_found=true
  
  python - << EOF
import requests
from bs4 import BeautifulSoup
event_content = requests.get("$event_url").text

event_soup = BeautifulSoup(event_content, 'html.parser')

event_name = event_soup.find('h1').get_text()
print("Name:", event_name)

venue_info = event_soup.find('div', class_='pl-4').get_text()
print("Address:", venue_info)

print("Date: ${end_date::10}")

print()

EOF

done

done

if [ "$events_found" = false ]; then
  echo "Events not found."
fi