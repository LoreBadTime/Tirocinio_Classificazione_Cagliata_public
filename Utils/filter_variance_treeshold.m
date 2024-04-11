function [f,removeindex]  = filter_variance_treeshold(features,treeshold)
    varvector = var(features);
    removeindex = [];
    len = length(varvector);
    i = 1;
    j = 1;
    K = 0;
    while i < len + 1
        if(varvector(i) < treeshold)
            varvector(i) = [];
            features(:,i) = [];
            removeindex(j,1) = 1;
            i = i - 1;
            len = len -1;
        else
            removeindex(j,1) = 0;
        end

        i = i + 1;
        j = j + 1;
    end
    f = features;
end