% procedura utilizzata per trovare gli index comuni nei vettori di features in
% ../features indexes/filtro
% il file senza il nome del set era l'output ottenuto,
% il file "NoneFILTRO" invece è ottenuto facendo l'estrazione dal merge di tutti i set
function [shared_features] = found_features(matrix)
    
    column = matrix(:,1);
    shared_features = []
    for i=1:length(column)
        to_check = column(i,1);
        cond = 1;
        for j=2:size(matrix,2)
            if(sum(to_check == matrix(:,j)) == 0)
               cond = 0;
            end
        end
        if(cond == 1)
            shared_features = [shared_features;to_check]
        end
    end
end