% algoritmo di k-folding
function [kfoldsets] = getkfoldsets(imds,mode)
    % non sapevo come impostare la spliteach label dinamicamente,
    % testato solo su 5 folds
    % divisione in folds
    if(mode == 5)
        allimgds = cell (1,5);
        % l'idea era di creare un array, ma non viene accettato come secondo parametro
        [allimgds{:}] = splitEachLabel(imds,0.2,0.2,0.2,0.2,0.2);
    else
        allimgds = cell (1,10);
        [allimgds{:}] = splitEachLabel(imds,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1);
    end
    kfoldsets = {};
    %display(allimgds);
    for i = 1:length(allimgds)
        files = {};
        for j = 1:length(allimgds)
            % merge dei fold escludendone il k
            if(i ~= j)
                filetmp = allimgds(j);
                filetmp = filetmp{1,1};
                for y = 1:length(filetmp.Files)
                    files(end + 1)  = filetmp.Files(y);
    
                end
            end
        end
        files = files';
        % image datastore prende in input un insieme di files
        othermergesets = imageDatastore(files,'IncludeSubfolders',true,'LabelSource','foldernames');
        % in prima posizione il training, in seconda il fold dell'iterazionw
        kfoldsets{end + 1} = {othermergesets, allimgds{i}};

    end
    % algoritmo non efficiente dato che crea 
    % k folds diversi in memoria staticamente
    
end

