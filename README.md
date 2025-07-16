# doi-10.1111-1475-6773.14396
This repository contains code for "Overlapping markets and quality competition among community health centers" by Kun Li and Avi Dor.

Citation: Li K, Dor A. Overlapping markets and quality competition among community health centers. Health Serv Res. 2024; 1-10. doi:10.1111/1475-6773.14396

This repository contains code that processes raw data and analyzes the data to produce figures and tables for the paper.


##  Study Data
    --  Uniform Data System (UDS), 2014-2018
		The primary data source is the Uniform Data System, an administrative dataset containing information at the community health center (CHC) level. 
		We are not allowed to share the full data files, either raw or processed.
		Public version of the UDS data files can be downloaded from:
		https://data.hrsa.gov/tools/data-reporting/program-data

    --  American Community Survey (ACS), 2015-2018
		Files downloaded from:
		https://usa.ipums.org/usa/acs.shtml


##  Do Files
    --  1-hhi.do
	--  This file processes the ZIP code table of the UDS and constructs CHC-centric Herfindahl–Hirschman index (HHI).

    --  2-uds_cleaning.do
	--  This file processes the UDS data; extracts and renames variables relevant to this study.

    --  3-1-identify_competitor.do
	--  This file identifies each CHC's competitors and "competitors' competitors".

    --  3-2-alt_identify_competitor.do
	--  This file identifies each CHC's competitors and "competitors' competitors", using alternative market definitions.

    --  4-1-acs.do
	--  This file processes the ACS data at the 5-digit ZIP code tabulation area (ZCTA) level.

    --  4-2-zcta-covariates.do
	--  This file aggregates ZCTA-level ACS variables to CHC-centric market level (i.e., CHC-level).

    --  4-3-c_quality.do
	--  This file generates measures of competitors' quality.

    --  5-analytic_sample.do
	--  This file creats an analytic sample of CHC-years from 2015-2018; constructs all variables relevant to this study.

    --  6.1-figure_1.do
	--  This file creates Figure 1.

    --  6.2-main_analysis.do
	--  This file conducts regression analysis.
	--  This file creates Table 1, Table 2, Table 3, Table 4, Table S2, Table S4, Table S5, Table S6, Table S7, Table S8, Table S9, Table S10.
 
