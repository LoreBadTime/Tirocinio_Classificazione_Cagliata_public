echo off
set trainset=15
set filterset=13
echo creating training set (number %trainset%)
python -m create_test_set ensemble_inset %trainset%


matlab -batch "classificatore_unificato('23', '21', '%filterset%','14', '1')" 
matlab -batch "classificatore_unificato('23', '21', '%filterset%','5', '1')" 
matlab -batch "classificatore_unificato('23', '21', '%filterset%','4', '1')" 
matlab -batch "classificatore_unificato('23', '21', '%filterset%','6', '1')" 
matlab -batch "classificatore_unificato('23', '21', '%filterset%','9', '1')" 
matlab -batch "classificatore_unificato('23', '21', '%filterset%','10', '1')" 
matlab -batch "classificatore_unificato('23', '21', '%filterset%','11', '1')"
matlab -batch "classificatore_unificato('23', '21', '%filterset%','12', '1')"  
