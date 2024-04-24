%This function capture a single image using internal trigger and assuming
%overlap mode

function [img] = CaptureImageIntTri(mmc)
       
    %Snap an image and get its properties
    %mmc.getRemainingImageCount
    mmc.snapImage();
    img = mmc.getImage();  % returned as a 1D array of signed integers in row-major order
    %mmc.getRemainingImageCount
    width = mmc.getImageWidth();
    height = mmc.getImageHeight();
    pixelType = 'uint16';
    img = typecast(img, pixelType);      % pixels must be interpreted as unsigned integers
    img = reshape(img, [width, height]); % image should be interpreted as a 2D array
    img = transpose(img);                % make column-major order for MATLAB    '
    img = flipud(img);
       
end

