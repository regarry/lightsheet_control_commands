function [imageWithBorders] = TileAndMoveToOneOfTheTiles( controlParameters, vertTilesNum, horzTilesNum, stepSizeInLateralScan, downSampleFactor )
        downImage = 0.1;
        %make a big  image
        [ bigImage, xyzScanArray, indCenter ] = TileInOneSection( controlParameters, vertTilesNum, horzTilesNum, stepSizeInLateralScan );
        save bigImage bigImage;
        %Allow the user to pick the relevant tiles
        sizeOfSquareInPixelsV = round(2048/downSampleFactor);
        sizeOfSquareInPixelsH = round(2048/downSampleFactor);
        [imageWithBorders] = DisplayTheImageWithBorderLines(bigImage, sizeOfSquareInPixelsV, sizeOfSquareInPixelsH, vertTilesNum, horzTilesNum, indCenter);
        h = figure; imshow(imresize(imageWithBorders,downImage),[]);
        %PickThePoints
        [hPixels, vPixels] = getpts(h);
        hPixels = hPixels/downImage;
        vPixels = vPixels/downImage;
        [selectedTiles] = WhichTilesWherePicked(hPixels,vPixels, sizeOfSquareInPixelsV, sizeOfSquareInPixelsH);
        
        %Pick only the last tile to be imaged
        selectedTiles = selectedTiles(end, :);
        [selectedTilesVectorAfterSnakePatternRemoval] = TranslateToOriginalTileNumbering(selectedTiles, vertTilesNum, horzTilesNum);
        
        %move the stage to the center of the selected tile
        [xPos, yPos, zPos] = GetXYZPosition(controlParameters.MMC);
        dx = xyzScanArray(1,selectedTilesVectorAfterSnakePatternRemoval) - xPos; dy = xyzScanArray(2,selectedTilesVectorAfterSnakePatternRemoval) - yPos; dz = xyzScanArray(3,selectedTilesVectorAfterSnakePatternRemoval) - zPos;
        [newPosX, newPosY, newPosZ] = SetRelativeXYZPosition(controlParameters.MMC, dx, dy, dz );        


end

