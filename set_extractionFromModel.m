% funzione di generazione dei report escludendo un set e usandolo come testing
% dataset è il numero del dataset da usare in testing
function [classificatori_affidabili] = set_extractionFromModel(Dataset,Datasetype,Report)

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

reportfile = pathstr + 'report'+ setkey + setnum +'.txt';
pythonpath =  pathstr + "report.py";

% datapath contiene il set di test
DataPath = pathstr +'1_Processed\'+ setnum + "\"+ setnum + set;
DataPath2 = pathstr +'1_Processed\Set_20'+ "\Set_20"+ set;




imds = imageDatastore(DataPath,'IncludeSubfolders',true,'LabelSource','foldernames');
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

imdsTest = imds; % set 20 di default per training
imdsTV = imageDatastore(DataPath2,'IncludeSubfolders',true,'LabelSource','foldernames');

% label sono negativi o positivi
YTrain = imdsTV.Labels; % Label di classe per lo split di training
YTest = imdsTest.Labels; % Label di classe per lo split di test 

% inizializzazione tabella con tutte le statistiche
stats = table((length(classificatori)),[(length(models)),0],0,0,0);
stats.Properties.VariableNames = {'name','classes','macroAVG','microAVG','weightAVG'};
classificatori_affidabili = {};
theshold_affidabilita_fscore = 0.98;

for i = 1:length(models)
    % estrazione del descrittore per l'iterazione
    model = models{i,1};
    % estrazione dimensione ideale del descrittore
    size = model.Layers(1).InputSize(1:3);
    % applicazione dimensione ideale come augmdatastore,
    % i parametri dopo consentono di convertire le immagini ad un canale a immagini a 3 canali(necessari per le reti convoluzionali)
    % solo se esse hanno meno canali, altrimenti non fa niente oltre al resize
    audsTV = augmentedImageDatastore(size, imdsTV,'ColorPreprocessing', 'gray2rgb');
    audsTest = augmentedImageDatastore(size, imdsTest,'ColorPreprocessing', 'gray2rgb');
    % estrazione del layer delle features 
    layer = models{i,3};
    % estrazione delle features ti train e tes
    [feature,featureTest] = extractfeatures(model, audsTV ,audsTest,layer);
    % questa parte serve per il parser dopo per sapere il nome del modello da reportare
    name = models{i,2};
    a = [table({"modello : " + name},[0,0],0,0,0);table({"dataset : "+ DataPath},[0,0],0,0,0)];
    a.Properties.VariableNames = {'name','classes','macroAVG','microAVG','weightAVG'};
    % training e testing dei singoli classificatori
    for l = 1:length(classificatori)
        classificatore = classificatori{l,1};
        % questa serve per il report
        b = table({classificatori{l,2}},[0,0],0,0,0);
        b.Properties.VariableNames = {'name','classes','macroAVG','microAVG','weightAVG'};
        % merge delle tabelle dei passi precedenti
        stats = [stats;[a;b]];
        % allenamento classificatore e calcolo della confusion matrix
        [microkNN, macrokNN, wkNN, stats1, fscore, model_classificatore] = calculuatestats(feature,featureTest,classificatore,YTrain,YTest);
        % salvataggio stats per python
        stats = [stats;stats1];
        % serviva per enseble, estraeva i classificatori con uno score alto 
        if fscore > theshold_affidabilita_fscore
            %classificatori_affidabili{numel(classificatori_affidabili) + 1} = {name,classificatori{l,2},fscore,model_classificatore,size,model,layer};
        end
    end
end
% serve per reporting
a = table({"end" + name},[0,0],0,0,0);
a.Properties.VariableNames = {'name','classes','macroAVG','microAVG','weightAVG'};
stats = [stats;a];
try
    if Report == "1"
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