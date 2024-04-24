% function z = Auto_Focus_Tamura_v2(I,l,u,delta_z,pixel_size,refidx,lambda,tf_phase,ROI)
% Auto Focus using Tamura Coefficient
% 05/15/2015, created by Chris, chris.yichen.wu@gmail.com
% 07/22/2015, modified by Chris, changed the way to define propagation 
% to address complaints.:(... Also added phase focus capability :)
% 
% Input Variables:
%   I       - input hologram for auto-focus
%   [l,u]   - search range of z2, in m
%   delta_z - tolerance of focus distance
%   pixel_size - pixel_size, in m
%   refidx  - refractive index, in 1
%   lambda  - wavelength, in m
%   tf_phase    - 1 for focusing phase, 0 for amplitude. In 0~1, we calculate
%               both criteria and give a geometric mean of them
%   ROI     - ROI for focus 1x4 matrix [lx,ly,ux,uy] in pixels, (NOTE we don't propagate a small region,
%           instead, we propagate whole 'I', then only calculate the focus criteria of this ROI. If you want
%           to propagate small region, you may alternatively crop the 'I' first before feed into this code. DEFAULT is whole ROI)   
%
% Output Variables:
%   z       - auto-focused propagation distance 
%

function z = Auto_Focus_Tamura_v2(I,l,u,delta_z,pixel_size,refidx,lambda,tf_phase,ROI)

if nargin <= 7
    tf_phase = 0;
end

if nargin <= 8
    [Ny,Nx] = size(I);
    ROI = [1,1,Nx,Ny];
end
ROI = ROI-zeros(1,4);

tic;


% rough focus to make sure of concavity
[l,u] = rough_focus(I,l,u,ROI,tf_phase,pixel_size,refidx,lambda);

if isnan(l)||isnan(u)
    z = NaN;
else
    % fine search using golden ratio in concave region
    alpha = (sqrt(5)-1)/2;
    p = u-alpha*(u-l);
    fp = focus_error(I,p,ROI,tf_phase,pixel_size,refidx,lambda);
    q = l+alpha*(u-l);
    fq = focus_error(I,q,ROI,tf_phase,pixel_size,refidx,lambda);

    while u-l > delta_z
        if fp < fq
            l = p;
            p = q;
            fp = fq;
            q = l+alpha*(u-l);
            fq = focus_error(I,q,ROI,tf_phase,pixel_size,refidx,lambda);
        else
            u = q;
            q = p;
            fq = fp;
            p = u-alpha*(u-l);
            fp = focus_error(I,p,ROI,tf_phase,pixel_size,refidx,lambda);
        end 
    %     disp(l); disp(u);
    end

    z = (l+u)/2;
end

toc

end

% recursively shrink [zl,zu] to make search region convex
function [l,u] = rough_focus(I,l0,u0,ROI,tf_phase,pixel_size,refidx,lambda)

% flexible parameters
M = 3;    % totally 4M+1 rough search points

% kernal starts here
N = 2*M;  % totally 2N+1 search Points for concavity

z_list = linspace(l0,u0,2*N+1);
g_list = zeros(1,2*N+1);
for ii = 1:2*N+1
    g_list(ii) = focus_error(I,-z_list(ii),ROI,tf_phase,pixel_size,refidx,lambda);
end
figure(20); plot(z_list,g_list); drawnow;
flag_concave = 0;
while ~flag_concave
    flag_concave = 1;
    % check concavity
    for ii = 2:N-1
%         if (g_list(ii-1)+g_list(ii+1)) > (2*g_list(ii))   % concave criteria
        if g_list(ii) <= min([g_list(ii-1),g_list(ii+1)])   % quasi-concave criteria
            flag_concave = 0;
            disp('z range is not concave,half-shrinking...');
            break;
        end
    end
    [~,max_ind] = max(g_list);
    if max_ind == 1
        warning('Lowerbound Too Large: Decrease Lowerbound');
        z_list(:) = NaN;
        break;
    end
    if max_ind == 2*N+1
        warning('Upperbound Too Small: Increase Upperbound');
        z_list(:) = NaN;
        break;
    end
    if max_ind-M < 1
        start_ind = 1;
    elseif max_ind+M>2*N+1
        start_ind = 2*N+1-2*M;
    else
        start_ind = max_ind-M;
    end
    temp_z = z_list;
    temp_g = g_list;
    % keep N+1 points unchanged to simplify calculation complexity
    for ii = 1:N+1
        z_list(2*ii-1) = temp_z(start_ind+(ii-1));
        g_list(2*ii-1) = temp_g(start_ind+(ii-1));
    end
    % calculate focus error of additional N points, total 2N+1 points
    for ii = 1:N
        z_list(2*ii) = (z_list(2*ii-1)+z_list(2*ii+1))/2;
        g_list(2*ii) = focus_error(I,-z_list(2*ii),ROI,tf_phase,pixel_size,refidx,lambda);
    end
figure(20); plot(z_list,g_list); drawnow;
%     disp(diff(z_list));
%     disp(g_list);
end
l = z_list(1);
u = z_list(2*N+1);

end

function err = focus_error(I,z,ROI,tf_phase,pixel_size,refidx,lambda)

% define the propagation function
PROP = @(x,y) Propagate_ver3(x,pixel_size,refidx,lambda,y,false);

U = PROP(I,-z);
U = U(ROI(2):ROI(4),ROI(1):ROI(3));
if tf_phase == 0
    err = Tamura_coeff(abs(U));
elseif tf_phase == 1
    phase_hold = angle(U*exp(1i*2*pi*refidx*z/lambda));
%     rec_hold = U;
%     rec_hold = rec_hold / exp(1j * angle(mean2(rec_hold)));
%     phase_hold = angle(rec_hold)+2*pi;
    err = Tamura_coeff(abs(phase_hold));
else
    err_amp = Tamura_coeff(abs(U));
    phase_hold = angle(U*exp(1i*2*pi*refidx*z/lambda));
    err_phase = Tamura_coeff(abs(phase_hold));
    err = (err_amp.^(1-tf_phase))*(err_phase.^tf_phase);
end

end


function C = Tamura_coeff(I)

N_crop = 10;     % crop the edge to avoid edge effect
[Ny,Nx] = size(I);
I = I(N_crop:Ny-N_crop,N_crop:Nx-N_crop);

std_I = std(I(:));
mean_I = mean(I(:));
C = sqrt(std_I/mean_I);

end

% function Uz = Propagate_ver3(U,pixelsize,refidx,lambda,z,tf_freqmask)
% Propagation in frequency by division of angular spectrum
% Note: (0,0) assumed to be centered naturally
% Inputs:   spectrum    -   input image in frequency domain
%           pixelsize   -   pixel size of sensor, in m
%           refidx      -   refractive index
%           lambda      -   wavelength, in m
%           z           -   propagation distance
%           tf_freqmask -   0 or 1, add frequency mask to avoid ringing
% 
% 11/20/2014, Created by (Chris) Yichen WU, chris.yichen.wu@gmail.com
% 01/05/2015, ver2 by (Chris) Yichen WU, chris.yichen.wu@gmail.com
%       -   deleted so-called freq_mask
%       -   combined PropGeneral to one function
% 01/15/2015, ver3 by (Chris) Yichen WU, chris.yichen.wu@gmail.com
%       -   added freq_mask

function Uz = Propagate_ver3(U,pixelsize,refidx,lambda,z,tf_freqmask)

FT = @(x) ifftshift(fft2(fftshift(x)));
IFT = @(x) ifftshift(ifft2(fftshift(x)));

spectrum = FT(U);
[NFv, NFh] = size(spectrum);
Fs = 1/pixelsize;
Fh = Fs/NFh .* (-ceil((NFh-1)/2) : floor((NFh-1)/2));
Fv = Fs/NFv .* (-ceil((NFv-1)/2) : floor((NFv-1)/2)); 
[Fhh, Fvv] = meshgrid(Fh, Fv);

DiffLimMat = ones(NFv,NFh);
lamdaeff = lambda/refidx;
DiffLimMat((Fhh.^2+Fvv.^2) >= 1/lamdaeff^2) = 0;

H = exp(1j.*2.*pi.*z./lamdaeff.*(1-(lamdaeff.*Fvv).^2-(lamdaeff*Fhh).^2).^0.5);
H(~DiffLimMat) = 0;

spectrum_z = spectrum.*H;

% if nargout >1
%     DiffLim = DiffLimMat;
% end

if tf_freqmask
    freqmask = BandLimitTransferFunction(pixelsize, z, lambda, Fvv, Fhh);
    spectrum_z = spectrum_z.*freqmask;
end

Uz = IFT(spectrum_z);

end

function [freqmask] = BandLimitTransferFunction(pixelsize, z, lamda, Fvv, Fhh)

[hSize, vSize] = size(Fvv);
dU = (hSize*pixelsize)^-1;
dV = (vSize*pixelsize)^-1;
Ulimit = ((2*dU*z)^2+1)^-0.5/lamda;
Vlimit = ((2*dV*z)^2+1)^-0.5/lamda;

freqmask = (Fvv.^2./(Ulimit^2)+Fhh.^2.*(lamda^2))<=1 & (Fvv.^2.*(lamda^2)+Fhh.^2./(Vlimit^2))<=1;

end



