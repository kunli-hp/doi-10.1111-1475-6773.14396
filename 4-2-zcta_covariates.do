* ==============================================================================

* CHC Quality Competition: Do File Sequence #4.2

* This do-file generates market-level covariates for each CHC.

* ==============================================================================

****	Inputs: 1) HHI data files derived from Do File #1
****		2) ACS files derived from Do File #4.1
****	Outputs: Market-level covariates (each row corresponds to a CHC-centric market)


clear
set more off


****	Set working directory
cd "${cdata}/"


****	Generate market-level covariates by aggregating ZCTA-level variables to CHC market-level
use hhi_14_18.dta, clear

**	Cleaning
*	Drop CHC-ZIP with zero patient visit
drop if TotalPatientChcZip == 0
drop if TotalPatientChcZip == .
*	Drop other/unknown zip code
keep if zipcodetype == "ZipCode"

**	Merge with ZCTA-level covariates
*	ZIP code-ZCTA crosswalk
merge m:1 year zipcode using zip_zcta_1418.dta, nogen keep(master match)
*	ACS data
merge m:1 year zcta using acs_1418.dta, nogen keep(master match)


**	Race/ethnicity
preserve
	drop povertyrate_zcta
	drop if total_pop_zcta == ""
	*	Keep only ZIP codes included in the index CHC's market
	drop if rule_market==0
	
	*	Weighted by patient volume
	bysort id year: egen total_c = sum(TotalPatientChcZip)
	gen share_c = TotalPatientChcZip / total_c

	local vars total_pop_zcta total_white_zcta pop_male pop_female pop_under18 pop_above64
	foreach i of local vars{
		destring `i', replace
		gen `i'_w = `i' * share_c
	}
	collapse (sum) total_pop_zcta_w total_white_zcta_w pop_male_w pop_female_w pop_under18_w pop_above64_w, by(id year)
	rename (total_pop_zcta_w total_white_zcta_w pop_male_w pop_female_w pop_under18_w pop_above64_w) (total_pop_market total_white_market total_male_market total_female_market total_under18_market total_above64_market)
	
	*	Save
	save race_market_1418.dta, replace
restore

*	Alternative market difinition (a)
preserve
	drop povertyrate_zcta
	drop if total_pop_zcta == ""
	*	Keep only ZIP codes included in the index CHC's market
	drop if rule_market_a==0
	
	*	Weighted by patient volume
	bysort id year: egen total_c = sum(TotalPatientChcZip)
	gen share_c = TotalPatientChcZip / total_c

	local vars total_pop_zcta total_white_zcta pop_male pop_female pop_under18 pop_above64
	foreach i of local vars{
		destring `i', replace
		gen `i'_w = `i' * share_c
	}
	collapse (sum) total_pop_zcta_w total_white_zcta_w pop_male_w pop_female_w pop_under18_w pop_above64_w, by(id year)
	rename (total_pop_zcta_w total_white_zcta_w pop_male_w pop_female_w pop_under18_w pop_above64_w) (total_pop_market_a total_white_market_a total_male_market_a total_female_market_a total_under18_market_a total_above64_market_a)
	
	*	Save
	save race_market_1418_a.dta, replace
restore

*	Alternative market difinition (b)
preserve
	drop povertyrate_zcta
	drop if total_pop_zcta == ""
	*	Keep only ZIP codes included in the index CHC's market
	drop if rule_market_b==0
	
	*	Weighted by patient volume
	bysort id year: egen total_c = sum(TotalPatientChcZip)
	gen share_c = TotalPatientChcZip / total_c

	local vars total_pop_zcta total_white_zcta pop_male pop_female pop_under18 pop_above64
	foreach i of local vars{
		destring `i', replace
		gen `i'_w = `i' * share_c
	}
	collapse (sum) total_pop_zcta_w total_white_zcta_w pop_male_w pop_female_w pop_under18_w pop_above64_w, by(id year)
	rename (total_pop_zcta_w total_white_zcta_w pop_male_w pop_female_w pop_under18_w pop_above64_w) (total_pop_market_b total_white_market_b total_male_market_b total_female_market_b total_under18_market_b total_above64_market_b)
	
	*	Save
	save race_market_1418_b.dta, replace
restore


**	Income var
preserve
	drop total_pop_zcta total_white_zcta pop_male pop_female pop_under18 pop_above64
	drop if povertyrate_zcta == "-" | povertyrate_zcta == "null" | povertyrate_zcta == ""
	destring povertyrate_zcta, replace
	*	Keep only ZIP codes included in the index CHC's market
	drop if rule_market==0
	
	*	Weighted by patient volume
	bysort id year: egen total_c = sum(TotalPatientChcZip)
	gen share_c = TotalPatientChcZip / total_c
	gen povertyrate_zcta_w = povertyrate_zcta * share_c

	collapse (sum) povertyrate_zcta_w, by(id year)
	rename povertyrate_zcta_w povertyrate_market

	*	Save
	save poverty_market_1418.dta, replace
restore

*	Alternative market difinition (a)
preserve
	drop total_pop_zcta total_white_zcta pop_male pop_female pop_under18 pop_above64
	drop if povertyrate_zcta == "-" | povertyrate_zcta == "null" | povertyrate_zcta == ""
	destring povertyrate_zcta, replace
	*	Keep only ZIP codes included in the index CHC's market
	drop if rule_market_a==0
	
	*	Weighted by patient volume
	bysort id year: egen total_c = sum(TotalPatientChcZip)
	gen share_c = TotalPatientChcZip / total_c
	gen povertyrate_zcta_w = povertyrate_zcta * share_c

	collapse (sum) povertyrate_zcta_w, by(id year)
	rename povertyrate_zcta_w povertyrate_market_a

	*	Save
	save poverty_market_1418_a.dta, replace
restore

*	Alternative market difinition (b)
preserve
	drop total_pop_zcta total_white_zcta pop_male pop_female pop_under18 pop_above64
	drop if povertyrate_zcta == "-" | povertyrate_zcta == "null" | povertyrate_zcta == ""
	destring povertyrate_zcta, replace
	*	Keep only ZIP codes included in the index CHC's market
	drop if rule_market_b==0
	
	*	Weighted by patient volume
	bysort id year: egen total_c = sum(TotalPatientChcZip)
	gen share_c = TotalPatientChcZip / total_c
	gen povertyrate_zcta_w = povertyrate_zcta * share_c

	collapse (sum) povertyrate_zcta_w, by(id year)
	rename povertyrate_zcta_w povertyrate_market_b

	*	Save
	save poverty_market_1418_b.dta, replace
restore
