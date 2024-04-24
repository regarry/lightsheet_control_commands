images_file = dir('*.tiff');
len = length(images_file);
empty=0;
notempty = 0;
image_vector = []
for i=1:20
    i
    file = dir(images_file(i).name);
    img = imread(images_file(i).name);
    var(single(img(:)))
    if var(single(img(:))) > 34
        notempty = notempty + 1;
        image_vector = [image_vector 1];
    else
        empty = empty + 1;
        image_vector = [image_vector 0];
    end
end


img = imread('0.0149.tiff');
img2 = imgaussfilt(img);
Sx = fspecial('sobel');
Gx = imfilter(double(img2),Sx,'replicate','conv');
Gy = imfilter(double(img2),Sx,'replicate','conv');
G = Gx.^2 + Gy.^2;
FM = std2(G)^2

% -0.01 6.5505e+11
% -0.014 1.3278e+12
% -0.019 2.3171e+12
% 0.049 4.5516e+10
% 0.099 1.7271e+09
% 0.0149 3.3217e+08















