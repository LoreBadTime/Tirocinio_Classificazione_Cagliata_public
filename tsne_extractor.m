hold all
base = mfilename("fullpath");
[pathstr,~,~] = fileparts( base );
pathstr = pathstr+"\";
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
usedset =  "LocEntropy";
setnums = ["4","5","6","9","10","11","12","13","14","15"];
chosenset = "_" + usedset;
colors = [];
for k=1:length(setnums)
    colors = [colors;rand(1,3)];
end
load colors.mat

for j=1:length(models)
    model = models{j,1};
    size = model.Layers(1).InputSize(1:3);
    layer = models{j,3};
    tsne_model_container = [];
    tsne_label_container = [];
    for i = 1:length(setnums)
        setnum =  "Set_" + setnums(i);
        DataPath = pathstr + '1_Processed\'+ setnum + "\"+ setnum + chosenset;
        imds = imageDatastore(DataPath,'IncludeSubfolders',true,'LabelSource','foldernames');
        auds = augmentedImageDatastore(size, imds,'ColorPreprocessing', 'gray2rgb');
        features = activations(model, auds, layer, 'MiniBatchSize', 512);
        features = squeeze(features); 
        features = features';
        tsne_model_container = [tsne_model_container;features];
        tsne_label_container = [tsne_label_container;repmat("Set"+setnums(i)+usedset,[1 length(imds.Files)])'];
    end
    f = figure;
    %f.WindowState = 'maximized';
    set(gca,'colororder',parula(32));
    Y = tsne(tsne_model_container);
    plotted = gscatter(Y(:,1),Y(:,2),tsne_label_container);
    modelname = models{j,2}+"-"+usedset;
    for k = 1:numel(plotted)
        set(plotted(k),'Color',colors(k,:))
    end
    title(modelname);
    legend('Location','southeastoutside');
    saveas(f, modelname, 'png');
    close(f);

end