# Connecticut Counties to Regions Crosswalk

ACS uses the nine regional units that replaced Connecticut counties for most purposes but BLS still uses the traditional counties. There are some minor misalignments, but the big issue is Fairfield County was bifurcated. It will be addressed by combining the Western Connecticut and Greater Bridgeport ACS units into a single synthetic council of government "Greenwich". 

Connecticut's transition from eight historical counties to nine planning regions (or Councils of Governments, COGs) as county-equivalents for Census purposes does not follow a one-to-one correspondence. The new planning regions often overlap with the boundaries of the old counties but also divide some counties into multiple regions. Here is a general outline of how the eight counties correspond to the nine planning regions:

1. **Fairfield County**: Split into two planning regions:
   - Western Connecticut COG (WestCOG)
   - Greater Bridgeport COG

2. **Hartford County**: Primarily aligns with the Capitol Region COG (CRCOG), though parts may overlap with other regions.

3. **Litchfield County**: Corresponds to the Northwest Hills COG (NHCOG).

4. **Middlesex County**: Divided between:
   - Lower Connecticut River Valley COG (RiverCOG)
   - Naugatuck Valley COG (NVCOG)

5. **New Haven County**: Mostly aligns with the South Central Regional COG (SCRCOG), though parts also fall under NVCOG.

6. **New London County**: Corresponds to the Southeastern Connecticut COG (SECCOG).

7. **Tolland County**: Primarily falls under the Capitol Region COG (CRCOG).

8. **Windham County**: Corresponds to the Northeastern Connecticut COG (NECCOG).

This reorganization reflects an effort to better align Census data with Connecticut's current administrative and planning structures, as counties ceased functioning as government entities in 1960. The nine planning regions now serve as geographic units for regional coordination and statistical purposes[1][2][3].

The [Connecticut Crosswalk File](https://mcdc.missouri.edu/cgi-bin/broker?_PROGRAM=apps.geocorr2022.sas&_SERVICE=MCDC_long&_debug=0&state=Ct09&g1_=county&g2_=ctregion&wtvar=pop20&nozerob=1&fileout=1&filefmt=csv&lstfmt=html&title=&counties=&metros=&places=&oropt=&latitude=&longitude=&distance=&kiloms=0&locname=) apportions the state's county-level population to the Connecticut planning regions and is used to create the `ct_gdp.csv` file in the `create_gdp_database.jl` script to apportion GDP proportionally to population.

Citations:
[1] https://www.census.gov/programs-surveys/acs/technical-documentation/user-notes/2023-01.html
[2] https://www.caliper.com/learning/where-are-the-counties-for-connecticut/
[3] https://portal.ct.gov/governor/news/press-releases/2022/06-2022/governor-lamont-announces-census-bureau-approves-proposal-for-planning-regions
[4] https://www.darienct.gov/DocumentCenter/View/791/FAQ-Memo-December-2020-PDF
[5] https://appliedgeographic.com/2023/04/changing-of-the-counties/
[6] https://www.ctpublic.org/news/2022-06-16/u-s-census-approves-connecticut-request-for-nine-planning-regions-but-opinions-differ-on-the-impact
[7] https://www.ctdata.org/blog/geographic-resources-for-connecticuts-new-county-equivalent-geography
[8] https://www.bls.gov/cew/classifications/areas/new-2024-connecticut-counties.htm
[9] https://www.ctdata.org/blog/census-bureau-releases-first-population-estimates-for-connecticuts-county-equivalent-planning-regions
[10] https://portal.ct.gov/opm/igpp/org/planning-regions/planning-regions---overview
[11] https://data.census.gov/map?q=Connecticut&mode=results
[12] https://www.census.gov/geographies/reference-files/time-series/geo/relationship-files.html
[13] https://storymaps.arcgis.com/stories/23bc7986213547a79cb8a5dafa84d68d
[14] https://portal.ct.gov/-/media/OPM/IGPP/ORG/County-Equivalency/County-Equivalency-Request-Letter-to-US-Census-Bureau-81419-signed.pdf
[15] https://libguides.ctstatelibrary.org/regionalplanning/maps
[16] https://www.census.gov/geographies/reference-files/time-series/geo/relationship-files.2020.html
