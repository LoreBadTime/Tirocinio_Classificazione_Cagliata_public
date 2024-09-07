echo off

set testset=10
echo creating merge set (N_sets-set number %testset%)
python -m create_test_set ensemble_inset %testset%