echo off
set testset=15

echo creating training set (number %testset%)
python -m create_test_set ensemble_inset %testset%


matlab -batch "classificatore_unificato('23', '21', '13','12', '1')"  
matlab -batch "classificatore_unificato('23', '21', '13','14', '1')" 
matlab -batch "classificatore_unificato('23', '21', '13','5', '1')" 
matlab -batch "classificatore_unificato('23', '21', '13','4', '1')" 
matlab -batch "classificatore_unificato('23', '21', '13','6', '1')" 
matlab -batch "classificatore_unificato('23', '21', '13','9', '1')" 
matlab -batch "classificatore_unificato('23', '21', '13','10', '1')" 
matlab -batch "classificatore_unificato('23', '21', '13','11', '1')"
