% controllare shuffle_getkfoldsets per più info
function [kfoldsets] = getkfoldsets(imds,mode)
    
    %quà divido in folds, da rivedere (non so come passarli dinamicamente dato che non accetta tuple) 
    if(mode == 5)
        allimgds = cell (1,5);
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
            if(i ~= j)
                filetmp = allimgds(j);
                filetmp = filetmp{1,1};
                for y = 1:length(filetmp.Files)
                    files(end + 1)  = filetmp.Files(y);
    
                end
            end
        end
        [~,idx] = sort(lower(files));
        othermergesets = imageDatastore(files(idx),'IncludeSubfolders',true,'LabelSource','foldernames');
        kfoldsets{end + 1} = {othermergesets, allimgds{i}};
    end
end

