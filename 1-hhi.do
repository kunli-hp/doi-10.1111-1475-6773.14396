* ==============================================================================

* CHC Quality Competition: Do File Sequence #1

* This do-file identifies CHC markets and constructs HHIs for 2014-2018.

* ==============================================================================

****	Data source: UDS ZIP code table 
**		Each row is a CHC-ZIP code combination
**		Contains information on the number of patients originated from each 5-digit ZIP code

clear
set more off


****	Set working directory
cd "${rdata}/uds/"


****	Construct ZIP-code-level HHIs and CHC-centric HHIs
forvalue i = 4/8{
	use patient-origin-zip-201`i'.dta, clear

	*** Recode missing zipcode
	replace ZipCode=ZipCodeType if ZipCode==""

	*** Rename variables
	label var BHCMISID "Unique CHC id"
	rename TotalNumberofPatients TotalPatientChcZip
		label var TotalPatientChcZip "# of patients in ZIP code z sought care from CHC i"
	rename ZipCode, lower
	rename ReportingYear year

	***	Market shares
	bysort BHCMISID: egen chc_n = sum(TotalPatientChcZip)
		label var chc_n "Total # of patients at CHC i"
	gen chc_share = TotalPatientChcZip/chc_n
		label var chc_share "% of patients from ZIP code z among all patients at CHC i"

	bysort zipcode: egen zip_n = sum(TotalPatientChcZip)
		label var zip "Total # of patients in ZIP code z"
	gen zip_share = TotalPatientChcZip/zip_n
		label var zip_share "Market share of CHC i in ZIP code z"

	*** Indicator of the index CHC's market 
	** Main analysis: CHC i's market only includes ZIP codes contributing to at least 1% of CHC i's patients
		gen rule_market = (chc_share >= 0.01)
		* Exclude cells with missing ZIP codes
		replace rule_market = 0 if zipcodetype != "ZipCode"
			label var rule_market "Indicator of CHC i's market (1==yes)"
			
	** Sensitivity analysis (a): CHC i's market only includes ZIP codes contributing to at least 5% of CHC i's patients
		gen rule_market_a = (chc_share >= 0.05)
		* Exclude cells with missing ZIP codes
		replace rule_market = 0 if zipcodetype != "ZipCode"
			label var rule_market_a "Alternative indicator (a) of CHC i's market (1==yes)"
			
	** Sensitivity analysis (b): Largest ZIP code areas cumulatively contributing up to 60% of the CHC i's patients
		recode chc_share_total (. = 0)
		gsort BHCMISID -chc_share
		gen chc_share2 = chc_share
		replace chc_share2 = . if zipcodetype != "ZipCode"
		gen neg_chc_share = -chc_share2
		bysort BHCMISID (neg_chc_share): gen cum_chc_share = sum(chc_share2)
		gen share_flag = (cum_chc_share >= 0.6)
		bysort BHCMISID (neg_chc_share): gen diff_flag = share_flag[_n] - share_flag[_n-1]
		gen rule_market_b = 1 - (share_flag == 1 & diff_flag == 0)
		label variable rule_market_b "Alternative indicator (b) of CHC i's market (1==yes)"
	
	
	*** Indicator of significant competitors in a ZIP code 
	* (Significant competitors in ZIP codes z only includ CHCs accounting for at least 1% of the market share)
	gen rule_competitor = (zip_share >= 0.01)
		label var rule_competitor "Indicator of significant competitor in ZIP code z (1==yes)"
	
	*** Denominators for rescaling market shares
	bysort BHCMISID: egen chc_share_sm = sum(rule_market * chc_share)
		label var chc_share_sm "% of patients at CHC i from market areas"
	bysort zipcode: egen zip_share_sm = sum(rule_competitor * zip_share)
		label var zip_share_sm "% of patients in ZIP code z at significant competitor CHCs"
		
	bysort BHCMISID: egen chc_share_sm_a = sum(rule_market_a * chc_share)
		label var chc_share_sm "% of patients at CHC i from market areas"
	bysort BHCMISID: egen chc_share_sm_b = sum(rule_market_b * chc_share)
		label var chc_share_sm "% of patients at CHC i from market areas"

	
	*** ZIP-code-level HHIs
	gen zip_share2 = (zip_share / zip_share_sm)^2
	bysort zipcode: egen zip_hhi = sum(rule_competitor * zip_share2)
		label var zip_hhi "HHI of ZIP code z"
	
	*** CHC-centric HHIs
	* (Weighted average of HHIs of ZIP codes that are included in CHC i's market)
	gen chc_wshare = (chc_share / chc_share_sm) * zip_hhi
	bysort BHCMISID: egen chc_hhi = sum(rule_market * chc_wshare)
		label var chc_hhi "HHI of CHC i"
		
	gen chc_wshare_a = (chc_share / chc_share_sm_a) * zip_hhi
	bysort BHCMISID: egen chc_hhi_a = sum(rule_market_a * chc_wshare_a)
		label var chc_hhi "HHI of CHC i, alternative (a)"
		
	gen chc_wshare_b = (chc_share / chc_share_sm_b) * zip_hhi
	bysort BHCMISID: egen chc_hhi_b = sum(rule_market_b * chc_wshare_b)
		label var chc_hhi "HHI of CHC i, alternative (b)"

	*** Save
	save "${cdata}/hhi_201`i'.dta", replace
}


****	Append data
use "${cdata}/hhi_2014.dta", clear

forvalue i = 5/8{
	append using "${cdata}/hhi_201`i'.dta", force
	}
	
destring year, replace

**	Save
save "${cdata}/hhi_14_18.dta", replace

