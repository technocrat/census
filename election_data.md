Notes on processing of 2024 county level election results from
[United States General Election Presidential Results by District, Ward, or County from 2008 to 2024](https://tonmcg.github.io/US_County_Level_Election_Results_08-24/)

# Importing CSV Data into PostgreSQL

~~~
<pre>
sql
   BEGIN;
   CREATE TEMP TABLE temp_gop (geoid varchar(5), value bigint);
   COPY temp_gop FROM '/Users/ro/projects/census/data/2024_gop.csv' WITH (FORMAT csv, HEADER true);
   INSERT INTO census.variable_data (geoid, variable_name, value)
   SELECT t.geoid, 'republican', t.value
   FROM temp_gop t
   WHERE EXISTS (SELECT 1 FROM census.counties c WHERE c.geoid = t.geoid);
   DROP TABLE temp_gop;
   COMMIT;
   BEGIN;
   CREATE TEMP TABLE temp_dem (geoid varchar(5), value bigint);
   COPY temp_dem FROM '/Users/ro/projects/census/data/2024_dem.csv' WITH (FORMAT csv, HEADER true);
   INSERT INTO census.variable_data (geoid, variable_name, value)
   SELECT t.geoid, 'democratic', t.value
   FROM temp_dem t
   WHERE EXISTS (SELECT 1 FROM census.counties c WHERE c.geoid = t.geoid);
   DROP TABLE temp_dem;
   COMMIT;
</pre>
~~~
Finding Missing GEOIDs
~~~
<pre>
   BEGIN;
   CREATE TEMP TABLE temp_gop (geoid varchar(5), value bigint);
   COPY temp_gop FROM '/Users/ro/projects/census/data/2024_gop.csv' WITH (FORMAT csv, HEADER true);
   SELECT t.geoid FROM temp_gop t LEFT JOIN census.counties c ON t.geoid = c.geoid WHERE c.geoid IS NULL ORDER BY t.geoid;
   DROP TABLE temp_gop;
   COMMIT;
</pre>
~~~

Found 44 missing geoids that weren't inserted into the database:
~~~<pre>
02001   02002   02003   02004   02005   02006   02007   02008   02009   02010
02011   02012   02014   02015   02017   02018   02019   02021   02022   02023
02024   02025   02026   02027   02028   02029   02030   02031   02032   02033
02034   02035   02036   02037   02038   02039   02040   11002   11003   11004
11005   11006   11007   11008
</pre>
~~~
- Most missing geoids start with "02" (Alaska's FIPS state code)
- A few start with "11" (District of Columbia's FIPS state code)
- These likely represent boroughs/census areas in Alaska and wards in DC that aren't defined as counties in the census.counties table

HI & AK state election results missing from county returns:
[2024 United States presidential election](https://en.wikipedia.org/wiki/2024_United_States_presidential_election)
AK GOP 184458 DEM 140026
HI GOP 193661 DEM 313044
   
