% identica a merge_features_extractor_index, solo con lo shuffle
function [features_container,labels] = merge_features_extractor_index_shuffle(models,DataPath,indexes)
    features_container = [];
    outindexes = [];
    imds = imageDatastore(DataPath,'IncludeSubfolders',true,'LabelSource','foldernames');
    imds = shuffle(imds);
    labels = imds.Labels;
    for j=1:length(models(:,1))
        model = models{j,1};
        size_ = model.Layers(1).InputSize(1:3);
        layer = models{j,3};
        auds = augmentedImageDatastore(size_, imds,'ColorPreprocessing', 'gray2rgb');
        features = activations(model, auds, layer, 'MiniBatchSize', 64);
        features = squeeze(features); 
        features = features';
        features_container = [features_container,features];
    end
    features_container(:,setdiff([1:size(features_container,2)],indexes(:,1))) = [];
end
