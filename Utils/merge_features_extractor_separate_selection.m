% non usato, quì si effettua prima selezione features per descittore e poi merge


function [features_container,outindexes,labels] = merge_features_extractor_separate_selection(models,DataPath,mode)
    features_container = [];
    outindexes = [];
    imds = imageDatastore(DataPath,'IncludeSubfolders',true,'LabelSource','foldernames');
    imds = shuffle(imds);
    tmp = [];
    labels = imds.Labels;
    cost = 0;
    for j=1:length(models(:,1))
        tmp1 = [];
        model = models{j,1};
        size = model.Layers(1).InputSize(1:3);
        layer = models{j,3};
        auds = augmentedImageDatastore(size, imds,'ColorPreprocessing', 'gray2rgb');
        features = activations(model, auds, layer, 'MiniBatchSize', 32);
        features = squeeze(features); 
        features = features';
        [features,tmp1] = filter_mutual(features,filter_mutual_inf(features,labels,3),1,98);
        tmp1 = tmp1 + cost;
        tmp = [tmp;tmp1];
        cost = length(features(:,1));
        features_container = [features_container,features];
    end
    if mode == 0
        return
    end
    % codice filtering
    %[features_container,outindexes] = filter_variance_treeshold(features_container,1e-2);

    outindexes = tmp;
    return;
    
    % [features_container,outindexes] = filter_variance_treeshold(features_container,1e-2);
    % i = length(outindexes) + 1;
    % len = i;
    % while i < length(tmp) + 1
    %     outindexes(i,1) = len;
    %     i = i + 1;
    % end
    % outindexes = [tmp,outindexes];
end