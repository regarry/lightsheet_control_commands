function [imageWithBorders] = DisplayTheImageWithBorderLines(simulatedImage, sizeOfSquareInPixelsV, sizeOfSquareInPixelsH, verticalTileNumber, horizontalTileNumber, indCenter)
    %h = figure; imshow(simulatedImage); hold on;
    if (numel(simulatedImage) > 419430400)
        lineWidth = 30;
    else
        lineWidth = 50;        
    end
    
    color = max(simulatedImage(:));
    imageWithBorders = simulatedImage;
        
    for ii = 1:(horizontalTileNumber - 1)
        vect = (sizeOfSquareInPixelsH*ii) + (-floor(lineWidth/2):ceil(lineWidth/2));
        imageWithBorders(:, vect) = color;
        
    end
    
    for ii = 1:(verticalTileNumber - 1)
        vect = (sizeOfSquareInPixelsV*ii) + (-floor(lineWidth/2):ceil(lineWidth/2));
        imageWithBorders(vect, :) = color;      
    end
    
    % Color the middle tile
    if ((mod((verticalTileNumber),2) == 0) && (mod((horizontalTileNumber),2) == 0) )
        vect = (sizeOfSquareInPixelsH*horizontalTileNumber/2) + (-floor(lineWidth/2):ceil(lineWidth/2));
        hvect = (((verticalTileNumber/2 - 1)*sizeOfSquareInPixelsV)+1):((verticalTileNumber/2)*sizeOfSquareInPixelsV);
        imageWithBorders(hvect,vect) = 0;    
        imageWithBorders(vect,hvect) = 0;       
    end
    if ((mod((verticalTileNumber),2) == 1) && (mod((horizontalTileNumber),2) == 0) )
        vect = (sizeOfSquareInPixelsH*horizontalTileNumber/2) + (-floor(lineWidth/2):ceil(lineWidth/2));
        hvect = (((verticalTileNumber/2 - 0.5)*sizeOfSquareInPixelsV)+1):((verticalTileNumber/2 + 0.5)*sizeOfSquareInPixelsV);
        imageWithBorders(hvect,vect) = 0;    
        vect = (sizeOfSquareInPixelsV*(verticalTileNumber/2 + 0.5)) + (-floor(lineWidth/2):ceil(lineWidth/2));
        hvect = (((horizontalTileNumber/2 - 1)*sizeOfSquareInPixelsH)+1):((horizontalTileNumber/2)*sizeOfSquareInPixelsH);
        imageWithBorders(vect,hvect) = 0;       
    end
      if ((mod((verticalTileNumber),2) == 0) && (mod((horizontalTileNumber),2) == 1) )
        vect = (sizeOfSquareInPixelsH*(horizontalTileNumber/2 + 0.5)) + (-floor(lineWidth/2):ceil(lineWidth/2));
        hvect = (((verticalTileNumber/2 - 1)*sizeOfSquareInPixelsV)+1):((verticalTileNumber/2)*sizeOfSquareInPixelsV);
        imageWithBorders(hvect,vect) = 0;    
        vect = (sizeOfSquareInPixelsV*(verticalTileNumber/2)) + (-floor(lineWidth/2):ceil(lineWidth/2));
        hvect = (((horizontalTileNumber/2 - 0.5)*sizeOfSquareInPixelsH)+1):((horizontalTileNumber/2 + 0.5)*sizeOfSquareInPixelsH);
        imageWithBorders(vect,hvect) = 0;       
      end
     if ((mod((verticalTileNumber),2) == 1) && (mod((horizontalTileNumber),2) == 1) )
        vect = (sizeOfSquareInPixelsH*(horizontalTileNumber/2 + 0.5)) + (-floor(lineWidth/2):ceil(lineWidth/2));
        hvect = (((verticalTileNumber/2 - 0.5)*sizeOfSquareInPixelsV)+1):((verticalTileNumber/2 + 0.5)*sizeOfSquareInPixelsV);
        imageWithBorders(hvect, vect) = 0;    
        imageWithBorders(vect, hvect) = 0;        
    end
%     if ((mod(numel(verticalTileNumber),2) == 1) && (mod(numel(horizontalTileNumber),2) == 1) )
%         zVec = stepSize*zVec + centerZ;
%         yVec = stepSize*yVec + centerY;
%     end
%     if ((mod(numel(verticalTileNumber),2) == 1) && (mod(numel(horizontalTileNumber),2) == 0) )
%         zVec = stepSize*zVec + centerZ;
%         yVec = stepSize*yVec + centerY; 
%     end
%     if ((mod(numel(verticalTileNumber),2) == 0) && (mod(numel(horizontalTileNumber),2) == 1) )
%         zVec = stepSize*zVec + centerZ; 
%         yVec = stepSize*yVec + centerY;
%     end
    
    %figure; imshow(imageWithBorders);

end