# Concordia

@@marginnote
~~~<img src="/img/concord.png" style="width: 100%; display: block;">~~~
@@
All of Concordia lies within 200 miles of Boston except for northeastern Maine, which is sparsely settled. It is bordered by Quebec, Canada on the north and by New Brunswick, Canada on the east. It borders New York on the west and south. Approximately 75% of the region is forested.
~~~
<iframe role="img" src="data:text/html,%3C%21DOCTYPE%20html%3E%0A%3Chtml%3E%0A%3Chead%3E%0A%20%20%3Ctitle%3ELeaflet%20Template%3C%2Ftitle%3E%0A%20%20%3Clink%20rel%3D%22stylesheet%22%20href%3D%22https%3A%2F%2Funpkg%2Ecom%2Fleaflet%401%2E9%2E4%2Fdist%2Fleaflet%2Ecss%22%20%2F%3E%0A%20%20%3Cscript%20src%3D%22https%3A%2F%2Funpkg%2Ecom%2Fleaflet%401%2E9%2E4%2Fdist%2Fleaflet%2Ejs%22%3E%3C%2Fscript%3E%0A%20%20%3Cstyle%3E%0A%20%20%20%20body%2C%20html%20%7B%0A%20%20%20%20%20%20%20%20margin%3A%200%3B%0A%20%20%20%20%20%20%20%20padding%3A%200%3B%0A%20%20%20%20%20%20%20%20width%3A%20100%25%3B%0A%20%20%20%20%20%20%20%20height%3A%20100%25%3B%0A%20%20%20%20%7D%0A%20%20%20%20%2Eflex%2Dcontainer%20%7B%0A%20%20%20%20%20%20%20%20display%3A%20flex%3B%0A%20%20%20%20%20%20%20%20align%2Ditems%3A%20flex%2Dstart%3B%0A%20%20%20%20%20%20%20%20width%3A%20100%25%3B%0A%20%20%20%20%20%20%20%20height%3A%20100%25%3B%0A%20%20%20%20%7D%0A%20%20%20%20%23map%20%7B%0A%20%20%20%20%20%20%20%20flex%3A%201%3B%0A%20%20%20%20%20%20%20%20height%3A%20100vh%3B%0A%20%20%20%20%20%20%20%20margin%3A%200%3B%0A%20%20%20%20%7D%0A%20%20%20%20%2Etables%2Dcontainer%20%7B%0A%20%20%20%20%20%20%20%20display%3A%20flex%3B%0A%20%20%20%20%20%20%20%20flex%2Dwrap%3A%20wrap%3B%0A%20%20%20%20%20%20%20%20gap%3A%2010px%3B%0A%20%20%20%20%20%20%20%20padding%3A%2020px%3B%0A%20%20%20%20%7D%0A%20%20%20%20table%20%7B%0A%20%20%20%20%20%20%20%20border%2Dcollapse%3A%20collapse%3B%0A%20%20%20%20%20%20%20%20width%3A%20200px%3B%0A%20%20%20%20%7D%0A%20%20%20%20th%2C%20td%20%7B%0A%20%20%20%20%20%20%20%20border%3A%201px%20solid%20black%3B%0A%20%20%20%20%20%20%20%20padding%3A%208px%3B%0A%20%20%20%20%20%20%20%20text%2Dalign%3A%20right%3B%0A%20%20%20%20%7D%0A%20%20%20%20%2Elegend%20%7B%0A%20%20%20%20%20%20%20%20padding%3A%206px%208px%3B%0A%20%20%20%20%20%20%20%20background%3A%20white%3B%0A%20%20%20%20%20%20%20%20background%3A%20rgba%28255%2C255%2C255%2C0%2E9%29%3B%0A%20%20%20%20%20%20%20%20box%2Dshadow%3A%200%200%2015px%20rgba%280%2C0%2C0%2C0%2E2%29%3B%0A%20%20%20%20%20%20%20%20border%2Dradius%3A%205px%3B%0A%20%20%20%20%20%20%20%20line%2Dheight%3A%2024px%3B%0A%20%20%20%20%7D%0A%3C%2Fstyle%3E%0A%3C%2Fhead%3E%0A%3Cbody%3E%0A%3Cdiv%20class%3D%22flex%2Dcontainer%22%3E%0A%20%20%3Cdiv%20id%3D%22map%22%3E%0A%20%20%3C%2Fdiv%3E%0A%20%20%3Cdiv%20class%3D%22tables%2Dcontainer%22%3E%0A%20%20%3C%2Fdiv%3E%0A%3C%2Fdiv%3E%0A%3Cscript%3E%0Avar%20mapOptions%20%3D%20%7B%0A%20%20%20center%3A%20%5B42%2E36027777777778%2C%20%2D71%2E05777777777777%5D%2C%0A%20%20%20zoom%3A%207%0A%7D%3B%0Avar%20map%20%3D%20new%20L%2Emap%28%27map%27%2C%20mapOptions%29%3B%0A%0AL%2EtileLayer%28%27https%3A%2F%2F%7Bs%7D%2Etile%2Eopenstreetmap%2Eorg%2F%7Bz%7D%2F%7Bx%7D%2F%7By%7D%2Epng%27%2C%20%7B%0A%20%20%20%20attribution%3A%20%27%C2%A9%20OpenStreetMap%20contributors%27%2C%0A%20%20%20%20maxZoom%3A%2019%0A%7D%29%2EaddTo%28map%29%3B%0A%0Avar%20marker%20%3D%20L%2Emarker%28%5B42%2E36027777777778%2C%20%2D71%2E05777777777777%5D%29%3B%0Amarker%2EaddTo%28map%29%3B%0Amarker%2EbindPopup%28%27Boston%27%29%2EopenPopup%28%29%3B%0A%0Afunction%20milesToMeters%28miles%29%20%7B%0A%20%20%20return%20miles%20%2A%201609%2E34%3B%0A%7D%0A%0Avar%20colors%20%3D%20%5B%27%23D32F2F%27%2C%20%27%23388E3C%27%2C%20%27%231976D2%27%2C%20%27%23FBC02D%27%2C%20%27%237B1FA2%27%5D%3B%0Avar%20radii%20%3D%20%5B50%2C%20100%2C%20200%5D%2Emap%28Number%29%3B%0A%0Aradii%2EforEach%28function%28radius%2C%20index%29%20%7B%0A%20%20%20%20var%20circle%20%3D%20L%2Ecircle%28%5B42%2E36027777777778%2C%20%2D71%2E05777777777777%5D%2C%20%7B%0A%20%20%20%20%20%20%20%20radius%3A%20milesToMeters%28radius%29%2C%0A%20%20%20%20%20%20%20%20color%3A%20colors%5Bindex%5D%2C%0A%20%20%20%20%20%20%20%20weight%3A%202%2C%0A%20%20%20%20%20%20%20%20fill%3A%20true%2C%0A%20%20%20%20%20%20%20%20fillColor%3A%20colors%5Bindex%5D%2C%0A%20%20%20%20%20%20%20%20fillOpacity%3A%200%2E05%2C%0A%20%20%20%20%20%20%20%20interactive%3A%20false%0A%20%20%20%20%7D%29%2EaddTo%28map%29%3B%0A%20%20%20%20console%2Elog%28%27Added%20circle%3A%27%2C%20radius%2C%20%27miles%27%29%3B%0A%7D%29%3B%0A%0Avar%20legend%20%3D%20L%2Econtrol%28%7Bposition%3A%20%27bottomleft%27%7D%29%3B%0Alegend%2EonAdd%20%3D%20function%20%28map%29%20%7B%0A%20%20%20%20var%20div%20%3D%20L%2EDomUtil%2Ecreate%28%27div%27%2C%20%27legend%27%29%3B%0A%20%20%20%20div%2EinnerHTML%20%3D%20%27%3Cstrong%3EMiles%20from%20center%3C%2Fstrong%3E%3Cbr%3E%27%3B%0A%20%20%20%20radii%2EforEach%28function%28radius%2C%20i%29%20%7B%0A%20%20%20%20%20%20%20%20div%2EinnerHTML%20%2B%3D%0A%20%20%20%20%20%20%20%20%20%20%20%20%27%3Ci%20style%3D%22background%3A%27%20%2B%20colors%5Bi%5D%20%2B%20%27%3B%20width%3A%2018px%3B%20height%3A%2018px%3B%20float%3A%20left%3B%20margin%2Dright%3A%208px%3B%20opacity%3A%200%2E7%3B%22%3E%3C%2Fi%3E%20%27%20%2B%0A%20%20%20%20%20%20%20%20%20%20%20%20radius%20%2B%20%27%3Cbr%3E%27%3B%0A%20%20%20%20%7D%29%3B%0A%20%20%20%20return%20div%3B%0A%7D%3B%0Alegend%2EaddTo%28map%29%3B%0A%0A%2F%2F%20Add%20resize%20handler%20to%20ensure%20map%20fills%20container%20after%20window%20resize%0Awindow%2EaddEventListener%28%27resize%27%2C%20function%28%29%20%7B%0A%20%20%20%20map%2EinvalidateSize%28%29%3B%0A%7D%29%3B%0A%3C%2Fscript%3E%0A%3C%2Fbody%3E%0A%3C%2Fhtml%3E%0A" width="800" height="800"></iframe>
~~~
## Population
New England is home to approximately 15.1 million in the six states of Connecticut, New Hampshire, Maine, Massachusetts, Rhode Island and Vermont. As a single state, it would be the fifth largest, behind New York and ahead of Pennsylvania. It has about 4.5% of the total population of the United States.

Its population is concentrated along the Northeast Corridor from Boston to New York. Massachusetts has a population size similar to Indiana and Tennessee. Connecticut falls between Utah and Oklahoma. Maine and New Hampshire are both comparable to Hawaii. Rhode Island has the approximate population of Delaware and Montana. Vermont has a larger population than Wyoming and a smaller population than the District of Columbia.
![Concordia at night](/img/concord_night.png)

Its closest global peer nation in terms of population is Guinea. It is roughly the same size as Denmark, Norway and Finland combined or Sweden and one of those other Scandinavian states.

### Age Structure
![Concordia regional age pyramid](/img/concord_region_age.png)	
Compared to the United States as a whole, New England has a younger population, although that varies by state.
![Concordia state age pyramids](/img/concord_state_age/png)
The age distribution differences are reflected in the dependency ratios for the New England states.
<dependency ratio table here>
A lower dependency ratio indicates a higher proportion of the population in the 16-65 age group. For the US as a whole, the ratio is 54.86.

### Fertility
The estimated total fertility rate per thousand women for the United State is approximately 1.62, which is less than the 2.1 rate to maintain population levels in the absence of migration.

@@marginnote Sources: [Hamilton BE, Martin JA, Osterman MJK. Births: provisional data for 2023. Vital Statistics Rapid Release; no 35. April 2024](https://dx.doi.org/10.15620/%20cdc/151797); Gokhale, Jagadeesh, [U.S. Demographic Projections: With and Without Immigration, 2024](https://budgetmodel.wharton.upenn.edu/issues/2024/3/22/us-demographic-projections-with-and-without-immigration)@@

Together with the District of Columbia and Oregon, the New England states have the lowest total fertility rates in the United States. Massachusetts and Connecticut have death rates below the national average, while the other New England states have rates that are higher.
@@marginnote Sources: Sources: Centers for Disease Control and Prevention, National Center for Health Statistics. National Vital Statistics System, Mortality 2018-2023 on CDC WONDER Online Database, released in 2024. Data are from the [Multiple Cause of Death Files, 2018-2023](Multiple Cause of Death Files, 2018-2023, as compiled from data provided by the 57 vital statistics jurisdictions through the Vital Statistics Cooperative Program.), as compiled from data provided by the 57 vital statistics jurisdictions through the Vital Statistics Cooperative Program.@@

In the New England States

total fertility table here

@@marginnote Source: [Maine State of Domestic Trade Annual Report 2024](https://www.maine.gov/decd/sites/maine.gov.decd/files/inline-files/Final%20Report%20-%202024%20Annual%20Macro%20Update%20-%20Maine%20DECD.pdf)@@
### Growth
## Economy
### Manufacturing
### Food
### Resource Extraction
### Services
### Balance of Trade

## Assessment
	