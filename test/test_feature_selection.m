% script utilizzato per testare la feature selection

Dataset = "4";
Datasetype = "Enhanced";
setkey = "_" + Datasetype;
set = setkey + "\";
setnum = "Set_" + Dataset;
base = mfilename("fullpath");
[pathstr,~,~] = fileparts( base );
pathstr = erase(pathstr, 'test');
pathstr = pathstr+"\";
addpath(pathstr + "Utils\");
addpath(pathstr + "OtherUtils\");

basePath = pathstr + '\1_Processed\';

DataPath = basePath+ setnum + "\"+ setnum + set;


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

%overrwrite modelli solo per testare l'extraction su uno, rimuovere per testare su tutti.
models = {alexnet,"alexnet",'fc6'};

features_container = [];

outindexes = [];
imds = imageDatastore(DataPath,'IncludeSubfolders',true,'LabelSource','foldernames');
imds = shuffle(imds);
%estrazione features da descrittori
for j=1:length(models(:,1))
    model = models{j,1};
    size = model.Layers(1).InputSize(1:3);
    layer = models{j,3};
    auds = augmentedImageDatastore(size, imds,'ColorPreprocessing', 'gray2rgb');
    features = activations(model, auds, layer, 'MiniBatchSize', 32);
    features = squeeze(features); 
    features = features';
    features_container = [features_container,features];
end
%% per testare in scikit usare questa conversione per trasfromare il dato in numero
Y = [];
labels = imds.Labels;
for i=1:length(labels)
      if labels(i) == "Positive"
          Y = [Y;1];
      else 
          Y = [Y;0];
      end
end
% salvataggio per scikit
save("b","Y")
save("a","features")
%%
% codice filtering
labels = imds.Labels;
% estrazione da variance treshold prima di mutual information
%[features_container,outindexes] = filter_variance_treeshold(features_container,1e-2);
tmp = [];

%% var contiene la mutual information per feature
% il terzo valore è il k del k nearest neighbor di scikit
var = filter_mutual_inf(features_container,labels,3);
format long;
var

%vero filtraggio utilizzando la mutual info ricavata in precedenza
[features_container,tmp] = filter_mutual(features_container,var,1,99.9);
%%

