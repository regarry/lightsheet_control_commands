function [selectedTilesVectorAfterSnakePatternRemoval] = TranslateToOriginalTileNumbering(selectedTiles, vertTilesNum, horzTilesNum)
    
    %Go back to the actual acquisation sequence, starts from bottom right
    %corner, goes up turns left and down and so on in a snake pattern
    for ii = 1:size(selectedTiles,1)
            selectedTiles(ii,2) = horzTilesNum - selectedTiles(ii,2) + 1;                   
    end

    for ii = 1:size(selectedTiles,1)
        
        if (mod(selectedTiles(ii,2),2) == 1)
                selectedTiles(ii,1) = vertTilesNum - selectedTiles(ii,1) + 1;       
        end
    end
                   
    selectedTilesVectorAfterSnakePatternRemoval = zeros(1,size(selectedTiles,1)); 
    
    %From matrix indices move to vector indices
    
    for ii = 1:size(selectedTiles,1)
        selectedTilesVectorAfterSnakePatternRemoval(ii) =  (selectedTiles(ii,2) - 1)*vertTilesNum + selectedTiles(ii,1);
    end
    
    %Sort them according to the order    
    selectedTilesVectorAfterSnakePatternRemoval = sort(selectedTilesVectorAfterSnakePatternRemoval);
    
    %Get ride of duplicates
    selectedTilesVectorAfterSnakePatternRemoval = unique(selectedTilesVectorAfterSnakePatternRemoval);
    
end