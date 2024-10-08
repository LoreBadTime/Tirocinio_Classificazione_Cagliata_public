set testset=10
set filter=Enhanced
:: automatic tests for specified set and specified filter 

echo off

set var=%~dp0test\test_feature_selection
set var=%var:\=/%
:: mutual information test(THIS TEST WILL BE SKIPPED IF SCIKIT/NUMPY ARE NOT INSTALLED)
echo Test mutual information
set test_mutual_info=base = mfilename("fullpath");[pathstr,~,~] = fileparts( base );pathstr = pathstr+"\";addpath(pathstr +"test");cd(pathstr+"test");test_feature_selection("%testset%", "%filter%")

echo %test_mutual_info% > testmf.m

matlab -batch "run('testmf.m')" && del testmf.m && python test/test1.py ^
&& echo Generated mutual info test score by matlab and python, please check mutual_info files in "./test" directory

echo:
echo creating merge set (N_sets-set number %testset%)
python -m create_test_set merge %testset%


:: matlab has a different random generation from python so the noise added to mutual inform
:: algorithm could give different numbers, the difference can be seen only from the fifth/six decimal digit 
:: also matlab has formatted everything to its notation, so watch the numbers after the zeroes
:: matlab prints this format rows (index/1000,mutual_info_score/1000) where 
:: python outputs just a list of scores normally

 
:: every test made with filter and set (No ensemble for now) (Enhanced, set testset), PARSED REPORTING AVAIABLE ONLY USING PYTHON 
:: can be parallelized (just change the && with "start /high")
echo starting tests for dataset and filter
echo k_fold sequential inset %testset% ^
&& runmatlab.bat kfold_extractionFromModel %testset% %filter% 1 ^
echo  k_fold shuffle inset %testset% ^
&& runmatlab.bat shuffle_kfold_extractionFromModel %testset% %filter% 1 ^
echo  n-1 marge,n excluded in test sequential %testset% ^
&& runmatlab.bat set_extractionFromModel %testset% %filter% 1 ^
echo  n-1 marge,n excluded in test shuffle %testset% ^
&& runmatlab.bat set_shuffle_extractionFromModel %testset% %filter% 1 ^
echo  n-1 merge %testset% ,n exluded feature selection Mutual info static (already-calculated features to select in a file) ^
&& runmatlab.bat set_fselectionmerged_shuffle_extractionFromModel %testset% %filter% 1 ^
echo  n-1 merge %testset% ,n exluded feature selection Mutual info dynamic (features to select calculated on the go) ^
&& runmatlab.bat set_fselectionmerged_shuffle_extractionFromModel %testset% %filter% 2  

echo:
echo test terminated, parsed results are in './results/' directory
:: enseble tests not provided for now (needs special configuration)