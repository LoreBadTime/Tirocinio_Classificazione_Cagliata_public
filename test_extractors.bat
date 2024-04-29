
:: automatic test for set 5
set testset=5
set filter=Enhanced

:: creating merge set (N_sets-set number 5)
python -m create_test_set merge %testset%

:: mutual information test(COMMENT THIS TEST IF SCIKIT/NUMPY ARE NOT INSTALLED)
echo on
set var=%~dp0test\test_feature_selection
set var=%var:\=/%
:: matlab has a different random generation from python so the noise added to mutual inform
:: algorithm could give different numbers, the difference can be seen only from the fifth/six decimal digit 
:: also matlab has formatted everything to its notation, so watch the numbers after the zeroes
:: matlab prints this format rows (index/1000,mutual_info_score/1000) where 
:: python outputs just a list of scores normally  
matlab -batch "run('%var%.m')" && python test/test1.py ^
:: every test made with filter and set (No ensemble for now) (Enhanced, set 5), PARSED REPORTING AVAIABLE ONLY USING PYTHON ^
:: can be parallelized (just change the && with "start /high")^
:: k_fold sequential inset ^
&& runmatlab.bat kfold_extractionFromModel %testset% %filter% 1 ^
:: k_fold shuffle inset ^
&& runmatlab.bat shuffle_kfold_extractionFromModel %testset% %filter% 1 ^
:: n-1 marge,n excluded in test sequential ^
&& runmatlab.bat set_extractionFromModel %testset% %filter% 1 ^
:: n-1 marge,n excluded in test shuffle ^
&& runmatlab.bat set_shuffle_extractionFromModel %testset% %filter% 1 ^
:: n-1 merge,n exluded feature selection Mutual info static (already-calculated features to select in a file) ^
&& runmatlab.bat set_fselectionmerged_shuffle_extractionFromModel %testset% %filter% 1 ^
:: n-1 merge,n exluded feature selection Mutual info dynamic (features to select calculated on the go) ^
&& runmatlab.bat set_fselectionmerged_shuffle_extractionFromModel %testset% %filter% 2  

:: enseble tests not provided for now (needs special configuration)