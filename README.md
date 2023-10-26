# Meetup Event Finder

This Bash script is designed to scrape Meetup.com for events in a specified city and time range, using a provided keyword for filtering. It fetches event details, such as the event name, date and time, location, and URL, and provides a Google Maps link for each event's location.

## Usage

To use this script, follow these steps:

1. Make sure you have Bash and the required dependencies installed, especially `curl`.

2. Clone or download this repository to your local machine.

3. Open a terminal and navigate to the directory where the script is located.

4. Run the script with the desired options. The available options are as follows:

   - `-d <date>`: Event date in the format YYYY-MM-DD.
   - `-r <day_range>`: Number of days (0 means only one date).
   - `-k <keyword>`: Keyword to search for (default: "pizza").
   - `-c <city>`: City for filtering (default: "Gdansk").
   - `-h, --help`: Display the help message.

   Example usage:

   ```bash
   ./script.sh -d 2023-10-24 -r 7 -k pizza -c Gdansk

 
# Warning

Please be aware that when changing the city for event scraping, you should double-check the generated URL from the `$url` variable by pasting it into a web browser. (Uncomment line 102 to print URL links to the terminal.)
