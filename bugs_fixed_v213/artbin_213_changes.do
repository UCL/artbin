/*******************************************************************************
artbin_213_changes.do

Illustrates the main changes between
    OLD: artbin 2.1.2 (19feb2026) 
    NEW: artbin 2.1.3 (26nov2026) 

Each section lists one change, what the old and new versions do

"OLD:" and "NEW:" in the comments give the results from running this file
with each version in StataNow 19 (26nov2026).
*******************************************************************************/

clear all
set more off
args artbin_dir
if `"`artbin_dir'"'=="" local artbin_dir "C:\Users\zcakf79\OneDrive - University College London\Desktop\artbin_bug\artbin-main"
adopath ++ "`artbin_dir'"
discard
which artbin
which art2bin


*==============================================================================
* SECTION A. NEW ERROR MESSAGES (invalid input that used to give a wrong result)
*==============================================================================

*------------------------------------------------------------------------------
* A1. More allocation ratios than groups
*     OLD: for >2 groups the extra ratios were ignored in the calculation but
*          still counted when splitting n between the arms, so n was far too
*          small: pr(.1 .2 .3) gives n = 231, aratios(1 1 1 5) gave n = 87
*          (29 per arm), and the table showed the allocation ratio as 1:1:1.
*          For 2 groups the error was "Invalid allocation ratio".
*     NEW: error "Please specify the same number of aratios() as pr()".
*------------------------------------------------------------------------------
artbin, pr(.1 .2 .3)
cap noi artbin, pr(.1 .2 .3) aratios(1 1 1 5)
cap noi artbin, pr(.1 .2) aratios(1 2 3)

*------------------------------------------------------------------------------
* A2. margin() must lie strictly between -1 and 1 (artbin and art2bin)
*     OLD: no check. Message "You have found a case that we have never
*          encountered before! ..." and then a result: n = 2 for
*          margin(1), and a missing n (".") for margin(-1.5).
*     NEW: error "Margin must lie strictly between -1 and 1".
*------------------------------------------------------------------------------
cap noi artbin, pr(.2 .2) margin(1)
cap noi artbin, pr(.2 .2) margin(-1.5)
cap noi art2bin 0.2 0.2, margin(1)

*------------------------------------------------------------------------------
* A3. doses() checks (>2 groups, trend test)
*     OLD: doses(1 2 3 4) silently dropped the 4th dose (n = 186);
*          doses(2 2 2) gave a missing sample size (".").
*     NEW: errors "Please specify the same number of doses() as pr()." and
*          "doses() must contain at least two distinct values."
*------------------------------------------------------------------------------
cap noi artbin, pr(.1 .2 .3) doses(1 2 3 4)
cap noi artbin, pr(.1 .2 .3) doses(2 2 2)

*------------------------------------------------------------------------------
* A4. ccorrect with nchi (2 groups)
*     OLD: ccorrect was accepted and the table said "Continuity correction
*          yes", but it was not applied (n = 124 with and without ccorrect).
*     NEW: error "ccorrect is not available with nchi".
*------------------------------------------------------------------------------
artbin, pr(.1 .3) nchi
cap noi artbin, pr(.1 .3) nchi ccorrect

*------------------------------------------------------------------------------
* A5. nvmethod() must be 1, 2 or 3 (artbin and art2bin)
*     OLD: nvmethod(5) and nvmethod(0) were silently reset to 3 (n = 398);
*          nvmethod(2.5) failed with "unknown function *()".
*     NEW: error "nvmethod() must be 1, 2 or 3".
*------------------------------------------------------------------------------
cap noi artbin, pr(.1 .2) nvmethod(5)
cap noi artbin, pr(.1 .2) nvmethod(2.5)
cap noi art2bin 0.1 0.2, nvmethod(0)

*------------------------------------------------------------------------------
* A6. convcrit() smaller than 1E-15
*     OLD: only a warning "convcrit < 1E-15: program may hang", then the
*          calculation went ahead (here n = 231).
*     NEW: error "convcrit() must be at least 1E-15".
*------------------------------------------------------------------------------
cap noi artbin, pr(.1 .2 .3) convcrit(1e-16)
artbin, pr(.1 .2 .3) convcrit(1e-15)

*------------------------------------------------------------------------------
* A7. ap2() has no effect
*     OLD: ap2() was range-checked but only used in code that cannot be
*          reached, so a valid value was silently ignored.
*     NEW: a valid ap2() gives the warning "ap2() has no effect and is
*          ignored."; an out-of-range value still gives an error.
*------------------------------------------------------------------------------
artbin, pr(.2 .2) margin(.1)
artbin, pr(.2 .2) margin(.1) ap2(.4)
cap noi artbin, pr(.2 .2) margin(.1) ap2(1.5)


*==============================================================================
* SECTION B. BUG FIXES THAT CHANGE THE CALCULATED SAMPLE SIZE OR POWER
*==============================================================================

*------------------------------------------------------------------------------
* B1. Iterative sample-size search for >2 groups (distant method)
*     OLD: the search interval [n0/2, 2*n0] was not checked to contain the
*          solution, so n could be too small: n = 104 (65 13 13 13).
*     NEW: the interval is widened until it contains the solution:
*          n = 111 (69 14 14 14).
*     The power at the old n = 104 is 0.987, below the 0.99 requested.
*------------------------------------------------------------------------------
artbin, pr(.001 .002 .003 .5) aratios(5 1 1 1) power(.99)
artbin, pr(.001 .002 .003 .5) aratios(5 1 1 1) n(104)

*------------------------------------------------------------------------------
* B2. Power close to 1 for >2 groups (noncentral chi-square out of range)
*     OLD: power shown as missing (".") and the sample-size search went the
*          wrong way: pr(.001 .5 .999) power(.99) gave n = 66.
*     NEW: new subprogram _nchi2 (nchi2() under version 13, then a normal
*          approximation): n = 12, and power 1.000 instead of ".".
*------------------------------------------------------------------------------
artbin, pr(.001 .5 .999) power(.99)
artbin, pr(.001 .5 .999) n(66)
artbin, pr(.01 .5 .99) n(1000)

*------------------------------------------------------------------------------
* B3. Power approximation not valid at very small n (>2 groups, distant)
*     OLD: n(3) gave power "."; power(.06) gave n = 9 and power(.05) gave
*          n = 0, where the approximation is not valid.
*     NEW: n(3): error "Power approximation not valid for n = 3; sample size
*          too small". power(.06) and power(.05): error giving the smallest
*          valid n (9.49) and the power there (0.075).
*     (power(.05), i.e. power = alpha, hung in an earlier draft of 2.1.3: the
*     search started at n0 = 0 and doubled it forever. It now starts at n = 1.)
*------------------------------------------------------------------------------
cap noi artbin, pr(.1 .2 .3) n(3)
cap noi artbin, pr(.1 .2 .3) power(.06)
cap noi artbin, pr(.1 .2 .3) power(.05)

*------------------------------------------------------------------------------
* B4. condit with a single allocation ratio
*     OLD: calculated n for equal allocation, then split it 1:2:
*          aratios(2) gave 374 (125 249), but aratios(1 2) gave 465.
*     NEW: aratios(2) is treated as aratios(1 2): both give 465 (155 310).
*------------------------------------------------------------------------------
artbin, pr(.2 .1) condit aratios(2)
artbin, pr(.2 .1) condit aratios(1 2)

*------------------------------------------------------------------------------
* B5. nchi with a single allocation ratio (2 groups)
*     OLD: aratio(2) gave 125 (42 83, equal allocation split 1:2);
*          aratio(1 2) gave 146.
*     NEW: both give 146 (49 97).
*------------------------------------------------------------------------------
artbin, pr(.1 .3) nchi aratio(2)
artbin, pr(.1 .3) nchi aratio(1 2)

*------------------------------------------------------------------------------
* B6. Continuity correction for power at very small n
*     OLD: _cc deflation was applied even when n <= a/2, so power fell as n
*          rose: n = 4, 8, 12 gave power 0.106, 0.033, 0.030.
*     NEW: for n <= a/2 the corrected n is set to 0 (minimum power), so power
*          no longer decreases: 0.021, 0.021, 0.030.
*------------------------------------------------------------------------------
artbin, pr(.1 .3) n(4) ccorrect
artbin, pr(.1 .3) n(8) ccorrect
artbin, pr(.1 .3) n(12) ccorrect

*------------------------------------------------------------------------------
* B7. art2bin returned results with ccorrect in power mode
*     OLD: n0 was overwritten by the continuity-corrected n, so r(Dart)
*          (expected number of events) was wrong: 39.025. r(n), r(n0), r(n1)
*          were not returned and r(power) was a local (string).
*     NEW: r(Dart) = 40 (100*0.1 + 100*0.3); r(n) = 200, r(n0) = r(n1) = 100
*          and r(power) are returned as scalars.
*------------------------------------------------------------------------------
art2bin 0.1 0.3, n(200) ccorrect
return list

*------------------------------------------------------------------------------
* B8. force with a non-zero margin(): trial type and hypotheses
*     OLD: with force the table showed the stated (unfavourable) direction:
*          non-inferiority, H1: pi2 - pi1 < .05, but n was calculated for
*          the other direction.
*     NEW: the table shows the design that was calculated (substantial-
*          superiority, H1: pi2 - pi1 > .05), with the note "with force,
*          sample size/power are calculated for H1: pi2 - pi1 > .05".
*------------------------------------------------------------------------------
cap noi artbin, pr(.2 .3) margin(.05) unfavourable
artbin, pr(.2 .3) margin(.05) unfavourable force
artbin, pr(.2 .3) margin(.05) favourable

*------------------------------------------------------------------------------
* B9a. notable in power mode: r(n) is returned
*     OLD: r(n) = .   NEW: r(n) = 1000.
*------------------------------------------------------------------------------
artbin, pr(.1 .2) n(1000) notable
display "r(n) = " r(n) "   r(power) = " r(power)

*------------------------------------------------------------------------------
* B9b. notable in sample-size mode: r(power) is returned
*     OLD: r(power) = .   NEW: r(power) = .8 (the power used).
*------------------------------------------------------------------------------
artbin, pr(.1 .2) notable
display "r(n) = " r(n) "   r(power) = " r(power)


*==============================================================================
* SECTION C. NEW OPTION AND NEW WARNINGS
*==============================================================================

*------------------------------------------------------------------------------
* C1. art2bin now accepts force
*     OLD: art2bin's error message suggests -force-, but force was not in its
*          syntax: "option force not allowed".
*     NEW: force overrides the check with a warning (n = 2334).
*------------------------------------------------------------------------------
cap noi art2bin 0.2 0.3, margin(0.05) unfavourable
cap noi art2bin 0.2 0.3, margin(0.05) unfavourable force

*------------------------------------------------------------------------------
* C2. favourable/unfavourable/force ignored for >2 groups
*     OLD: silently ignored.
*     NEW: warning "favourable/unfavourable/force are ignored for >2 groups."
*------------------------------------------------------------------------------
artbin, pr(.1 .2 .3) favourable
artbin, pr(.1 .2 .3) unfavourable force

*------------------------------------------------------------------------------
* C3. nvmethod() ignored for >2 groups or with condit
*     OLD: silently ignored, except with local or wald for >2 groups, where
*          the 2-group checks still ran and gave an error: local nvm(1) gave
*          "Need nvm(3) if local specified" and wald nvm(3) gave "Need nvm(1)
*          if Wald specified".
*     NEW: warning "nvmethod() is only used for 2-group unconditional tests
*          and is ignored."; with local or wald the result is now calculated:
*          n = 234 (local) and n = 207 (wald).
*------------------------------------------------------------------------------
artbin, pr(.1 .2 .3) nvmethod(1)
artbin, pr(.2 .1) condit nvmethod(1)
cap noi artbin, pr(.1 .2 .3) local nvmethod(1)
cap noi artbin, pr(.1 .2 .3) wald nvmethod(3)


*==============================================================================
* SECTION D. OUTPUT TABLE CHANGES (no change to the results)
*==============================================================================

*------------------------------------------------------------------------------
* D1. American spellings favorable/unfavorable
*     OLD: the table said the outcome was "Inferred by the program".
*     NEW: reported as specified by the user, as for the British spellings.
*------------------------------------------------------------------------------
artbin, pr(.2 .3) favorable
artbin, pr(.2 .3) favourable
artbin, pr(.3 .2) unfavorable

*------------------------------------------------------------------------------
* D2. Non-integer allocation ratios (>2 groups)
*     OLD: rounded in the table: 1:2:2 and 1:2:4.
*     NEW: shown unrounded: 1:1.5:2 and 1:2.25:3.5.
*------------------------------------------------------------------------------
artbin, pr(.1 .2 .3) aratios(1 1.5 2)
artbin, pr(.1 .2 .3) aratios(1 2.25 3.5)

*------------------------------------------------------------------------------
* D3. Large sample sizes and numbers of events (>= 1,000,000)
*     OLD: rounded to 3 significant figures in the table: n = 7850000,
*          3920000 per group, even with noround.
*     NEW: shown in full: n = 7848870, 3924435 per group; with noround,
*          n = 7848869.5, 3924434.8 per group.
*------------------------------------------------------------------------------
artbin, pr(.5 .501)
artbin, pr(.5 .501) noround

*------------------------------------------------------------------------------
* D4. Very small event probabilities in pr()
*     OLD: shown as 0.000 0.000.
*     NEW: shown with enough digits: 0.0001 0.0002.
*     (For 2 groups the double space between probabilities is also gone.)
*------------------------------------------------------------------------------
artbin, pr(.0001 .0002)
artbin, pr(.0001 .0002 .0003)

*------------------------------------------------------------------------------
* D5. "(taken as alpha/2 one-sided)" line
*     OLD: missing for >2 groups with trend/doses, for 2 groups with nchi, and
*          for condit, although all use alpha/2.
*     NEW: shown for all two-sided tests that use alpha/2; still not shown for
*          the >2-group chi-square test, which uses the full alpha.
*------------------------------------------------------------------------------
artbin, pr(.1 .2 .3) trend
artbin, pr(.1 .3) nchi
artbin, pr(.1 .2 .3)

*------------------------------------------------------------------------------
* D6. Conditional test no longer labelled as a score test
*     OLD: "... using the score test" was also shown with condit.
*     NEW: not shown with condit.
*------------------------------------------------------------------------------
artbin, pr(.2 .1) condit
artbin, pr(.1 .2 .3) condit

*------------------------------------------------------------------------------
* D7. doses() shown as entered
*     OLD: rounded to 2 decimal places: 0.00, 0.13, 0.50 and
*          1.00, 1.00, 2.00, 4.00.
*     NEW: shown as entered: 0, 0.125, 0.5 and 1, 1.005, 2, 4.
*------------------------------------------------------------------------------
artbin, pr(.1 .2 .3) doses(0 0.125 0.5)
artbin, pr(.1 .2 .3 .4) doses(1 1.005 2 4)

*------------------------------------------------------------------------------
* D8. Wording of error messages ("Can not" -> "Cannot")
*------------------------------------------------------------------------------
cap noi artbin, pr(.1 .2 .3) margin(.1)
cap noi artbin, pr(.2 .3) favourable unfavourable


*==============================================================================
* SECTION E. DIALOG BOX (artbin.dlg version 2.3)
*     - New "force" checkbox.
*     - Switching to "Specify sample size" now clears the Power/N box.
*==============================================================================
* db artbin

adopath - "`artbin_dir'"
