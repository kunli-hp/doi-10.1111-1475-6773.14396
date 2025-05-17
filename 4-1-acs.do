* ==============================================================================

* CHC Quality Competition: Do File Sequence #4.1

* This do-file processes the ACS data at the ZCTA level.

* ==============================================================================


clear
set more off


****	Set working directory
cd "${rdata}/acs/"


****	Process data
**	Race/ethnicity
forvalues i = 4/8{
	import delimited ACSDT5Y201`i'.B02001-Data.csv, varnames(1) clear
	keep geo_id name b02001_001e b02001_002e
	
	gen zcta = subinstr(name,"ZCTA5 ","",.)
	replace zcta = subinstr(zcta," ","",.)
	
	drop geo_id name
	drop if _n == 1
	
	gen year = 201`i'
	rename b02001_001e total_pop_zcta
	rename b02001_002e total_white_zcta
	save "${cdata}/race_201`i'.dta", replace
}

*	Append data
use "${cdata}/race_2014.dta", clear
forvalues i = 5/8{
	append using "${cdata}/race_201`i'.dta".dta, force
}

save "${cdata}/acs_1418.dta", replace

**	Poverty
forvalues i = 7/8{
	import delimited ACSST5Y201`i'.S1701-Data.csv, varnames(1) clear
	keep name s1701_c03_001e
	
	gen zcta = subinstr(name,"ZCTA5 ","",.)
	replace zcta = subinstr(zcta," ","",.)
	
	drop if _n == 1
	rename s1701_c03_001e povertyrate_zcta
	drop name
	
	gen year = 201`i'
	save "${cdata}/poverty_201`i'.dta", replace
	clear
}

*	Append data
use "${cdata}/poverty_2014.dta"
forvalues i = 5/8{
	append using "${cdata}/poverty_201`i'.dta", force
}


**	Merge with existing age and sex composition file
merge 1:1 zcta year using "${cdata}/acs_1418.dta", nogen
merge 1:1 zcta year using "${cdata}/sex_age_1418.dta", nogen

*	Save
save "${cdata}/acs_1418.dta", replace
