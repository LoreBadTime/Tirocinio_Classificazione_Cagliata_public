% extaction from model di test che utilizza un terzo layer di filtraggio, usata per l'enseble



function [classificatori_affidabili] = extractionFromModel_test(DatasetTrain,DatasetFscore,Datasetype,Report,thirdLayerset,thirdlayer)

% Caricamento del dataset di interesse, suddiviso in sottocartelle (ogni
% sottocartella è una classe del dataset).
% (path,foldermode,settingmode,labelimmagini,labelsettings)


setkey = "_" + Datasetype;
set = setkey + "\";
setnum = "Set_" + DatasetFscore;
base = mfilename("fullpath");
[pathstr,~,~] = fileparts( base );
pathstr = pathstr+"\";

addpath(pathstr + "Utils\")
addpath(pathstr + "OtherUtils\");
pythonpath =  pathstr + "report.py";
DataPathTest = pathstr +"1_Processed\"+ setnum + "\"+ setnum + set;
DataPathTrain = pathstr +"1_Processed\"+ 'Set_'+DatasetTrain+ "\Set_"+DatasetTrain+ set;
DataPath3Layer = pathstr + "1_Processed\" + 'Set_'+ thirdLayerset + "\Set_"+ thirdLayerset + set;
reportfile = pathstr + "1_Processed\" + 'report'+ setkey + setnum +'.txt';


imdsTest = imageDatastore(DataPathTest,'IncludeSubfolders',true,'LabelSource','foldernames');
imdsTV = shuffle(imageDatastore(DataPathTrain,'IncludeSubfolders',true,'LabelSource','foldernames'));
imdsThirdLayer = imageDatastore(DataPath3Layer,'IncludeSubfolders',true,'LabelSource','foldernames');

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


% Split del dataset in train e test. Per ora usiamo uno split secco 80%/20%, poi passeremo a una k-fold Cross Validation
% 

 %set 21 testing, set 26 training

% label sono negativi o positivi
YTrain = imdsTV.Labels; % Label di classe per lo split di training
YTest = imdsTest.Labels; % Label di classe per lo split di test 
YThird = imdsThirdLayer.Labels;
% Estrazione feature alexnet per datastore di training/validation e test.
% l'augmentedImageDatastore viene usato per fare il resize delle immagini
% in input in modo da matchare l'input della rete.
% TV: sta per "TrainValidation", ma per ora non usiamo validation ma usiamo
% esclusivamente uno split secco train/test.
stats = table((length(classificatori)),[(length(models)),0],0,0,0);
stats.Properties.VariableNames = {'name','classes','macroAVG','microAVG','weightAVG'};
classificatori_affidabili = {};
theshold_affidabilita_fscore = 0.99;

for i = 1:length(models)
    model = models{i,1};
    size = model.Layers(1).InputSize(1:3);
    % display(size)
    audsTV = augmentedImageDatastore(size, imdsTV,'ColorPreprocessing', 'gray2rgb');
    audsTest = augmentedImageDatastore(size, imdsTest,'ColorPreprocessing', 'gray2rgb');
    layer = models{i,3};
    [feature,featureTest] = extractfeatures(model, audsTV ,audsTest,layer);
    name = models{i,2};
    a = [table({"modello : " + name},[0,0],0,0,0);table({"dataset : "+ DataPathTest},[0,0],0,0,0)];
    a.Properties.VariableNames = {'name','classes','macroAVG','microAVG','weightAVG'};
    for l = 1:length(classificatori)
        classificatore = classificatori{l,1};
        b = table({classificatori{l,2}},[0,0],0,0,0);
        b.Properties.VariableNames = {'name','classes','macroAVG','microAVG','weightAVG'};
        stats = [stats;[a;b]];
        [microkNN, macrokNN, wkNN, stats1, fscore, model_classificatore] = calculuatestats(feature,featureTest,classificatore,YTrain,YTest);
        stats = [stats;stats1];
        if fscore > theshold_affidabilita_fscore
            if thirdlayer == 1
                audsThird = augmentedImageDatastore(size, imdsThirdLayer,'ColorPreprocessing', 'gray2rgb');
                featuresThird = activations(model, audsThird, layer, 'MiniBatchSize', 64);
                featuresThird = squeeze(featuresThird); 
                featuresThird = featuresThird';
                if (thirdLayerFilter(model_classificatore,featuresThird,YThird) == 1)
                    classificatori_affidabili{numel(classificatori_affidabili) + 1} = {name,classificatori{l,2},fscore,model_classificatore,size,model,layer};
                end
            else
                classificatori_affidabili{numel(classificatori_affidabili) + 1} = {name,classificatori{l,2},fscore,model_classificatore,size,model,layer};
            end
        end
    end
end

a = table({"end" + name},[0,0],0,0,0);
a.Properties.VariableNames = {'name','classes','macroAVG','microAVG','weightAVG'};
stats = [stats;a];
try
    if Report == "1"
        %sendreport(stats,reportfile,pythonpath,setkey);
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
function [ret] = thirdLayerFilter(model,datastore,Labels)
    predictions = predict(model,datastore);
    negative_max_error = 40;
    positive_max_error = 5;
    for i=1:length(Labels)
        prediction = predictions(i);
        if (prediction ~= Labels(i))
            if prediction == "Negative" && Labels(i) == "Positive"
                positive_max_error = positive_max_error - 1;
                 if positive_max_error == 0
                    ret = 0;
                    return
                 end
            else
                negative_max_error = negative_max_error - 1;
                if negative_max_error == 0
                    ret = 0;
                    return
                end
            end
        end
    end
    ret = 1;
end