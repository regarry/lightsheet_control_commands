%% create the simulation image
verticalTileNumber = 8;
horizontalTileNumber = 6;
sizeOfImageH = 512;
sizeOfImageV = 512;
simulatedImage = randn(verticalTileNumber,horizontalTileNumber);
simulatedImage = imresize(simulatedImage, [sizeOfImageV sizeOfImageH], 'nearest');
%% Display and pick
sizeOfSquareInPixelsV = round(sizeOfImageV/verticalTileNumber);
sizeOfSquareInPixelsH = round(sizeOfImageH/horizontalTileNumber); 
[imageWithBorders] = DisplayTheImageWithBorderLines(simulatedImage, sizeOfSquareInPixelsV, sizeOfSquareInPixelsH, verticalTileNumber, horizontalTileNumber);
h = figure; imshow(imageWithBorders);
%PickThePoints
[hPixels, vPixels] = getpts(h);

%% Correlate the picked pixels to tiles
[selectedTiles] = WhichTilesWherePicked(hPixels,vPixels, sizeOfSquareInPixelsV, sizeOfSquareInPixelsH);
DisplayTheImageWithSelectedTiles(imageWithBorders, selectedTiles, sizeOfSquareInPixelsV, sizeOfSquareInPixelsH);