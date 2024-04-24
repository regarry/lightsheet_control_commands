function [bigImage] = StitchTheImages(images, horzTilesNum, vertTilesNum)
    
    %Create the big image
    bigImage = zeros(size(images,1)*vertTilesNum, size(images,2)*horzTilesNum);
    for ii = 1:size(images,3)
        indexV = mod(ii - 1,vertTilesNum);
        indexH = floor((ii-1)/(vertTilesNum));
        %Odd to compensate for the snake pattern
        if (mod(indexH,2) == 0)
            indexV = vertTilesNum - indexV - 1;
        end
        indexH = horzTilesNum - indexH - 1;
        startVVec = indexV*size(images,1) + 1;
        endVVec = (indexV+1)*size(images,1);
        vVec = startVVec:endVVec;
        startHVec = indexH*size(images,2) + 1;
        endHVec = (indexH+1)*size(images,2);
        hVec = startHVec:endHVec;
        bigImage(vVec, hVec) =  images(:,:,ii);
    end
    
end