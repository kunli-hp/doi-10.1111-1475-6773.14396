* ==============================================================================

* CHC Quality Competition: Do File Sequence #6.1

* This do-file creates Figure 1.

* ==============================================================================


clear
set more off


****	Set working directory
cd "${cdata}/"


****	Figure 1
use analytic.dta, clear

hist chc_hhi_total, width(0.04) percent graphregion(fcolor(white) lcolor(white)) bgcolor(white) ///
	xtitle("HHI", size(vlarge)) ytitle(,size(vlarge)) xlabel(,format(%9.1f) labsize(vlarge)) ylabel(,labsize(vlarge)) name(hist_hhi, replace)
hist competitor, width(2) percent graphregion(fcolor(white) lcolor(white)) bgcolor(white) ///
	xtitle("Number of Competitors", size(vlarge)) ytitle(,size(vlarge)) xlabel(,labsize(vlarge)) ylabel(,labsize(vlarge)) name(hist_com, replace)

graph box chc_hhi_total, over(year, lab(labsize(vlarge))) graphregion(fcolor(white) lcolor(white)) bgcolor(white) ///
	ytitle(HHI, size(vlarge)) ylabel(,labsize(vlarge)) name(box_hhi, replace)
graph box competitor, over(year, lab(labsize(vlarge))) graphregion(fcolor(white) lcolor(white)) bgcolor(white) ///
	ytitle("Number of Competitors", size(vlarge)) ylabel(,labsize(vlarge)) name(box_com, replace)

graph combine hist_hhi box_hhi, graphregion(fcolor(white) lcolor(white)) title("HHI") name(hhi, replace)
graph combine hist_com box_com, graphregion(fcolor(white) lcolor(white)) title("Number of Competitors") name(com, replace)
graph combine hhi com, col(1) graphregion(fcolor(white) lcolor(white))

graph export "${results}/f1.png", as(png) replace
