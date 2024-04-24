%-----------------------------------
%-----------------------------------
%Auto focus part, 
%Version 2 added some parameters to improve flexability
%-----------------------------------
%-----------------------------------

function [optAngle] = AutoFocusAngle_V1(image, zDist, pixelSize, waveLength, refractiveIndex, statAngle, initAngle, stepSize, range, convUnits, verticalAng, vPoint, hPoint, radius)

%Parameter definition 
zeroPad = false; %For BP
freqShift = true; %For BP

%Create the sobel edge matrix
hh = fspecial('sobel');
hv=hh';
 
%For the proceses keep only the region of intrest 
processedAreaVectorV = vPoint + (-radius:radius);
processedAreaVectorH = hPoint + (-radius:radius);

 
count = 1;
angleVec = (initAngle-range):stepSize:(initAngle+range);
numOfelementsInAngleVec = numel(angleVec);
varVector = zeros(1, numOfelementsInAngleVec);

%To change to processed FOV to follow the angle
initAngleMedium = asind(sind(initAngle)/refractiveIndex);
initShift = zDist*tand(initAngleMedium);

%For vertical angle
for angleIter = (initAngle - range):stepSize:(initAngle + range)
    fprintf(['angle = ',num2str(angleIter),'\n']);    
    if (verticalAng)
                 
           [propImage] = WavePropAngle_v4(image, waveLength, -zDist, refractiveIndex, pixelSize, pixelSize, angleIter, statAngle, convUnits, zeroPad, freqShift);
           %Make sure that they have the same FOV
           %angleIter
           angleIterMedium = asind(sind(angleIter)/refractiveIndex);
           shiftVertical =  zDist*tand(angleIterMedium);
           shiftInPixels = round((initShift - shiftVertical)/pixelSize);
           processedAreaVectorVmoved = processedAreaVectorV + shiftInPixels;
           imageProces = abs(propImage(processedAreaVectorVmoved, processedAreaVectorH));
           %figure; imshow(imageProces,[]); title(['angle = ',num2str(angleIter)]);
           %Find the edges using the sobel matrix           
           temp2 = abs(imfilter(imageProces,hh));
           temp3 = abs(imfilter(imageProces,hv));
           temp4 = sqrt(temp2.^2 + temp3.^2);
           %Calculate the variance
           varVector(count) = var(temp4(:));
           count = count + 1;
    else
           [propImage] = WavePropAngle_v4(image, waveLength, -zDist, refractiveIndex, pixelSize, pixelSize, statAngle, angleIter, convUnits, zeroPad, freqShift);
           %Make sure that they have the same FOV
           angleIterMedium = asind(sind(angleIter)/refractiveIndex);
           shiftHorizontal =  zDist*tand(angleIterMedium);
           shiftInPixels = round((initShift - shiftHorizontal)/pixelSize);
           processedAreaVectorHmoved = processedAreaVectorH + shiftInPixels;
           imageProces = abs(propImage(processedAreaVectorV, processedAreaVectorHmoved));
           %figure; imshow(imageProces,[]); title(['angle = ',num2str(angleIter)]);
           %Find the edges using the sobel matrix           
           temp2 = abs(imfilter(imageProces,hh));
           temp3 = abs(imfilter(imageProces,hv));
           temp4 = sqrt(temp2.^2 + temp3.^2);
           %Calculate the variance
           varVector(count) = var(temp4(:));
           count = count + 1;
    end
   
end


%[lmaxV lmaxIdx] = lmax(varVector,tempSmooth);
%[lminV lminIdx] = lmin(varVector,tempSmooth);
varVector
maxVal = max(varVector);
ind = (varVector == maxVal);
optAngle = angleVec(ind);
figure; plot(angleVec,varVector); xlabel('Angles Degrees'); ylabel('Focus Measure'); 

end





function [lmval,indd]=lmin(xx,filt)
%LMIN 	function [lmval,indd]=lmin(x,filt)
%	Find local minima in vector X, where LMVAL is the output
%	vector with minima values, INDD is the corresponding indeces
%	FILT is the number of passes of the small running average filter
%	in order to get rid of small peaks.  Default value FILT =0 (no
%	filtering). FILT in the range from 1 to 3 is usially sufficient to
%	remove most of a small peaks
%	Examples:
%	xx=0:0.01:35; y=sin(xx) + cos(xx ./3);
%	plot(xx,y); grid; hold on;
%	[a b]=lmin(y,2)
%	 plot(xx(a),y(a),'r+')
%	see also LMAX, MAX, MIN

%
%**************************************************|
% 	Serge Koptenko, Guigne International Ltd., |
%	phone (709)895-3819, fax (709)895-3822     |
%--------------06/03/97----------------------------|

x=xx;
len_x = length(x);
fltr=[1 1 1]/3;
if nargin <2, filt=0;
else
    x1=x(1); x2=x(len_x);
    
    for jj=1:filt,
        c=conv(fltr,x);
        x=c(2:len_x+1);
        x(1)=x1;
        x(len_x)=x2;
    end
end

lmval=[];
indd=[];
i=2;		% start at second data point in time series

while i < len_x-1,
    if x(i) < x(i-1)
        if x(i) < x(i+1)	% definite min
            lmval =[lmval x(i)];
            indd = [ indd i];
            
        elseif x(i)==x(i+1)&x(i)==x(i+2)	% 'long' flat spot
            %lmval =[lmval x(i)];	%1   comment these two lines for strict case
            %indd = [ indd i];	%2 when only  definite min included
            i = i + 2;  		% skip 2 points
            
        elseif x(i)==x(i+1)	% 'short' flat spot
            %lmval =[lmval x(i)];	%1   comment these two lines for strict case
            %indd = [ indd i];	%2 when only  definite min included
            i = i + 1;		% skip one point
        end
    end
    i = i + 1;
end

if filt>0 & ~isempty(indd),
    if (indd(1)<= 3)|(indd(length(indd))+2>length(xx)),
        rng=1;	%check if index too close to the edge
    else rng=2;
    end
    
    for ii=1:length(indd),
        [val(ii) iind(ii)] = min(xx(indd(ii) -rng:indd(ii) +rng));
        iind(ii)=indd(ii) + iind(ii)  -rng-1;
    end
    indd=iind; lmval=val;
else
end
end

function [lmval,indd]=lmax(xx,filt)
%LMAX 	[lmval, indd]=lmax(xx,filt). Find local maxima in vector XX,where
%	LMVAL is the output vector with maxima values, INDD  is the
%	corresponding indexes, FILT is the number of passes of the small
%	running average filter in order to get rid of small peaks.  Default
%	value FILT =0 (no filtering). FILT in the range from 1 to 3 is
%	usially sufficient to remove most of a small peaks
%	For example:
%	xx=0:0.01:35; y=sin(xx) + cos(xx ./3);
%	plot(xx,y); grid; hold on;
%	[b,a]=lmax(y,2)
%	 plot(xx(a),y(a),'r+')
%	see also LMIN, MAX, MIN

%**************************************************|
% 	Serge Koptenko, Guigne International Ltd., |
%	phone (709)895-3819, fax (709)895-3822     |
%--------------06/03/97----------------------------|

x=xx;
len_x = length(x);
fltr=[1 1 1]/3;
if nargin <2, filt=0;
else
    x1=x(1); x2=x(len_x);
    for jj=1:filt,
        c=conv(fltr,x);
        x=c(2:len_x+1);
        x(1)=x1;
        x(len_x)=x2;
    end
end
lmval=[]; indd=[];
i=2;		% start at second data point in time series
while i < len_x-1,
    if x(i) > x(i-1)
        if x(i) > x(i+1)	% definite max
            lmval =[lmval x(i)];
            indd = [ indd i];
        elseif x(i)==x(i+1)&x(i)==x(i+2)	% 'long' flat spot
            %lmval =[lmval x(i)];  	%1   comment these two lines for strict case
            %indd = [ indd i];	%2 when only  definite max included
            i = i + 2;  		% skip 2 points
        elseif x(i)==x(i+1)	% 'short' flat spot
            %lmval =[lmval x(i)];	%1   comment these two lines for strict case
            %indd = [ indd i];	%2 when only  definite max included
            i = i + 1;		% skip one point
        end
    end
    i = i + 1;
end
if filt>0 & ~isempty(indd),
    if (indd(1)<= 3)|(indd(length(indd))+2>length(xx)),
        rng=1;	%check if index too close to the edge
    else rng=2;
    end
    for ii=1:length(indd), 	% Find the real maximum value
        [val(ii) iind(ii)] = max(xx(indd(ii) -rng:indd(ii) +rng));
        iind(ii)=indd(ii) + iind(ii)  -rng-1;
    end
    indd=iind; lmval=val;
else
end
end


