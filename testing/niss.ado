*! Sample size for non-inferiority trial using a risk difference
*! Created by Patrick Phillips
*! version 1.01 10mar2015

*
* Sample size program for non-inferiority trials using a risk difference
* Started 21/08/2014
*
*

cap program drop niss
program niss, rclass
	version 13.1
	syntax anything,  ///
		[ARatio(real 1) ALpha(real 0.025) POwer(real 0.8) NAssessable(real 0)]
			// Allocation ratio: fixed in advance n2/n1
			// Probability of outcome p1:p2
			// Alpha (one-sided)
			// H0: p1-p2 < delta, or p1-p2 > delta if delta < 0
		
	loc za = invnormal(1-`alpha')
	loc zb = invnormal(`power')
	loc zz = (`za' + `zb')^2
		// (z_(1-a) + z_(1-b))^2

	** Check p1, p2 and delta
	loc p1 = word("`anything'",1)
	loc p2 = word("`anything'",2)
	loc delta = word("`anything'",3)
	
	if !inrange(real("`p1'"),0,1) | !inrange(real("`p2'"),0,1) | !inrange(real("`delta'"),-1,1) {
		noi disp as err _n "Provide each of p1, p2, delta."
		noi disp as err _n "Delta must be positive."
		noi disp as err _n "Syntax should be: {txt}niss p1 p2 delta, alpha() power() aratio() nassessable()" _n
		exit 7
	}
		
		
	** Using observed values 
		loc n1_obs = (`zz' * (`aratio'*`p1'*(1-`p1') + `p2'*(1-`p2'))) / (`aratio'*((`p1' - `p2')-`delta')^2)
			// Number of patients in each group
			
	** Using MLE
	*loc a = (1 + `aratio') / `aratio'
	*loc b = -(1 + `aratio' + `aratio'*`p1' + `p2' + `delta'*(1+2*`aratio')) / `aratio'
	*loc c = (`aratio'*(`delta')^2 + `delta'*(2*`aratio'*`p1' + 1 + `aratio') + `aratio'*`p1' + `p2') / `aratio'
	loc a = (1 + `aratio')
	loc b = -(1 + `aratio' + `p1' + `aratio'*`p2' + `delta'*(2+`aratio'))
	loc c = (`delta')^2 + `delta'*(2*`p1' + 1 + `aratio') +`p1' +  `aratio'*`p2' 
		
	loc d = -`p1'*`delta'*(1+`delta')

	loc v = (`b')^3/(3*`a')^3 - `b'*`c'/(6*(`a')^2) + `d' / (2*`a')
	loc u = sign(`v')*sqrt((`b')^2/(3*`a')^2 - `c'/(3*`a'))
	loc w = (_pi + acos(`v'/(`u')^3))/3

	loc p1d = 2*`u'*cos(`w') - `b'/(3*`a')
	loc p2d = `p1d' - `delta'

	loc chk = `a'*(`p1d')^3 + `b'*(`p1d')^2 + `c'*`p1d' + `d'
		// Chk - this should equal zero
	assert abs(`chk') < 0.000000001

	*loc term1 = `aratio'*`p1d'*(1-`p1d') + `p2d'*(1-`p2d') / `aratio'
	*loc term2 = `aratio'*`p1'*(1-`p1') + `p2'*(1-`p2')
	loc term1 = `p1d'*(1-`p1d') + `p2d'*(1-`p2d') / `aratio'
	loc term2 = `p1'*(1-`p1') + `p2'*(1-`p2') / `aratio'

	*loc n1_mle = ((`za'*sqrt(`term1') + `zb'*sqrt(`term2'))^2) / (`aratio'*((`p1' - `p2')-`delta')^2)
	loc n1_mle = ((`za'*sqrt(`term1') + `zb'*sqrt(`term2'))^2) / ((`p1' - `p2')-`delta')^2
	
	foreach mthd in mle obs {
		loc n2_`mthd' = ceil(`aratio'*`n1_`mthd'' / (1-`nassessable'))
		loc n1_`mthd' = ceil(         `n1_`mthd'' / (1-`nassessable'))
		loc N_`mthd' = `n1_`mthd''+`n2_`mthd''
	}
		
	di as text _n "{bf}{c TLC}{dup 76:{c -}}{c TRC}"
	di as text "{bf}{c |} Sample size calculation for non-inferiority trials using a risk difference {c |}"
	di as text "{bf}{c BLC}{dup 76:{c -}}{c BRC}" 
	di as text "            p1 = `p1'"
	di as text "            p2 = `p2'"
	di as text "         delta = `delta'"
	di as text "         alpha = `alpha' (one-sided)"
	di as text "         power = `power'"
	di as text "    allocation = 1:`aratio'"
	di as text "not assessable = `nassessable'"
	
	di as text _n "Sample size using {res}observed values (approximate){txt}:"
	di as text    "    Group 1: {res}`n1_obs'"
	di as text    "    Group 2: {res}`n2_obs'"
	di as text    "      Total: {res}`N_obs'" 
	di as text _n "Sample size using {res}maximum likelihood estimation (more accurate){txt}:"
	di as text    "    Group 1: {res}`n1_mle'"
	di as text    "    Group 2: {res}`n2_mle'"
	di as text    "      Total: {res}`N_mle'" _n

	return scalar N_mle = `N_mle'
	return scalar n2_mle = `n2_mle'
	return scalar n1_mle = `n1_mle'
	return scalar N_obs = `N_obs'
	return scalar n2_obs = `n2_obs'
	return scalar n1_obs = `n1_obs'
		
	return scalar aratio = `aratio'
	return scalar power = `power'
	return scalar alpha = `alpha'
	return scalar delta = `delta'
	return scalar p2 = `p2'
	return scalar p1 = `p1'
end

