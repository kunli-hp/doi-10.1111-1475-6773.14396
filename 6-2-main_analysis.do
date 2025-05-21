* ==============================================================================

* CHC Quality Competition: Do File Sequence #6.2

* This do-file conducts main regression analysis and creates result tables

* ==============================================================================


clear
set more off


****	Set working directory
cd "${cdata}/"

use analytic.dta, clear


************	Analyses	************

****	With monopolists (Table S10, Model 3)
replace lc_composite_oppwt = 0 if chc_hhi == 1 | competitor == 0
gen monopolist = (chc_hhi == 1 |competitor == 0)

local covariate cmi siteno mcaid_rate unins_rate zip_total_s povertyrate_market pct_nonwhite_market yr3 yr4 yr5
local instrument lcc_frac_uninsured lcc_frac_medicaid

xtivreg composite_oppwt chc_hhi monopolist `covariate' (lc_composite_oppwt = `instrument'), re
	outreg2 using "${results}/table_s10.rtf", replace dec(3) ctitle(monopolist)

**	Summary stats of monopolists (Table S4)
asdoc sum composite_oppwt screening_oppwt medication_oppwt chronic_oppwt `covariate' if monopolist == 1, stat(N mean sd) save("${results}/table_s4.doc") replace dec(2) fs(12) font(Times New Roman)

**	Drop monopolist
drop if competitor == 0 | chc_hhi == 1


****	Use contemporaneous competitors' quality (Table S10, Model 7)
xtivreg composite_oppwt chc_hhi `covariate' (c_composite_oppwt = cc_frac_uninsured cc_frac_medicaid), re
	outreg2 using "${results}/table_s10.rtf", append dec(3) ctitle(Contemporaneous)


****	Main Analysis (Table 2)
**	IV-G2SLS
xtivreg composite_oppwt chc_hhi `covariate' (lc_composite_oppwt = `instrument'), re
	est sto com
	keep if e(sample)
	outreg2 using "${results}/table_2.rtf", replace dec(3)
	xtoverid, noisily


**	Baseline OLS
reg composite_oppwt lc_composite_oppwt chc_hhi `covariate'
	outreg2 using "${results}/table_2.rtf", append dec(3)
	
**	Baseline GLS
xtreg composite_oppwt lc_composite_oppwt chc_hhi `covariate', re
	outreg2 using "${results}/table_2.rtf", append dec(3)

*	FE vs. RE (Chi2 = 4.86, p = 0.9625)
xtivreg composite_oppwt chc_hhi `covariate' (lc_composite_oppwt = `instrument'), fe
	est sto fe
	hausman fe com

	
****	Validigy of IVs
**	Geographic distribution of competitors' competitors (Table S7)
preserve

	replace year = year - 1

	merge 1:m id year using cc_1418.dta, keep(master match) nogen
	rename (id BHCMISID zip) (idi id zipi)
	merge m:1 id year using uds_1418.dta, keepusing(zip) keep(master match) nogen
	
	**	% of same-state competitors' competitors
	gen statei = substr(zipi, 1, 2)
	gen statecc = substr(zip, 1, 2)
	gen same = (statei == statecc)
	bysort idi year: egen samep = mean(same)

	**	Distance between the index CHC and its competitors' competitors' headquarters
	rename zipi zipcode
	merge m:1 zipcode year using "zip_zcta_1418.dta", keep(master match) nogen
	destring zcta, replace
	merge m:1 zcta using geocode_zcta.dta, keep(master match) nogen
	rename (intptlat intptlong zcta zipcode) (lat1 long1 zip1 zipi)
	rename zip zipcode
	merge m:1 zipcode year using "zip_zcta_1418.dta", keep(master match) nogen
	destring zcta, replace
	merge m:1 zcta using geocode_zcta.dta, keep(master match) nogen
	rename (intptlat intptlong zcta zipcode) (lat2 long2 zip2 zip)

	geodist lat1 long1 lat2 long2, generate(dist) miles

	bysort idi year: egen id_dist = mean(dist)
	duplicates drop idi year, force
	
	**	Table S7
	asdoc sum samep id_dist, stat(N mean sd) save("${results}/table_s7.doc") replace dec(2) fs(12) font(Times New Roman)

	**	Exclude when competitors' competitors were close (Table S10, Model 4)
	sum samep, d
	sum id_dist, d
	local dist_p5 = r(p5)

	xtivreg composite_oppwt chc_hhi `covariate' (lc_composite_oppwt = `instrument') if id_dist > `dist_p5' & id_dist != ., re
		outreg2 using "${results}/table_s10.rtf", replace dec(3)

restore


**	Covariate balance test (Table S9)
gen rev_perpat = total_pat_revenue / total_patient_num
gen cost_perpat = cost_oper / total_patient_num

*	Panel A
qui sum lcc_frac_uninsured, d
	gen tcc_uninsured = (lcc_frac_uninsured >= r(p50))
qui sum lcc_frac_medicaid, d
	gen tcc_medicaid = (lcc_frac_medicaid >= r(p50))

local char frac_female_patient frac_white frac_poverty frac_uninsured frac_medicaid frac_medicare total_patient_num medical_encounter physician_fte pct_physician rev_perpat cost_perpat

foreach i of local char{
	qui xtreg `i' i.tcc_uninsured chc_hhi cmi siteno mcaid_rate unins_rate zip_total_s povertyrate_market pct_nonwhite_market yr3 yr4 yr5, re
	outreg2 using "${results}/table_S9A.rtf", append dec(3)
}

foreach i of local char{
	qui xtreg `i' i.tcc_medicaid chc_hhi cmi siteno mcaid_rate unins_rate zip_total_s povertyrate_market pct_nonwhite_market yr3 yr4 yr5, re
	outreg2 using "${results}/table_S9A.rtf".rtf, append dec(3)
}

*	Panel B
xtile tccc_medicaid = lcc_frac_medicaid, nq(3)
xtile tccc_uninsured = lcc_frac_uninsured, nq(3)

foreach i of local char{
	qui xtreg `i' i.tccc_uninsured chc_hhi cmi siteno mcaid_rate unins_rate zip_total_s povertyrate_market pct_nonwhite_market yr3 yr4 yr5, re
	outreg2 using "${results}/table_S9B.rtf", append dec(3)
}

foreach i of local char{
	qui xtreg `i' i.tccc_medicaid chc_hhi cmi siteno mcaid_rate unins_rate zip_total_s povertyrate_market pct_nonwhite_market yr3 yr4 yr5, re
	outreg2 using "${results}/table_S9B.rtf", append dec(3)
}



****	First-stage (Table S4)
**	Recover theta for GLS estimation
gen flag = 1
bysort id_en: egen T = sum(flag)

local covariate cmi siteno mcaid_rate unins_rate zip_total_s povertyrate_market pct_nonwhite_market yr3 yr4 yr5
local instrument lcc_frac_uninsured lcc_frac_medicaid
	xtivreg composite_oppwt chc_hhi `covariate' (lc_composite_oppwt = `instrument'), re theta
	gen theta = 1 - sqrt(e(sigma_e)^2 / (T*e(sigma_u)^2+e(sigma_e)^2))

**	GLS transformation
* gen Xit - theta * mean(Xit)
local vars composite_oppwt lc_composite_oppwt chc_hhi cmi siteno mcaid_rate unins_rate zip_total_s povertyrate_market pct_nonwhite_market yr3 yr4 yr5 lcc_frac_uninsured lcc_frac_medicaid
	foreach i of local vars{
		bysort id_en: egen m`i' = mean(`i')
		gen g`i' = `i' - theta * m`i'
	}

gen double cons = 1-theta

**	First stage regression
local gcovariate gcmi gsiteno gmcaid_rate gunins_rate gzip_total_s gpovertyrate_market gpct_nonwhite_market gyr3 gyr4 gyr5
local ginstrument glcc_frac_uninsured glcc_frac_medicaid

	reg glc_composite_oppwt gchc_hhi `gcovariate' `ginstrument' cons, nocons
		est sto first
		outreg2 using "${results}/table_S4.rtf", replace dec(3)
		capture drop c_hat
		predict c_hat, xb

	
	
****	Domain-specific models (Table 3)
local covariate cmi siteno mcaid_rate unins_rate zip_total_s povertyrate_market pct_nonwhite_market yr3 yr4 yr5
local instrument lcc_frac_uninsured lcc_frac_medicaid

est restore com	
	margins, eyex(lc_composite_oppwt) atmeans post
	outreg2 using "${results}/table_3.rtf", append dec(3) stats(coef ci)

xtivreg chronic_oppwt chc_hhi `covariate' (lc_composite_oppwt = `instrument'), re
	margins, eyex(lc_composite_oppwt) atmeans post
	outreg2 using "${results}/table_3.rtf", append dec(3) stats(coef ci)

xtivreg screening_oppwt chc_hhi `covariate' (lc_composite_oppwt = `instrument'), re
	margins, eyex(lc_composite_oppwt) atmeans post
	outreg2 using "${results}/table_3.rtf", append dec(3) stats(coef ci)

xtivreg medication_oppwt chc_hhi `covariate' (lc_composite_oppwt = `instrument'), re
	margins, eyex(lc_composite_oppwt) atmeans post
	outreg2 using "${results}/table_3.rtf", append dec(3) stats(coef ci)
	

	
	
****	Results by CHC's patient insurance mix (Table 4)
**	Uninsured
sum frac_uninsured, d
	local p50 = r(p50)
	local p75 = r(p75)

xtreg composite_oppwt c_hat2 chc_hhi `covariate' if frac_uninsured < `p50', re
	margins, eyex(c_hat) atmeans post
	outreg2 using "${results}/table_4.rtf", replace dec(3) stats(coef ci) ctitle(unins_belowp50)
xtreg composite_oppwt c_hat2 chc_hhi `covariate' if frac_uninsured >= `p50', re
	margins, eyex(c_hat) atmeans post
	outreg2 using "${results}/table_4.rtf", append dec(3) stats(coef ci) ctitle(unins_abovep50)
xtreg composite_oppwt c_hat2 chc_hhi `covariate' if frac_uninsured >= `p75', re
	margins, eyex(c_hat) atmeans post
	outreg2 using "${results}/table_4.rtf", append dec(3) stats(coef ci) ctitle(unins_abovep75)

**	Privately insured
sum frac_private, d
	local p50 = r(p50)
	local p75 = r(p75)
	
xtreg composite_oppwt c_hat2 chc_hhi `covariate' if frac_private < `p50', re
	margins, eyex(c_hat) atmeans post
	outreg2 using "${results}/table_4.rtf", append dec(3) stats(coef ci) ctitle(private_belowp50)
xtreg composite_oppwt c_hat2 chc_hhi `covariate' if frac_private >= `p50', re
	margins, eyex(c_hat) atmeans post
	outreg2 using "${results}/table_4.rtf", append dec(3) stats(coef ci) ctitle(private_abovep50)
xtreg composite_oppwt c_hat2 chc_hhi `covariate' if frac_private >= `p75', re
	margins, eyex(c_hat) atmeans post
	outreg2 using "${results}/table_4.rtf", append dec(3) stats(coef ci) ctitle(private_abovep75)
	
	
	
****	Additional sensitivity analysis
*	Use # of competitors (Table S10, Model 1)
xtivreg composite_oppwt competitor `covariate' (lc_composite_oppwt = `instrument'), re
	outreg2 using "${results}/table_s10.rtf", append dec(3) ctitle(alt-competition)

*	other weighting (Table S10, Model 2)
xtivreg composite_eqwt chc_hhi `covariate' (lc_composite_eqwt = `instrument'), re
	outreg2 using "${results}/table_s10.rtf", append dec(3) ctitle(eq-weight)

*	Drop HHI (Table S10, Model 5)
xtivreg composite_oppwt `covariate' (lc_composite_oppwt = `instrument'), re
	outreg2 using "${results}/table_s10.rtf", append dec(3) ctitle(no-hhi)

*	Additional control variables (Table S10, Model 6)
xtivreg composite_oppwt chc_hhi `covariate' pct_female_market pct_under18_market pct_above64_market (lc_composite_oppwt = `instrument'), re
	outreg2 using "${results}/table_s10.rtf", append dec(3) ctitle(more-covariate)

*	Alternative market definitions (Table S6)
local covariate cmi siteno mcaid_rate_a unins_rate_a zip_total_s_a povertyrate_market_a pct_nonwhite_market_a yr3 yr4 yr5
local instrument lcca_frac_uninsured lcca_frac_medicaid
xtivreg composite_oppwt chc_hhi `covariate' (lc_composite_oppwt = `instrument'), re
	outreg2 using "${results}/table_s6.rtf", append dec(3) ctitle(alt-a)

local covariate cmi siteno mcaid_rate_b unins_rate_b zip_total_s_b povertyrate_market_b pct_nonwhite_market_b yr3 yr4 yr5
local instrument lccb_frac_uninsured lccb_frac_medicaid
xtivreg composite_oppwt chc_hhi `covariate' (lc_composite_oppwt = `instrument'), re
	outreg2 using "${results}/table_s6.rtf", append dec(3) ctitle(alt-b)


****	Summary statistics
**	Table 1
asdoc sum composite_oppwt screening_oppwt medication_oppwt chronic_oppwt lc_composite_oppwt chc_hhi competitor, stat(N mean sd min p25 p75 max) save("${results}/table_1.doc") replace dec(2) fs(12) font(Times New Roman)
asdoc sum `covariate' `instrument', stat(N mean sd min p25 p75 max) save("${results}/table_1.rtf") append dec(2) fs(12) font(Times New Roman)

**	Table S2
asdoc sum cer_screen col_screen child_weight adult_weight tobacco_screen immunization med_asthma med_cad med_ivd diab_control hypt_control, stat(N mean sd min p25 p75 max) save("${results}/table_s2A.doc") append dec(2) fs(12) font(Times New Roman)

asdoc sum ncer_screen ncol_screen nchild_weight nadult_weight ntobacco_screen nimmunization nmed_asthma nmed_cad nmed_ivd ndiab_control nhypt_control, stat(N mean sd) save("${results}/table_s2A.doc") append dec(2) fs(12) font(Times New Roman)

asdoc sum wcer_screen wcol_screen wchild_weight wadult_weight wtobacco_screen wimmunization wmed_asthma wmed_cad wmed_ivd wdiab_control whypt_control, stat(N mean sd min p25 p75 max) save("${results}/table_s2B.doc") append dec(2) fs(12) font(Times New Roman)

**	Table S5
asdoc sum chc_hhi chc_hhi_a chc_hhi_b, stat(N mean sd min p25 p75 max) save("${results}/table_s5.doc") replace dec(2) fs(12) font(Times New Roman)
