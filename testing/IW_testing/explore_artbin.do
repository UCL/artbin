/*
Ian's file for exploring / understanding artbin 
IW 21oct2020 
systematic output 11feb2021
change NI away from special case that made nvm 1 = 2 15feb2021
tidy up 26feb2021
4may2021: for NI trials, remove nvm and add ccorrect
*/
local name explore_artbin
*local ver _v126
cap log close
which artbin`ver'
log using `name'`ver', text replace
postutil clear
postfile ian str20(type method opt) n using `name'_postfile, replace

// 2 arms, superiority
foreach method in "local" "nolocal" "wald" "condit local" {
	foreach opt in noccorrect ccorrect {
		cap artbin`ver', pr(.4 .2) alpha(0.025) power(.8) onesided noround `method' `opt'
		if !_rc local n = r(n)
		else local n=.
		post ian ("2 arms sup") ("`method'") ("`opt'") (`n')
	}
}


// same for 3 arms
foreach method in "local" "nolocal" "wald" "condit local" {
	foreach opt in notrend trend {
		cap artbin`ver', pr(.4 .35 .2) alpha(0.05) power(.8) noround `method' `opt'
		if !_rc local n = r(n)
		else local n=.
		post ian ("3 arms") ("`method'") ("`opt'") (`n')
	}
}

// finally NI
foreach method in "local" "nolocal" "wald" "condit local" {
	foreach opt in noccorrect ccorrect {
		cap artbin`ver', pr(.4 .4) margin(.2) alpha(0.05) power(.8) noround `method' `opt'
		if !_rc local n = r(n)
		else local n=.
		post ian ("2 arms NI") ("`method'") ("`opt'") (`n')
	}
}

postclose ian

use `name'_postfile, clear
sencode type, gen(typenum)
sencode method, gen(methnum)
sencode opt, gen(optnum)
tabdisp optnum methnum, by(typenum) c(n) concise

log close
