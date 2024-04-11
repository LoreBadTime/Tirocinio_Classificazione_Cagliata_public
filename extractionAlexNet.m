% Vecchio script di test

% Caricamento del dataset di interesse, suddiviso in sottocartelle (ogni
% sottocartella è una classe del dataset).
base = mfilename("fullpath");
[pathstr,~,~] = fileparts( base );
pathstr = pathstr+"\";

addpath(pathstr + "Utils\")
addpath(pathstr + "OtherUtils\");
DataPath = pathstr + "1_Processed\Set_4\Set_4_Enhanced\";
reportfile =  pathstr + 'report.txt';
pythonpath =  pathstr + "report.py";


imds = imageDatastore(DataPath,'IncludeSubfolders',true,'LabelSource','foldernames');

% Split del dataset in train e test. Per ora usiamo uno split secco 80%/20%, poi passeremo a una k-fold Cross Validation
[imdsTV, imdsTest] = splitEachLabel(imds,0.8,0.2);

YTrain = imdsTV.Labels; % Label di classe per lo split di training
YTest = imdsTest.Labels; % Label di classe per lo split di test 

alexnet_fc = 'fc6'; % Layer di estrazione scelto per AlexNet

% Estrazione feature alexnet per datastore di training/validation e test.
% l'augmentedImageDatastore viene usato per fare il resize delle immagini
% in input in modo da matchare l'input della rete.
% TV: sta per "TrainValidation", ma per ora non usiamo validation ma usiamo
% esclusivamente uno split secco train/test.

audsTV = augmentedImageDatastore([227 227], imdsTV);
audsTest = augmentedImageDatastore([227 227], imdsTest);

% Estrazione delle feature dal livello "fc_7" di AlexNet
featuresAlexTV = activations(alexnet, audsTV, alexnet_fc, 'MiniBatchSize', 32);

% per ridurre il tutto a una NxM, con M = numero features:
featuresAlexTV = squeeze(featuresAlexTV); 
featuresAlexTV = featuresAlexTV';

% Ripetizione dei passi precedenti per lo split di test
featuresAlexTest = activations(alexnet, audsTest, alexnet_fc, 'MiniBatchSize', 32);
featuresAlexTest = squeeze(featuresAlexTest);
featuresAlexTest = featuresAlexTest';

% Codice per l'addestramento del classificatore kNN, mediante le features 
% estratte da AlexNet.
modelAlexkNN = fitcknn(featuresAlexTV, YTrain);
predAlexkNN = predict(modelAlexkNN, featuresAlexTest);
cmAlexkNN = confusionmat(string(YTest), string(predAlexkNN));


% Estrazione delle statistiche di interesse delle confusion matrix.
% Il file computeMetrics restituisce le metriche di interesse (già inserite
% a mano all'interno del codice) con 3 diverse medie: micro, macro,
% weighted, e una tabella complessiva di riepilogo con i dettagli di tutte
% le classi e generali.

% AlexNet:
[microAlexkNN, macroAlexkNN, wAlexkNN, statsAlexkNN] = computeMetrics(cmAlexkNN);
try
    sendreport(statsAlexkNN,"alexnet",reportfile,DataPath,pythonpath);
catch
end