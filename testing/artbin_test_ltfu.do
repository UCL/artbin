/*
artbin_test_ltfu.do
new testing file for artbin
IW 14/11/2023
*/
pda

* evaluate ltfu() for power->n
artbin, pr(.02 .02) margin(.02) noround
local n=r(n)
artbin, pr(.02 .02) margin(.02) noround ltfu(.1)
di r(n),`n'/0.9
assert reldif(r(n),`n'/0.9) < 1E-7


* evaluate ltfu() for n->power
artbin, pr(.02 .02) margin(.02) noround n(1000) ltfu(.2)
local power=r(power)
artbin, pr(.02 .02) margin(.02) noround n(800)
di r(power),`power'
assert reldif(r(power),`power') < 1E-7


* check ltfu() option by converting power to n and back
local norig 1000
local opts pr(.02 .02) margin(.02) ltfu(0.1) 
artbin, `opts' n(`norig')
local power = r(power)
artbin, `opts' power(`power') noround
di r(n), `norig'
assert reldif(r(n), `norig') < 1E-7

* at present specifying ltfu() with n() leads n() to be inflated

* check it works with non-integer ltfu*n
artbin, pr(.02 .02) margin(.02) ltfu(.05) n(1836)

* check total sample size (designed) is correct
artbin, pr(.02 .02) margin(.02) ltfu(.05) n(1000)
assert r(n)=950
