* ==============================================================================

* CHC Quality Competition: Do File Sequence #5

* This do-file creates analytic sample for the study.

* ==============================================================================


clear
set more off


****	Set working directory
cd "${cdata}/"


use uds_1418.dta, clear


****	Adding covariates
**	ACS-based market characteristics
merge 1:1 id year using race_market_1418.dta, keep(master match) nogen
merge 1:1 id year using race_market_1418_a.dta, keep(master match) nogen
merge 1:1 id year using race_market_1418_b.dta, keep(master match) nogen

merge 1:1 id year using poverty_market_1418.dta, keep(master match) nogen
merge 1:1 id year using poverty_market_1418_a.dta, keep(master match) nogen
merge 1:1 id year using poverty_market_1418_b.dta, keep(master match) nogen

**	Competitors' competitors' characteristics
merge 1:1 id year using ./data/cc_quality_1418.dta
rename _merge cc_flag

**	Competitors' quality
merge 1:1 id year using ./data/c_quality.dta, nogen
merge 1:1 id year using ./data/ca_quality.dta, nogen
merge 1:1 id year using ./data/cb_quality.dta, nogen

**	CHC characteristics
merge 1:1 id year using ./data/CHC_sites.dta, keepusing(siteno) nogen
merge 1:1 id year using ./data/c_count_1418.dta, nogen
replace competitor = 0 if competitor == .

****	Sample inclusion and exclusion
**	Keep 50 states and DC
encode state_ab, gen(state_en)
encode id, gen(id_en)

drop if state_ab == "AS" | state_ab == "FM" | state_ab == "GU" | state_ab == "MH" | state_ab == "MP" | state_ab == "PR" | state_ab == "PW" | state_ab == "VI"


****	Process variables
gen mcaid_rate = zip_medicaid / zip_total
gen unins_rate = zip_uninsured / zip_total
gen mcaid_rate_a = zip_medicaid_a / zip_total_a
gen unins_rate_a = zip_uninsured_a / zip_total_a
gen mcaid_rate_b = zip_medicaid_b / zip_total_b
gen unins_rate_b = zip_uninsured_b / zip_total_b

gen pct_nonwhite_market = 1 - (total_white_market / total_pop_market) * 1
replace povertyrate_market = povertyrate_market / 100
gen pct_female_market = total_female_market / total_pop_market
gen pct_under18_market = total_under18_market / total_pop_market
gen pct_above64_market = total_above64_market / total_pop_market

gen pct_nonwhite_market_a = 1 - (total_white_market_a / total_pop_market_a) * 1
replace povertyrate_market_a = povertyrate_market_a / 100
gen pct_female_market_a = total_female_market_a / total_pop_market_a
gen pct_under18_market_a = total_under18_market_a / total_pop_market_a
gen pct_above64_market_a = total_above64_market_a / total_pop_market_a

gen pct_nonwhite_market_b = 1 - (total_white_market_b / total_pop_market_b) * 1
replace povertyrate_market_b = povertyrate_market_b / 100
gen pct_female_market_b = total_female_market_b / total_pop_market_b
gen pct_under18_market_b = total_under18_market_b / total_pop_market_b
gen pct_above64_market_b = total_above64_market_b / total_pop_market_b

**	Standardize market-level patient volume
qui sum zip_total
local sd = r(sd)
gen zip_total_s = zip_total / `sd'
	label var zip_total_s "Standardized total # of CHC patients in a ZIP code"
	
qui sum zip_total_a
local sd = r(sd)
gen zip_total_s_a = zip_total_a / `sd'
	
qui sum zip_total_b
local sd = r(sd)
gen zip_total_s_b = zip_total_b / `sd'

**	Year dummies
tab year, gen(yr)

**	Lagged terms
xtset id_en year

gen lc_composite_oppwt = l.c_composite_oppwt
gen lc_composite_oppwt_a = l.c_composite_oppwt_a
gen lc_composite_oppwt_b = l.c_composite_oppwt_b
gen lc_composite_eqwt = l.c_composite_eqwt
gen lcc_frac_uninsured = l.cc_frac_uninsured
gen lcc_frac_medicaid = l.cc_frac_medicaid
gen lcca_frac_uninsured = l.cca_frac_uninsured
gen lcca_frac_medicaid = l.cca_frac_medicaid
gen lccb_frac_uninsured = l.ccb_frac_uninsured
gen lccb_frac_medicaid = l.ccb_frac_medicaid

*	Save
save analytic.dta, replace
