#!/bin/bash

#default args
keyword="pizza"
city="Gdansk"
events_found=false


function show_help {
  echo 
  echo "usage: $0 -d <date> -r <day_range> -k <keyword> -c <city>"
  echo "example: $0 -d 2023-10-24 -r 7 -k pizza -c Gdansk"
  echo "options:"
  echo "  -d <date>           Event date (in the format YYYY-MM-DD)"
  echo "  -r <day_range>      Number of days (0 means only one date)"
  echo "  -k <keyword>        Keyword to search for"
  echo "  -c <city>           City for filtering"
  echo "  -h, --help          Display this help and exit"
}

analyze_event_page() {
  event_url="$1"

  event_content=$(curl -s -L --compressed "$event_url")

  event_name=$(echo "$event_content" | grep -o -P '<h1.*>.*</h1>' | sed -e 's/<[^>]*>//g')
  event_info=$(echo "$event_content" | grep -o -P '{.*"@type":"Event".*?}}<')

  date_block=$(echo "$event_info" | grep -o -P 'startDate.*endDate[^,]*')
  time_data="${date_block:12:10}, ${date_block:23:5}-${date_block:64:5}"

  latitude=$(echo "$event_info" | grep -o -P 'latitude":[^,]*' | sed 's/latitude"://') 
  longitude=$(echo "$event_info" | grep -o -P 'longitude":[^}]*' | sed 's/longitude"://') 
  location=$(echo "$event_info" | grep -o -P 'location.*?Place.*?name[^,]*' | grep -o -P 'name[^,]*' | sed 's/name"://') 
  address=$(echo "$event_info" | grep -o -P 'location[^<]*' | grep -o -P 'streetAddress":"[^"]*' | sed 's/streetAddress":"//') 

  echo "Nazwa: $event_name"
  echo "Data: $time_data"
  echo "Nazwa Lokalizacji: ${location:1:-1}"
  echo "Adres: $address"
  echo "URL: $1"
  echo "URL MAPY: https://www.google.com/maps/place/$latitude,$longitude"

  echo

}


# arg --help check
for arg in "$@"; do
  if [ "$arg" = "--help" ]; then
    show_help
    exit 0
  fi
done


while getopts "d:r:k:c:h" opt; do
  case $opt in
    d)
      date="$OPTARG"
      ;;
    r)
      date_range="$OPTARG"
      ;;
    k)
      keyword="$OPTARG"
      ;;
    c)
      city="$OPTARG"
      ;;
    h)
      show_help
      exit 0
      ;;
    \?)
      show_help
      exit 1
      ;;
  esac
done

# required args
if [ -z "$date" ] || [ -z "$date_range" ]; then
echo "Options -d (date) and -r (day range) are required." >&2
  exit 1
fi

echo "Stat date: $date"
echo "Day range: $date_range"
echo "Keyword: $keyword"
echo "City: $city"
echo 


for ((i=0; i<date_range; i++)); do

  start_date=$(date -d "$date + $((i-1)) day" "+%Y-%m-%dT18:00:00-04:00")
  end_date=$(date -d "$date + $i day" "+%Y-%m-%dT17:59:00-04:00")

  url="https://www.meetup.com/find/?source=EVENTS&eventType=inPerson&keywords=$keyword&location=pl--$city&customStartDate=$start_date&customEndDate=$end_date"
  #echo "$url"
  page_content=$(curl -s "$url")

  event_urls=$(echo "$page_content" | grep -o -P 'href="https://www.meetup.com/[^"]+/events/[0-9]+/"' | sort | uniq | cut -d '"' -f 2 | cut -d '"' -f 1)


  for event_url in $event_urls; do
    events_found=true
    analyze_event_page "$event_url"
  done

done

if [ "$events_found" = false ]; then
  echo "Events in $city not found. (for keyword: $keyword)"
fi
