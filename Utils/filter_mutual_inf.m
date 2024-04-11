% k di default è 3 su matlab
function features_to_filter = filter_mutual_inf(features,labels,k)
    len = length(labels);
    Y = [];
    features_to_filter = [];
    % creazione label discreto per i casi positivi / negativi
    for i=1:len
          if labels(i) == "Positive"
              Y = [Y;1];
          else 
              Y = [Y;0];
          end
    end
    % calcolo mutual information usato da scikit https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0087357
    % algoritmo ottimizzabile
    % calcolo parte costante della formula della mutual information
    
    first_elem = psi(size(features,1));
    k_elem = psi(k);
    costant_part = first_elem + k_elem;
    % iterazione per tutte le features
    for p=1:size(features,2)
       column = features(:,p);
        % normalizzazione usata da scikit, aggiunge rumore
        column = column./std(column(:,1));
        column = column + 1e-10*max(1,mean(abs(column)))*randn(length(column),1);
        %
        submatrix = [column,Y];
        submatrix = sortrows(submatrix,2);
        % sorting in base ai label in modo da avere le features ordinate per label
        % ottenimento variabili discrete nel dataset
        values = unique(submatrix(:,2));
        
        final_vector = [];
            for i=1:length(values)
                % estrazione features con un unico label,
                % questo serve per trovare i knn più vicini nella stessa classe
                sub_matrix_value = submatrix(submatrix(:,2) == values(i) ,1);
                % questa parte potrebbe avere unexpected behavior per k < dei campioni del dataset
                if(k > size(submatrix,1))
                    error("insieme di ricerca troppo piccolo rispetto a k");
                end
                % attacco vettore di features con il label
                sub_matrix_value = [sub_matrix_value,ones(length(sub_matrix_value),1) .* values(i)];
                % ottenimento dei knn e estrazione del neighbor più lontano
                % il k + 1 serve perchè nella ricerca di tutti reinclude il punto stesso.
                % uso distanza euclidea per farlo(default scikit), modificabile
                distantest_points = knnsearch(sub_matrix_value,sub_matrix_value,'K',k+1,'Distance','euclidean');
                distantest_points = [distantest_points(:,1),distantest_points(distantest_points(:,end))];
                distances_vector = [];
                % calcolo distanza tra il punto j e il neighbour più lontano
                % uso distanza eucludea di defoult in scikit per farlo(norma 2) modificabile per altre distanze 
                for j=1:size(sub_matrix_value,1)
                    distances_vector(j,:) = [j,norm(sub_matrix_value(j,:) - sub_matrix_value(distantest_points(j,2),:),2)];
                end
                % vettore finale di distanze che serve per la seconda parte dell'algoritmo
                % l'ultimo elemento conta i campioni di un label(li sto copiando per effettuare operazioni vettoriali)
                final_vector = [final_vector;sub_matrix_value(:,1),sub_matrix_value(:,2),distances_vector(:,2),ones(size(sub_matrix_value,1),1) .* sum(sub_matrix_value(:,2) == values(i),'all')];
            end
        % calcolo Nx nella formula è la media delle psi del numero di campioni per classe
        % l'algoritmo richiede di calcolarla considerando per ogni campione dell dataset il numero dei label della classe
        % ex c1 -> classe 1
        %    c2 -> classe 1
        %    2 campioni per la classe 1
        %    c3 -> classe 2
        % la media è psi(2)*psi(2)*psi(1)/3
        Nx = mean(psi(final_vector(:,4)));
        num_of_elem = [];
        len =  size(final_vector,1);
        % questa parte dell'algoritmo invece richiede di calcolare il numero di neighbor considerando tutte le classi
        % ma basandoci sulla distanza ottenuta in precedenza
        for i=1:len
            distance = final_vector(i,3);
            iter_vector = [final_vector(i,1)];%,final_vector(i,2)];
            count = 0;
            % semplice calcolo della norma due per vedere se due campioni hanno una distanza 
            % minore rispetto a quella considerata in precedenza, in modo da poterli contare
            for j=1: len
                if(i ~= j)
                    secondvector = [final_vector(j,1)];%,final_vector(j,2)];
                    norm_calc = norm(iter_vector - secondvector,2);
                    if(norm_calc <= distance)
                        count = count + 1;
                    end
                end
            end
            num_of_elem(end + 1) = count;
        end
        % stessa cosa fatta prima con Nx
        mi = mean(psi(num_of_elem));
        % score finale mutual information
        Mutual_C = costant_part - Nx - mi;
        % impostazione dei valori possibili per la mutual information
        if Mutual_C == inf || Mutual_C == -inf || Mutual_C < 0
            Mutual_C = 0;
        end
        % impostazione dello score per feature (verra utilizzato fuori per estrarre i migliori score)
        features_to_filter(end+1,:) = [p,Mutual_C]; 
    end

end