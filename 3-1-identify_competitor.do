* ==============================================================================

* CHC Quality Competition: Do File Sequence #3

* This do-file identifies each CHC's competitors and "competitors' competitor".

* ==============================================================================

****	Inputs: HHI data files derived from Do File #1 
****	Outputs: 1) List of competitors of each CHC (each row is a CHC-competitor combination)
****		 2) List of "competitors' competitors" of each CHC (each row is a CHC-"competitors' competitors" combination)

****	Estmated Run Time: 15 hours	****

clear
set more off


****	Set working directory
cd "${cdata}/"


****	Identify each CHC's competitors
forvalue y = 4/8{
	use hhi_201`y'.dta, clear

	drop if zipcode=="Other ZIP Codes"|zipcode=="Unknown Residence"
	drop if rule_market==0 & rule_competitor==0

	**	List all CHC IDs
	levelsof BHCMISID, local(chc)

	**	Loop over all CHCs in the dataset; find competitors
	foreach c of local chc{
		*	List all ZIP codes of CHC c 
		levelsof zipcode if BHCMISID == "`c'" & rule_market == 1, local(market_zip)
		*	Identify all ZIP codes in the market of CHC c
		gen same_market = 0
		foreach l of local market_zip{
			replace same_market = 1 if zipcode=="`l'"
		}
		
		*	List all CHCs in the market of CHC c
		levelsof BHCMISID if same_market == 1 & rule_competitor == 1, local(compete_chc)
		*	Identify competitors of CHC c
		gen competitor = 0
		foreach l of local compete_chc{
			replace competitor=1 if BHCMISID=="`l'"
		}
		replace competitor = 0 if BHCMISID=="`c'"
		
		*	Save the list of competitors
		preserve
			keep if competitor == 1
			capture collapse competitor, by(BHCMISID year)
			if c(rc) == 0 {
				gen id = "`c'"
				append using c_201`y'.dta, force
				save c_201`y'.dta, replace
			}
			else if !inlist(c(rc), 2000, 2001) {
				exit c(rc)
			}
		restore

		drop same_market competitor
	}
}

**	Number of competitors
use c_2014.dta, clear

forvalue i = 5/8{
	append using c_201`i'.dta, force
}

collapse (sum) competitor, by(year id)
destring year, replace
save ./data/c_count_1418.dta, replace




****	Identify each CHC's "competitors' competitors"
forvalue y = 4/8{
	use hhi_201`y'.dta, clear

	drop if zipcode=="Other ZIP Codes"|zipcode=="Unknown Residence"
	drop if rule_market==0 & rule_competitor==0
	
	**	List all CHC IDs
	levelsof BHCMISID, local(chc)

	**	Loop over all CHCs in the dataset; find competitors
	foreach c of local chc{
		*	List all ZIP codes of CHC c
		levelsof zipcode if BHCMISID == "`c'" & rule_market == 1, local(market_zip)
		*	Identify all ZIP codes in the market of CHC c
		gen same_market = 0
		foreach l of local market_zip{
			replace same_market=1 if zipcode=="`l'"
		}

		*	List all CHCs in the market of CHC c
		levelsof BHCMISID if same_market == 1 & rule_competitor == 1, local(compete_chc)
		*	Identify competitors of CHC c
		gen competitor = 0
		foreach l of local compete_chc{
			replace competitor = 1 if BHCMISID=="`l'"
		}
		
		*	List all ZIP codes of CHC c and its competitors; Identify all ZIP codes in the market of CHC c and its competitors
		gen same_market_com = 0
			foreach l of local compete_chc{
			levelsof zipcode if BHCMISID == "`l'" & rule_market == 1, local(market_com)
			
			foreach k of local market_com{
				replace same_market_com = 1 if zipcode=="`k'"
			}
		}
		
		*	List all CHCs in the market of CHC c and its competitors
		levelsof BHCMISID if same_market_com == 1 & rule_competitor == 1, local(compete_com)
		*	Identify competitors of CHC c's competitors
		gen competitor_com = 0
		foreach l of local compete_com{
			replace competitor_com = 1 if BHCMISID == "`l'"
		}
		gen cc = 0
		replace cc = 1 if competitor_com == 1
		replace cc = 0 if competitor == 1

		preserve
			keep if cc == 1
			capture collapse cc, by(BHCMISID year)
			if c(rc) == 0 {
				gen id = "`c'"
				append using cc_201`y'.dta, force
				save cc_201`y'.dta, replace
			}
			else if !inlist(c(rc), 2000, 2001) {
				exit c(rc)
			}
		restore

		drop same_market competitor same_market_com competitor_com cc
	}
}

**	Competitors' competitors' characteristics
local iv chronic_oppwt screening_oppwt medication_oppwt composite_oppwt composite_eqwt frac_uninsured frac_medicaid

forvalue i = 4/8{
	use cc_201`i'.dta, clear
	destring year, replace
	rename id marker
	rename BHCMISID id
	merge m:1 id year using ./data/uds_1418.dta, keepusing(`iv') keep(match)
	collapse `iv', by(marker year)
	foreach q of local iv{
		rename `q' cc_`q'
	}
	rename marker id
	save cc_quality_201`i'.dta, replace
}

*	Append data
use cc_quality_2018.dta, clear
forvalue i = 4/7{
	append using cc_quality_201`i'.dta, force
}

*	Save
save cc_quality_1418.dta, replace
