% models -> descrittori scelti per estrazione features
% datapath -> path dove sono contenute le classi
% indexes -> index di features da non eliminare
% ATTENZIONE gli index devono essere prelevati dagli stessi descrittori altrimenti 
% ci si riferisce a features diverse
function [features_container,labels] = merge_features_extractor_index(models,DataPath,indexes)
    features_container = [];
    outindexes = [];
    imds = imageDatastore(DataPath,'IncludeSubfolders',true,'LabelSource','foldernames');
    labels = imds.Labels;
    % ciclo di merge features
    for j=1:length(models(:,1))
        model = models{j,1};
        size_ = model.Layers(1).InputSize(1:3);
        layer = models{j,3};
        auds = augmentedImageDatastore(size_, imds,'ColorPreprocessing', 'gray2rgb');
        features = activations(model, auds, layer, 'MiniBatchSize', 64);
        features = squeeze(features); 
        features = features';
        % merge di features
        features_container = [features_container,features];
    end
    % cancello gli elementi che sono nel primo vettore, ma non nel secondo
    % quindi cancello gli elementi che non sono in indexes
    features_container(:,setdiff([1:size(features_container,2)],indexes(:,1))) = [];
end
