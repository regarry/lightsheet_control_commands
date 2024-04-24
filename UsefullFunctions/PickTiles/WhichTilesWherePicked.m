
function [selectedTiles] = WhichTilesWherePicked(hPixels,vPixels, sizeOfSquareInPixelsV, sizeOfSquareInPixelsH)
    selectedTiles = zeros(numel(vPixels),2);
    for ii = 1:numel(hPixels)
        selectedTiles(ii,2) = floor(hPixels(ii)/sizeOfSquareInPixelsH) + 1;
        selectedTiles(ii,1) = floor(vPixels(ii)/sizeOfSquareInPixelsV) + 1;      
    end  
end