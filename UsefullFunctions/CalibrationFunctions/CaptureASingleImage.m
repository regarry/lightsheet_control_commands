%Set the exposure to 50 ms, capture and display a single image
function [] = CaptureASingleImage(mmc, cameraLabel, expTime)

    %Set the exposure to 50 ms
    mmc.setProperty(cameraLabel,'Exposure', expTime);
    val = mmc.getProperty(cameraLabel,'Exposure');
    display(['Exposure was set to ',char(val),' ms']);
   
    %Snap an image and get its properties
    mmc.snapImage();
    img = mmc.getImage();  % returned as a 1D array of signed integers in row-major order
    width = mmc.getImageWidth();
    height = mmc.getImageHeight();
    pixelType = 'uint16';
    img = typecast(img, pixelType);      % pixels must be interpreted as unsigned integers
    img = reshape(img, [width, height]); % image should be interpreted as a 2D array
    img = transpose(img);                % make column-major order for MATLAB
    
    %Start capturing images and show them until somebody press a key
    figure; imshow(img,[]);
    
end

