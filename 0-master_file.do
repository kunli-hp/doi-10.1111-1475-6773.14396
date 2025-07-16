* ==============================================================================

* CHC Quality Competition: MASTER FILE

* ==============================================================================


clear all
set more off

****	Root folder globals
global user "username"   /* updated username */
global root "/Users//$user/Box/CHC_competition_HSR" 	/* change to user's path */
global root "/Users//$user/Documents/CHC_competition_HSR" 	/* change to user's path */

****	Input and analysis folder globals
global rdata "${root}/data/rawdata"						/* raw data and can path to csv or dta */
global program "${root}/program"							/* do files for the analysis */
global cdata "${root}/data/cleandata"					/* dta files from building data */
global results "${root}/results"		        		/* logs, excel sheets, graphs from analyzing data */


****	Analysis
*	Construct CHC-centric Herfindahl–Hirschman index
do "$program/1-hhi.do"

*	Process UDS data
do "$program/2-uds_cleaning.do"

*	Identify competitors and "competitors' competitors"
do "$program/3-1-identify_competitor.do"

*	Identify competitors and "competitors' competitors" using alternative market definitions
do "$program/3-2-alt_identify_competitor.do"

*	Process ACS data
do "$program/4-1-acs.do"

*	Create CHC market-level covariates
do "$program/4-2-zcta-covariates.do"

*	Generate measures of competitors' quality
do "$program/4-3-c_quality.do"

*	Create analytic sample
do "$program/5-analytic_sample.do"

*	Create Figure 1
do "$program/6.1-figure_1.do"

*	Regression analysis
do "$program/6.2-main_analysis.do"
