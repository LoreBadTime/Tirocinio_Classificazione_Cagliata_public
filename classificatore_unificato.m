% script di test dell'enseble


function [no_res] = classificatore_unificato(TrainingSet,SecondLayerSet,ThirdLayerSet,testingset,useThirdLayer)

%TrainingSet = "21"
%ThirdLayerSet = "21"
%SecondLayerSet = "23"
%testingset = "6"

%useThirdLayer = 0

% int() python equivalent required
if useThirdLayer == "1"
    useThirdLayer = 1;
else 
    useThirdLayer = 0;
end

base = mfilename("fullpath");
[pathstr,~,~] = fileparts( base );
pathstr = pathstr+"\";




sets = {
    "_Enhanced";
    "_Original";"_LocStD";"_LocEntropy";};
set_predictors = {
   extractionFromModel_test(TrainingSet,SecondLayerSet,"Enhanced",'0',ThirdLayerSet,useThirdLayer);
   extractionFromModel_test(TrainingSet,SecondLayerSet,"Original",'0',ThirdLayerSet,useThirdLayer);
   extractionFromModel_test(TrainingSet,SecondLayerSet,"LocStD",'0',ThirdLayerSet,useThirdLayer);
   extractionFromModel_test(TrainingSet,SecondLayerSet,"LocEntropy",'0',ThirdLayerSet,useThirdLayer); 
};

TestPath = pathstr +  "1_Processed"+ "\Set_"+testingset+"\"+"Set_"+ testingset;
tmp = imageDatastore(TestPath+sets{1},'IncludeSubfolders',true,'LabelSource','foldernames');
testimagesnum = length(tmp.Labels);
numerrors = 0;
result = 0;
plotter = {}
limit = 0
% ciclo per ogni immagine(in modo da analizzarle)
for l = 1:testimagesnum
    Train = 0;
    % questo valore deciderà cagliata/non cagliata 
    sum = 0;
    

    % ciclo per i classificatori affidabili per un filtro immagine(Enhanced...)
    for k = 1:length(set_predictors)
        set_predictor = set_predictors{k};
        set = sets{k};
        % ottenimento imds del filtro immagine
        enhanched_ds = imageDatastore(TestPath+set,'IncludeSubfolders',true,'LabelSource','foldernames');
        Train = enhanched_ds.Labels;
        display(enhanched_ds.Files{l});
        for i = 1:length(set_predictor)
                % in set predictor sono salvati tutti i dati per effettuare l'estrazione 
                % di features nello stesso modo usato per l'allenamento
                edited_ds = augmentedImageDatastore(set_predictor{i}{5}, readimage(enhanched_ds,l),'ColorPreprocessing', 'gray2rgb');
                features = activations(set_predictor{i}{6}, edited_ds, set_predictor{i}{7}, 'MiniBatchSize', 256);
                features = squeeze(features); 
                features = features';
                % il classificatore preallenato con il correispondente descrittore
                % classifica le features dell'immagine
                if predict(set_predictor{i}{4},features) == "Negative"
                    % somma non più pesata fuori dal set
                    % dentro il set è meglio effettuare la somma pesata
                    sum = sum - 1;%set_predictor{i}{3};
                else 
                    sum = sum + 1;%set_predictor{i}{3};
                end
        end
    end
    % utile per vedere il plot dopo delle previsioni
    plotter{numel(plotter) + 1} = sum;
    % semplice funzione segno per controllare la votazione
    if sum > 0
        result = "Positive";
    else
        result = "Negative";
    end
    % controllo se robe sono corrette
    if contains(enhanched_ds.Files{l},"Positive") && limit == 0
        limit = l
    end
    if contains(enhanched_ds.Files{l},result)
        display("success " + result);
    else 
        display("failure " + result);    
        display(enhanched_ds.Files{l});
        numerrors = numerrors + 1;

    end
end
% plotting e risultati
display("numero errori = " + numerrors)
plotpoints = [];
for s = 1:length(plotter)
        plotpoints = [plotpoints,plotter{s}];
end
plot(plotpoints','b-', 'LineWidth', 2); 
grid on;
xlabel('immagine');
ylabel('somma ensemble(non-cagliata, cagliata)');
% Place black lines along axes:
xline(limit, 'Color', 'k', 'LineWidth', 2); % Draw line for Y axis.
yline(0, 'Color', 'k', 'LineWidth', 2); % Draw line for X axis.)
ax = gca;
exportgraphics(ax,"./results/ensemble_in_set " + testingset + "export.jpg")
end