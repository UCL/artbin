/*
MAIN TESTING FILE FOR ARTBIN v2.0.1
EMZ and IW, 13june2022
*/

clear all
set more off
prog drop _all

local cd C:\git\artbin\testing\


// 1. We compared results for non-inferiority trials with those given by \citet{Julious2011}, \citet{Blackwelder1982}, \citet{Pocock2003} and the online calculator \citet{SealedEnvelope2012}. Exact agreement was achieved.  


do `cd'artbin_testing_1


// 2. We compared results for a superiority binary outcome with those given by \citet{Pocock83} and the online calculator \citet{SealedEnvelope2012}. Exact agreement was achieved. 


do `cd'artbin_testing_2


// 3. We tested a range of scenarios including continuity correction results given by \texttt{artbin} and those given by the Stata program \texttt{power}.  The results from both programs were in agreement.  


do `cd'artbin_testing_3


// 4. We checked the results given by \texttt{artbin} using the  \texttt{margin} option against \citet{Julious2011}.  Exact agreement was achieved. 


do `cd'artbin_testing_4


// 5. The output of \texttt{artbin} was compared to Cytel’s software EAST which is a sophisticated package able to produce sample size and power calculations for a range of binary outcomes in clinical trial settings.  We achieved perfect agreement in all but a handful of cases where the sample size differerd by 1, which we believe is due to the difference in the way the packages round sample size.    


do `cd'artbin_testing_5


// 6. For the new 'switch-on' syntax options we tested \texttt{onesided} for a one-sided test and \texttt{ccorrect} to apply a continuity correction.


do `cd'artbin_testing_6


// 7. We tested every permuation of 2-arm/more than 2-arms and non-inferiority/substantial-superiority/superiority trials with margin, local/distant, conditional/unconditional, trend and Wald test options to check that the results were as expected, and that sample size was increased/decreased accordingly.


do `cd'artbin_testing_7
do `cd'\IW_testing\explore_every_option
do `cd'\IW_testing\explore_artbin


// 8. We checked error messages in a number of impossible cases, to ensure that we obtained error messages as required.


do `cd'artbin_errortest_8


// Also we tested the dialogue box menu options to verify that the results were as required.  


* See artbin_dlgboxtesting_9.do


// Note: We re-ran the test scripts #1,2,3,4 and 6 implementing the above tests with the default variable type (\texttt{set type}) as \texttt{float} and as \texttt{double}.



/*** END OF MAIN TESTING PROGRAM FOR ARTBIN ***/