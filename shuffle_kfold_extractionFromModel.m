% reporting in set k-folding con shuffle
% non varia molto dalle versioni set_extraction, solo che in questo caso il dataset in train e in test è lo stesso
function [k_classificatori_affidabili] = shuffle_kfold_extractionFromModel(Dataset,Datasetype,Report)


setkey = "_" + Datasetype;
set = setkey + "\";
setnum = "Set_" + Dataset;
base = mfilename("fullpath");
[pathstr,~,~] = fileparts( base );
pathstr = pathstr+"\";
addpath(pathstr + "Utils\");
addpath(pathstr + "OtherUtils\");

DataPath = pathstr +'1_Processed\'+ setnum + "\"+ setnum + set;
reportfile = pathstr + 'report'+ setkey + "inset_kfold_shuffle" + setnum +'.txt';
pythonpath =  pathstr + "report.py";



imds = imageDatastore(DataPath,'IncludeSubfolders',true,'LabelSource','foldernames');
imds = shuffle(imds);


kfolds = shuffle_getkfoldsets(imds,5);
k_classificatori_affidabili = {};
k_stats = {};
fscores = table(0,0,0,0,0);


% k-folding, attenzione che non ho indentato bene

for n = 1:length(kfolds)
%non sono riuscito a trovare squeezenet
models = {alexnet,"alexnet",'fc6'; ...
        resnet50,"resnet50",'avg_pool'; ...
        resnet18,"resnet18",'pool5'; ...
        googlenet,"googlenet",'pool5-7x7_s1'; ...
        inceptionv3,"inceptionv3",'avg_pool'; ...
        densenet201,"densenet201",'avg_pool'; ...
        mobilenetv2,"mobilenetv2",'global_average_pooling2d_1'; ...
        resnet101,"resnet101",'pool5'; ...
        xception,"xception",'avg_pool'; ...
        inceptionresnetv2,"inceptionresnetv2",'avg_pool'; ...
        nasnetlarge,"nasnetlarge",'global_average_pooling2d_2'; ...
        nasnetmobile,"nasnetmobile",'global_average_pooling2d_1'; ...
        darknet19,"darknet19",'avg1'; ...
        darknet53,"darknet53",'avg1'; ... 
        shufflenet,"shufflenet",'node_200'; ...
        efficientnetb0,"efficientnetb0",'efficientnet-b0|model|head|global_average_pooling2d|GlobAvgPool'; ...
        vgg16,"vgg16",'fc6'; ...
        vgg19,"vgg19",'fc6'};
classificatori = {
    @fitcknn,"k nearest n"; ...
    @normfitcnet,"neural net"; ...
    @fitctree, "decision tree"; ...
    @fitcsvm, "SVM lineare"; ...
    @customtreebagger, "Random Forest"; ...
    @customfitcdiscr, "discriminante lineare"
};



fold = kfolds{1,n};

imdsTV = fold{1,1};
imdsTest = fold{1,2};

% label sono negativi o positivi
YTrain = imdsTV.Labels; % Label di classe per lo split di training
YTest = imdsTest.Labels; % Label di classe per lo split di test 

% Estrazione feature alexnet per datastore di training/validation e test.
% l'augmentedImageDatastore viene usato per fare il resize delle immagini
% in input in modo da matchare l'input della rete.
% TV: sta per "TrainValidation", ma per ora non usiamo validation ma usiamo
% esclusivamente uno split secco train/test.
stats = table((length(classificatori)),[(length(models)),0],0,0,0);
stats.Properties.VariableNames = {'name','classes','macroAVG','microAVG','weightAVG'};
classificatori_affidabili = {};
theshold_affidabilita_fscore = 0.8;

for i = 1:length(models)
    model = models{i,1};
    size = model.Layers(1).InputSize(1:3);
    % display(size)
    audsTV = augmentedImageDatastore(size, imdsTV,'ColorPreprocessing', 'gray2rgb');
    audsTest = augmentedImageDatastore(size, imdsTest,'ColorPreprocessing', 'gray2rgb');
    layer = models{i,3};
    [feature,featureTest] = extractfeatures(model, audsTV ,audsTest,layer);
    name = models{i,2};
    a = [table({"modello : " + name},[0,0],0,0,0);table({"dataset : "+ DataPath},[0,0],0,0,0)];
    a.Properties.VariableNames = {'name','classes','macroAVG','microAVG','weightAVG'};
    for l = 1:length(classificatori)
        classificatore = classificatori{l,1};
        b = table({classificatori{l,2}},[0,0],0,0,0);
        b.Properties.VariableNames = {'name','classes','macroAVG','microAVG','weightAVG'};
        stats = [stats;[a;b]];
        [microkNN, macrokNN, wkNN, stats1, fscore, model_classificatore] = calculuatestats(feature,featureTest,classificatore,YTrain,YTest);
        stats = [stats;stats1];
        if fscore > theshold_affidabilita_fscore
            fscores{1,n} = fscores{1,n} + 1;
            %classificatori_affidabili{numel(classificatori_affidabili) + 1} = {name,classificatori{l,2},fscore,model_classificatore,size,model,layer};
        end
    end
end
%k_classificatori_affidabili{numel(k_classificatori_affidabili) + 1} =  classificatori_affidabili;
a = table({"end" + name},[0,0],0,0,0);
a.Properties.VariableNames = {'name','classes','macroAVG','microAVG','weightAVG'};
stats = [stats;a];
k_stats{numel(k_stats) + 1} = stats;
end
classificatori_affidabili = {};
display(fscores);
% calcolo media tra le tabelle k-fold
fstats = table(stats{1,1},stats{1,2},0,0,0);
fstats.Properties.VariableNames = {'name','classes','macroAVG','microAVG','weightAVG'};
for i = 2:height(stats)
        class_a = (k_stats{1,1}{i,2}(1) + k_stats{1,2}{i,2}(1) + k_stats{1,3}{i,2}(1) + k_stats{1,4}{i,2}(1) + k_stats{1,5}{i,2}(1))/5;
        class_b = (k_stats{1,1}{i,2}(2) + k_stats{1,2}{i,2}(2) + k_stats{1,3}{i,2}(2) + k_stats{1,4}{i,2}(2) + k_stats{1,5}{i,2}(2))/5;
        macroavg = (k_stats{1,1}{i,3}+    k_stats{1,2}{i,3}+k_stats{1,3}{i,3}+k_stats{1,4}{i,3}+k_stats{1,5}{i,3})/5;
        microavg = (k_stats{1,1}{i,4}+    k_stats{1,2}{i,4}+k_stats{1,3}{i,4}+k_stats{1,4}{i,4}+k_stats{1,5}{i,4})/5;
        weighted = (k_stats{1,1}{i,5}+    k_stats{1,2}{i,5}+k_stats{1,3}{i,5}+k_stats{1,4}{i,5}+k_stats{1,5}{i,5})/5;
        tmp = table(stats{i,1},[class_a,class_b],macroavg,microavg,weighted);
        tmp.Properties.VariableNames = {'name','classes','macroAVG','microAVG','weightAVG'};
        fstats = [fstats;tmp];
end
try
    if Report == "1"
        sendreport(fstats,reportfile,pythonpath,setkey);
    end
catch
end


%display(classificatori_affidabili);
end
% funzioni customizzate di setting dei classificatori
function [fun] = normfitcnet(dataset,Labels)
    fun = fitcnet((im2double(dataset)),Labels);
end
function [fun] = customtreebagger(dataset,Labels)
    numtrees = 100;
    fun = TreeBagger(numtrees, dataset,Labels,'Method', 'classification');
end
function [fun] = customfitcdiscr(dataset,Labels)
    fun = fitcdiscr(dataset,Labels,'discrimType','pseudoLinear');
end