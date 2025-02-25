#! /usr/bin/sh
# World Bank 2024 estimate from https://www.gapminder.org/data/
xsv select 1,226 ../data/world_pop.csv | awk -F, '
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