function [microAVG, macroAVG, wAVG, stats, fscore, model_classificatore] = calculuatestats(features,featuresTest,classificatore,Labels,Labels_Test)
    

% allenamento classificatore, la variabile classificatore è in realtà una funzione
model_classificatore = classificatore(features, Labels);
% test sui dati di test
prediction_classificatore = predict(model_classificatore, featuresTest);
% calcolo confusion matrix
confusion_matrix = confusionmat(string(Labels_Test), string(prediction_classificatore));


% Estrazione delle statistiche di interesse delle confusion matrix.
% Il file computeMetrics restituisce le metriche di interesse (già inserite
% a mano all'interno del codice) con 3 diverse medie: micro, macro,
% weighted, e una tabella complessiva di riepilogo con i dettagli di tutte
% le classi e generali.

% statistiche accuratezza estratte dal classifcatore
[microAVG, macroAVG, wAVG, stats] = computeMetrics(confusion_matrix);
avgtype = 3 ;%3 -> macroavg, 4 -> mircoavg, 5 -> weightedavg;
% estrazione fscore di interesse, usato solo per costruire l'enseble
fscore = stats{20,avgtype};
end