% mode 0 -> quarto maggiore delle features
% mode 1 -> percentile
% mode 2 -> k-best
% qui si estraggono le features utilizzando gli score
% features -> matrice di features in input (per colonna la singola feature)
% value è il sopra percentile o value-best
function [f,removeindex] = filter_mutual(features,indexe,mode,value)
    
    if(mode == 0)
        mean_ = mean(indexe(:,2));
        max_ = max(indexe(:,2));
        ideal = ((mean_+max_)/2 + max_)/2;
    else 
        if (mode == 1)
            ideal = prctile(indexe(:,2),value);
        else
            a = sort(indexe(:,2),1,'descend');
            ideal = a(value);
        end
    end
    % ideal è usato per ottenere lo score di mutual information sopra una soglia
    removeindex = [];
    len = length(indexe(:,1));
    i = 1;
    % rimozione features
    while i < len + 1
        if(indexe(i,2) < ideal)
            % cancellazione features sotto una cera soglia
            indexe(i,:) = [];
            features(:,i) = [];
            i = i - 1;
            len = len - 1;
        end
        i = i + 1;
    end
    % salvataggio features rimaste per rimuovere le altre
    % quando si estraggono dal test set
    % il nome non corrisponde al funzionamento
    % queste sono le features che si salvano
    removeindex = indexe(:,1);
    % features rimaste
    f = features;
end
