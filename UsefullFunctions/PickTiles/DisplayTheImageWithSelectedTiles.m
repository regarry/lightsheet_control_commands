function DisplayTheImageWithSelectedTiles(imageWithBorders, selectedTiles, sizeOfSquareInPixelsV, sizeOfSquareInPixelsH)
    displayImage = zeros(size(imageWithBorders));
    for ii = 1:size(selectedTiles,1)
        firstV = (selectedTiles(ii,1) - 1)*sizeOfSquareInPixelsV + 1;
        lastV = firstV + sizeOfSquareInPixelsV - 1;
        vectorV = (firstV:lastV);
        firstH = (selectedTiles(ii,2) - 1)*sizeOfSquareInPixelsH + 1;
        lastH = firstH + sizeOfSquareInPixelsH - 1;
        vectorH = (firstH:lastH);
        displayImage(vectorV, vectorH,:) = imageWithBorders(vectorV, vectorH,:);
    end
    figure; imshow(displayImage,[]);
end