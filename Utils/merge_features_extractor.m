% puro merge features

function [features_container,outindexes,labels] = merge_features_extractor(models,DataPath,mode)
    features_container = [];
    outindexes = [];
    imds = imageDatastore(DataPath,'IncludeSubfolders',true,'LabelSource','foldernames');
    imds = shuffle(imds);
    for j=1:length(models(:,1))
        model = models{j,1};
        size = model.Layers(1).InputSize(1:3);
        layer = models{j,3};
        auds = augmentedImageDatastore(size, imds,'ColorPreprocessing', 'gray2rgb');
        features = activations(model, auds, layer, 'MiniBatchSize', 64);
        features = squeeze(features); 
        features = features';

        features_container = [features_container,features];
    end
    if mode == 0
        return
    end
    % codice filtering
    labels = imds.Labels;
    %[features_container,outindexes] = filter_variance_treeshold(features_container,1e-2);
    tmp = [];
    [features_container,tmp] = filter_mutual(features_container,filter_mutual_inf(features_container,labels,3),1,98);


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