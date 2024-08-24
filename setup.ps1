#Requires -RunAsAdministrator
Invoke-WebRequest -Uri https://www.mathworks.com/mpm/win64/mpm -OutFile mpm.exe
./mpm install --release R2024a --destination "C:\Users\$($env:username)\matlab" --products Computer_Vision_Toolbox Deep_Learning_HDL_Toolbox Deep_Learning_Toolbox
./mpm install --release R2024a --destination "C:\Users\$($env:username)\matlab" --products Deep_Learning_Toolbox_Model_for_AlexNet_Network Deep_Learning_Toolbox_Model_for_DarkNet-19_Network
./mpm install --release R2024a --destination "C:\Users\$($env:username)\matlab" --products Deep_Learning_Toolbox_Model_for_DarkNet-53_Network Deep_Learning_Toolbox_Model_for_DenseNet-201_Network
./mpm install --release R2024a --destination "C:\Users\$($env:username)\matlab" --products Deep_Learning_Toolbox_Model_for_EfficientNet-b0_Network Deep_Learning_Toolbox_Model_for_GoogLeNet_Network
./mpm install --release R2024a --destination "C:\Users\$($env:username)\matlab" --products Deep_Learning_Toolbox_Model_for_Inception-ResNet-v2_Network Deep_Learning_Toolbox_Model_for_Inception-v3_Network
./mpm install --release R2024a --destination "C:\Users\$($env:username)\matlab" --products Deep_Learning_Toolbox_Model_for_MobileNet-v2_Network Deep_Learning_Toolbox_Model_for_NASNet-Large_Network
./mpm install --release R2024a --destination "C:\Users\$($env:username)\matlab" --products Deep_Learning_Toolbox_Model_for_NASNet-Mobile_Network 
./mpm install --release R2024a --destination "C:\Users\$($env:username)\matlab" --products Deep_Learning_Toolbox_Model_for_ResNet-101_Network Deep_Learning_Toolbox_Model_for_ResNet-18_Network
./mpm install --release R2024a --destination "C:\Users\$($env:username)\matlab" --products Deep_Learning_Toolbox_Model_for_ResNet-50_Network Deep_Learning_Toolbox_Model_for_ShuffleNet_Network
./mpm install --release R2024a --destination "C:\Users\$($env:username)\matlab" --products Deep_Learning_Toolbox_Model_for_VGG-16_Network Deep_Learning_Toolbox_Model_for_VGG-19_Network
./mpm install --release R2024a --destination "C:\Users\$($env:username)\matlab" --products Deep_Learning_Toolbox_Model_for_Xception_Network
./mpm install --release R2024a --destination "C:\Users\$($env:username)\matlab" --products Image_Processing_Toolbox Statistics_and_Machine_Learning_Toolbox
Remove-Item .\mpm.exe