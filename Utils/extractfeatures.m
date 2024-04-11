% input descrittore(alexnet, resnet ecc),
% imgdatastore in training e in test, il layer di estrazione dalla rete convoluzionale
% output le features di train e features di test
function [features,featuresTest] = extractfeatures(model, trainDs,testDs,layer)
    features = activations(model, trainDs, layer, 'MiniBatchSize', 32);
% output -> matrice multidimensionale (contiene numero campioni e altre variabili che che indicizzano le features)

% per ridurre il tutto a una NxM, con M = numero features:
    features = squeeze(features); 
%featuresAlexTV = reshape(featuresAlexTV, [size(featuresAlexTV,4), size(featuresAlexTV,3)*size(featuresAlexTV,2)*size(featuresAlexTV,1)]);
    features = features';

% Ripetizione dei passi precedenti per lo split di test
    featuresTest = activations(model, testDs, layer, 'MiniBatchSize', 32);
    featuresTest = squeeze(featuresTest);
    featuresTest = featuresTest';
end