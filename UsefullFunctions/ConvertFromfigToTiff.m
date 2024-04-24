% to retrieve the handle to current figure
fig_h = get(gca,'children');

% to find the handle of the image
handleToImage2 = findobj(fig_h, 'Type', 'Image');

% reading the matrix data
Es=get(handleToImage2,'CData' );

% retrieve the axis data
x=get(handleToImage2,'xData' );
y=get(handleToImage2,'yData' );

nameOfFile = '640_3.tiff';
imwrite(Es, nameOfFile);