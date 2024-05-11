
function [classificatori_affidabili] = set_fselectionmerged_shuffle_extractionFromModel(Dataset,Datasetype,Report)

% Caricamento del dataset di interesse, suddiviso in sottocartelle (ogni
% sottocartella è una classe del dataset).
% (path,foldermode,settingmode,labelimmagini,labelsettings)


setkey = "_" + Datasetype;
set = setkey + "\";
setnum = "Set_" + Dataset;
base = mfilename("fullpath");
[pathstr,~,~] = fileparts( base );
pathstr = pathstr+"\";
addpath(pathstr + "Utils\");
addpath(pathstr + "OtherUtils\");

if Report == "1"
    reportfile = pathstr + 'report'+ setkey + "_feature_selection_static_"+setnum +'.txt';
else
    reportfile = pathstr + 'report'+ setkey + "_feature_selection_dynamic_"+setnum +'.txt';
end

pythonpath =  pathstr + "report.py";

DataPathTest = pathstr + '1_Processed\'+ setnum + "\"+ setnum + set;
DataPathTrain = pathstr + '1_Processed\Set_20'+ "\Set_20"+ set;
addpath(pathstr + "feature indexes\Enhanced\")
addpath(pathstr + "feature indexes\LocEntropy\")
addpath(pathstr + "feature indexes\LocStD\")
addpath(pathstr + "feature indexes\Original\")




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
models_container = [];

load Enhanced_feat;
load LocEntropy_feat.mat;
load LocStd_feat;
load Original_feat;

switch (Datasetype)
    case "LocEntropy"
        
        models= {
        resnet50,"resnet50",'avg_pool'; ...
        resnet18,"resnet18",'pool5'; ...
        xception,"xception",'avg_pool'; ...
        darknet19,"darknet19",'avg1';
        };
        indexes = LocEntropy;
    case "LocStD"
        models = {
        
        densenet201,"densenet201",'avg_pool'; ...
        resnet101,"resnet101",'pool5'; ...
        %xception,"xception",'avg_pool'; ...
        %nasnetlarge,"nasnetlarge",'global_average_pooling2d_2'; ...
        vgg19,"vgg19",'fc6'};
        indexes = LocStD;
    case "Enhanced"
        models = {
        resnet50,"resnet50",'avg_pool'; ...
        darknet53,"darknet53",'avg1'; ... 
        shufflenet,"shufflenet",'node_200'; ...
        };
        indexes = Enhanced;
    case "Original"
        models = {
        inceptionv3,"inceptionv3",'avg_pool'; ...
        xception,"xception",'avg_pool'; ...
        inceptionresnetv2,"inceptionresnetv2",'avg_pool';
        };
        % original è stato esportato come a in origine
        indexes = a;
end
%non sono riuscito a trovare squeezenet
classificatori = {
    @fitcknn,"k nearest n"; ...
    @normfitcnet,"neural net"; ...
    @fitctree, "decision tree"; ...
    @fitcsvm, "SVM lineare"; ...
    @customtreebagger, "Random Forest"; ...
    @customfitcdiscr, "discriminante lineare"
};



stats = table((length(classificatori)),[(length(models)),0],0,0,0);
stats.Properties.VariableNames = {'name','classes','macroAVG','microAVG','weightAVG'};
classificatori_affidabili = {};
theshold_affidabilita_fscore = 0.98;

if Report == "1"
%feature selection statica
    [feature,YTrain] = merge_features_extractor_index_shuffle(models,DataPathTrain,indexes);
else
%feature selection dinamica, FA ANCHE LO SHUFFLE
    [feature,indexes,YTrain] = merge_features_extractor(models,DataPathTrain,1);
%save(setnum+Datasetype,"indexes");
%return;
end
% Nel dataset in testing non fa lo shuffle
[featureTest,YTest] = merge_features_extractor_index(models,DataPathTest,indexes);

a = [table({""},[0,0],0,0,0);table({"dataset : "+ DataPathTest},[0,0],0,0,0)];
a.Properties.VariableNames = {'name','classes','macroAVG','microAVG','weightAVG'};
for l = 1:length(classificatori)
        classificatore = classificatori{l,1};
        b = table({classificatori{l,2}},[0,0],0,0,0);
        b.Properties.VariableNames = {'name','classes','macroAVG','microAVG','weightAVG'};
        stats = [stats;[a;b]];
        [microkNN, macrokNN, wkNN, stats1, fscore, model_classificatore] = calculuatestats(feature,featureTest,classificatore,YTrain,YTest);
        stats = [stats;stats1];
        if fscore > theshold_affidabilita_fscore
            %classificatori_affidabili{numel(classificatori_affidabili) + 1} = {name,classificatori{l,2},fscore,model_classificatore,size,model,layer};
        end
end
stats

a = table({"end"},[0,0],0,0,0);
a.Properties.VariableNames = {'name','classes','macroAVG','microAVG','weightAVG'};
stats = [stats;a];
try
    if Report == "1" || Report == "2"
        sendreport(stats,reportfile,pythonpath,setkey);
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