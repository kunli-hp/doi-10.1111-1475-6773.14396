* ==============================================================================

* CHC Quality Competition: Do File Sequence #2

* This do-file crops the UDS data and gives meaningful labels to the variables.

* ==============================================================================

****	Data source: UDS 
**	Multiple tables with a unique CHC identifer; Each row is a CHC

clear
set more off


****	Set working directory
cd "${rdata}/uds/"


****	Process data
forvalue i = 5/7{
	use UDS-201`i'.dta, clear

	**	Rename variables to lower case
	qui ds
	local num = r(varlist)
	forvalue i=1/`=`:word count of `num''-1'{
		local lower = lower("`:word `i' of `num''")
		capture confirm variable `lower'
		if _rc!=0 {
			rename `:word `i' of `num'', lower
		}
	}

	**	Extract variables
	gen year=201`i'
		label var year "year"
	gen id=uds
		label var id "Unique CHC ID"
	gen name=healthcentername
		label var name "Organization Name"
	gen state_ab=healthcenterstate
		label var state_ab "state abbreviation"
	gen zip=substr(healthcenterzipcode,1,5)
		label var zip "5 digit zip code"
	gen chc=(fundingchc=="tRUE")
		label var chc "community Health center Grantee"

	**	patients age & gender mix
	egen total_patient_num = rowtotal(t3a_l39_ca t3a_l39_cb)
		label var total_patient_num "total number of patients"

	egen total_patient_female = rowtotal(t3a_l1_cb t3a_l2_cb t3a_l3_cb t3a_l4_cb t3a_l5_cb t3a_l6_cb t3a_l7_cb t3a_l8_cb t3a_l9_cb t3a_l10_cb t3a_l11_cb t3a_l12_cb t3a_l13_cb t3a_l14_cb t3a_l15_cb t3a_l16_cb t3a_l17_cb t3a_l18_cb t3a_l19_cb t3a_l20_cb t3a_l21_cb t3a_l22_cb t3a_l23_cb t3a_l24_cb t3a_l25_cb t3a_l26_cb t3a_l27_cb t3a_l28_cb t3a_l29_cb t3a_l30_cb t3a_l31_cb t3a_l32_cb t3a_l33_cb t3a_l34_cb t3a_l35_cb t3a_l36_cb t3a_l37_cb t3a_l38_cb)
		label var total_patient_female "number of patients female"

	gen frac_female_patient=total_patient_female/total_patient_num
		label var frac_female "fraction of patient female"
		
	**	race and socioeconomic status
	gen total_white=t3b_l5_cd
	label var total_white "total patients white"
	gen total_black=t3b_l3_cd
	label var total_black "total patients black"
	gen total_hispanic=t3b_l8_ca
	label var total_hispanic "total patients hispanic"

	gen frac_white=t3b_l5_cd/total_patient_num
	label var frac_white "fraction of patients white"
	gen frac_black=t3b_l3_cd/total_patient_num
	label var frac_black "fraction of patients black"
	gen frac_hispanic=t3b_l8_ca/total_patient_num
	label var frac_hispanic "fraction of patients hispanic"

	egen poverty_num=rowtotal(t4_l1_ca t4_l2_ca t4_l3_ca)
	label var poverty_num "total number of patients below 200% poverty line"

	gen frac_poverty=poverty_num/total_patient_num
	label var frac_poverty "fraction of patients below 200% poverty line"

	**	payer mix information
	egen uninsured=rowtotal(t4_l7_ca t4_l7_cb)
		label var uninsured "number of uninusred patients"
	egen medicaid=rowtotal(t4_l8_ca t4_l8_cb t4_l10b_ca t4_l10b_cb)
		label var medicaid "number of medicaid covered patients"
	egen private=rowtotal(t4_l11_ca t4_l11_cb)
		label var private "number of privately insured patients"

	gen frac_uninsured=uninsured/total_patient_num
		label var frac_uninsured "fraction of patients uninsured"
	gen frac_medicaid=medicaid/total_patient_num
		label var frac_medicaid "fraction of patients Medicaid"
	gen frac_private=private/total_patient_num
		label var frac_private "fraction of patients private"
	
	**	staff and visit mix
	gen medical_encounter=t5_l15_cb
	label var medical_encounter "total medical care services ecounter"
	gen physician_fte=t5_l8_ca
	label var physician_fte "total physician FTE"
	gen pct_physician=physician_fte/t5_l15_ca
	label var pct_physician "pct of physician as total medical care staff"
	
	**	finance
	gen total_pat_revenue=t9d_l14_cb
	label var total_pat_revenue "total patient revenue"
	egen cost_oper=rowtotal(t8a_l4_ca t8a_l10_ca t8a_l13_ca)
	label var cost_oper "operationg cost"

	keep name year id state_ab zip num_deliv_sites chc total_patient_num total_patient_female frac_female_patient uninsured medicaid private frac_uninsured frac_medicaid frac_private frac_white frac_black frac_hispanic frac_poverty medical_encounter physician_fte pct_physician total_pat_revenue cost_oper

	save save "${cdata}/uds_201`i'.dta", replace
}


****	Append data
use "${cdata}/uds_2014.dta", clear

forvalues i = 4/8{
	append using "${cdata}/uds_201`i'.dta", force
	}

**	Merge with CHC-level quality measures and case-mix index
*	A reuse of the quality measure files from Carey K, Luo Q, Dor A. Quality and Cost in Community Health Centers. Medical Care. 2021;59(9):824-828.
merge 1:1 id year using "${cdata}/quality_measures_2012_2018.dta", keep(master match)
	rename _merge quality_flag

merge 1:1 id year using "${cdata}/cmi_2012_2018.dta", keepus(cmi) keep(master match)
	rename _merge cmi_flag

**	Save
save "${cdata}/uds_14_18.dta", replace
