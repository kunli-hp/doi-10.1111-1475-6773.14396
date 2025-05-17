* ==============================================================================

* CHC Quality Competition: Do File Sequence #4.3

* This do-file generates measures of competitors' quality.

* ==============================================================================


clear
set more off


****	Set working directory
cd "${cdata}/"


****	Cleaning
use hhi_14_18.dta, clear

local quality composite_oppwt chronic_oppwt screening_oppwt medication_oppwt composite_eqwt
merge m:1 id year using ./data/uds_1418.dta, keepusing(`quality') nogen

**	Cleaning
*	Drop CHC-ZIP with zero patient visit
drop if TotalPatientChcZip == 0
drop if TotalPatientChcZip == .
*	Drop other/unknown zip code
keep if zipcodetype == "ZipCode"

recode rule_competitor (0 = .)
recode rule_market (0 = .)
recode rule_market_a (0 = .)
recode rule_market_b (0 = .)


****	Generate the exposure variable: competitors' quality weighted by relatvie market shares
preserve
	foreach q of local quality{
		*	Weighted mean quality of all significant CHC competitors in a 5-digit ZIP code
		gen flag = rule_competitor
		replace flag = . if `q' == .
		bysort zipcode year: egen zip_total_f = sum(TotalPatientChcZip * flag)
		gen weight = TotalPatientChcZip / zip_total_f
		replace weight = 0 if flag == .
		bysort zipcode year: egen zip_`q' = sum(`q' * weight)
		bysort zipcode year: egen missing = mean(`q' * weight)
		replace zip_`q' = . if missing == .
		
		*	Weighted mean quality of the index CHC's all competitors in a 5-digit ZIP code
		gen zip_c_`q' = (zip_`q' - `q' * weight) / (1 - weight)
		replace zip_c_`q' = zip_`q' if flag == .
		drop flag zip_total_f weight zip_`q' missing
		
		*	Aggregate ZIP-code-level competitors' quality to CHC market-level
		gen flag = rule_market
		replace flag = . if zip_c_`q' == .
		bysort id year: egen chc_total_f = sum(TotalPatientChcZip * flag)
		gen weight = TotalPatientChcZip / chc_total_f
		replace weight = 0 if flag == .
		bysort id year: egen c_`q' = sum(zip_c_`q' * weight)
		bysort id year: egen missing = mean(zip_c_`q' * weight)
		replace c_`q' = . if missing == .
		drop flag chc_total_f weight missing
	}
	
	***	ZIP-code-level patient volume
	drop if rule_market == .
	bysort zipcode year: egen zip_total = TotalPatientChcZip
	bysort zipcode year: egen zip_uninsured = None_UninsuredPatients
	bysort zipcode year: egen zip_medicaid = Medicaid_CHIP_OtherPublicPatient
	
	***	Collapse to CHC-level dataset
	collapse (mean) chc_hhi c_composite_oppwt c_composite_eqwt c_chronic_oppwt c_screening_oppwt c_medication_oppwt ///
		(sum) zip_total zip_uninsured zip_medicaid, by(id year)
	
	save c_quality.dta, replace
restore	
	

****	Generate the exposure variable: competitors' quality weighted by relatvie market shares (alternative market definition (a))
preserve
	foreach q of local quality{
		*	Weighted mean quality of all significant CHC competitors in a 5-digit ZIP code
		gen flag = rule_competitor
		replace flag = . if `q' == .
		bysort zipcode year: egen zip_total_f = sum(TotalPatientChcZip * flag)
		gen weight = TotalPatientChcZip / zip_total_f
		replace weight = 0 if flag == .
		bysort zipcode year: egen zip_`q' = sum(`q' * weight)
		bysort zipcode year: egen missing = mean(`q' * weight)
		replace zip_`q' = . if missing == .
		
		*	Weighted mean quality of the index CHC's all competitors in a 5-digit ZIP code
		gen zip_c_`q' = (zip_`q' - `q' * weight) / (1 - weight)
		replace zip_c_`q' = zip_`q' if flag == .
		drop flag zip_total_f weight zip_`q' missing
		
		*	Aggregate ZIP-code-level competitors' quality to CHC market-level
		gen flag = rule_market_a
		replace flag = . if zip_c_`q' == .
		bysort id year: egen chc_total_f = sum(TotalPatientChcZip * flag)
		gen weight = TotalPatientChcZip / chc_total_f
		replace weight = 0 if flag == .
		bysort id year: egen c_`q' = sum(zip_c_`q' * weight)
		bysort id year: egen missing = mean(zip_c_`q' * weight)
		replace c_`q' = . if missing == .
		drop flag chc_total_f weight missing
	}
	
	***	ZIP-code-level patient volume
	drop if rule_market_a == .
	bysort zipcode year: egen zip_total = TotalPatientChcZip
	bysort zipcode year: egen zip_uninsured = None_UninsuredPatients
	bysort zipcode year: egen zip_medicaid = Medicaid_CHIP_OtherPublicPatient
	
	***	Collapse to CHC-level dataset
	collapse (mean) chc_hhi_a c_composite_oppwt_a = c_composite_oppwt ///
		(sum) zip_total_a = zip_total zip_uninsured_a = zip_uninsured zip_medicaid_a = zip_medicaid, by(id year)
	
	save ca_quality.dta, replace
restore
	

****	Generate the exposure variable: competitors' quality weighted by relatvie market shares (alternative market definition (b))
preserve
	foreach q of local quality{
		*	Weighted mean quality of all significant CHC competitors in a 5-digit ZIP code
		gen flag = rule_competitor
		replace flag = . if `q' == .
		bysort zipcode year: egen zip_total_f = sum(TotalPatientChcZip * flag)
		gen weight = TotalPatientChcZip / zip_total_f
		replace weight = 0 if flag == .
		bysort zipcode year: egen zip_`q' = sum(`q' * weight)
		bysort zipcode year: egen missing = mean(`q' * weight)
		replace zip_`q' = . if missing == .
		
		*	Weighted mean quality of the index CHC's all competitors in a 5-digit ZIP code
		gen zip_c_`q' = (zip_`q' - `q' * weight) / (1 - weight)
		replace zip_c_`q' = zip_`q' if flag == .
		drop flag zip_total_f weight zip_`q' missing
		
		*	Aggregate ZIP-code-level competitors' quality to CHC market-level
		gen flag = rule_market_b
		replace flag = . if zip_c_`q' == .
		bysort id year: egen chc_total_f = sum(TotalPatientChcZip * flag)
		gen weight = TotalPatientChcZip / chc_total_f
		replace weight = 0 if flag == .
		bysort id year: egen c_`q' = sum(zip_c_`q' * weight)
		bysort id year: egen missing = mean(zip_c_`q' * weight)
		replace c_`q' = . if missing == .
		drop flag chc_total_f weight missing
	}
	
	***	ZIP-code-level patient volume
	drop if rule_market_b == .
	bysort zipcode year: egen zip_total = TotalPatientChcZip
	bysort zipcode year: egen zip_uninsured = None_UninsuredPatients
	bysort zipcode year: egen zip_medicaid = Medicaid_CHIP_OtherPublicPatient
	
	***	Collapse to CHC-level dataset
	collapse (mean) chc_hhi_b c_composite_oppwt_b = c_composite_oppwt ///
		(sum) zip_total_b = zip_total zip_uninsured_b = zip_uninsured zip_medicaid_b = zip_medicaid, by(id year)
	
	save cb_quality.dta, replace
restore
