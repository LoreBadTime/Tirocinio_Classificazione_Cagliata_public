
:: automatic test for set 5 (see create_test_set.pt)

:: creating merge set (N_sets-set number 5)
::python -m create_test_set

echo on
set var=%~dp0test\test_feature_selection
set var=%var:\=/%
:: matlab has a different random generation from python so the noise added to mutual inform
:: algorithm could give different numbers, the difference can be seen only from the fifth/six decimal digit 
:: also matlab has formatted everything to its notation, so watch the numbers after the zeroes
:: matlab prints this format rows (index/1000,mutual_info_score/1000) where 
:: python outputs just a list of scores normally  
matlab -batch "run('%var%.m')" && python test/test1.py

start /high runmatlab.bat kfold_extractionFromModel 5 Enhanced 1
start /high runmatlab.bat shuffle_kfold_extractionFromModel 5 Enhanced 1
start /high runmatlab.bat set_extractionFromModel 5 Enhanced 1
start /high runmatlab.bat set_shuffle_extractionFromModel 5 Enhanced 1
start /high runmatlab.bat set_fselectionmerged_shuffle_extractionFromModel 5 Enhanced 1
start /high runmatlab.bat set_fselectionmerged_shuffle_extractionFromModel 5 Enhanced 2
