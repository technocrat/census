#! /bin/sh
#
# World Bank 2024 estimate from https://www.gapminder.org/data/
# URL: blob:https://www.gapminder.org/f8098849-c15a-4df6-8b39-4b5f6dce0a73
#
# NOTE: Before running this script, you must first download the data from
# gapminder.org and save it to ../data/world_pop24.csv
#
# Check if input file exists
INPUT_FILE="../data/world_pop24.csv"
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file $INPUT_FILE does not exist."
    echo "Please download the data from gapminder.org first."
    exit 1
fi

# Check if input file has content
if [ ! -s "$INPUT_FILE" ]; then
    echo "Error: Input file $INPUT_FILE is empty."
    echo "Please download the data from gapminder.org first."
    exit 1
fi

xsv select 1,226 "$INPUT_FILE" | awk -F, '
BEGIN { OFS="," }
NR==1 { print "country,population"; next }
{
    if ($2 ~ /B/) {
        gsub(/B/,"",$2)
        $2 = int($2 * 1000000000)
    } else if ($2 ~ /M/) {
        gsub(/M/,"",$2)
        $2 = int($2 * 1000000)
    } else if ($2 ~ /k/) {
        gsub(/k/,"",$2)
        $2 = int($2 * 1000)
    }
    if ($2 != "" && $1 != "") {
        print $1,$2
    }
}' > world_pop24.csv && cat world_pop24.csv
