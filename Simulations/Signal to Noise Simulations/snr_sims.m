close all; clearvars; clc; % clean up
% SNR_Localization_simulation
% This simulation will take fitted parameters of latex beads and use them
% to create simulated point spread functions which are used for subsequent
% fitting and comparison of localization information

%% User Settings
% SNRs = 10.^(1:0.1:5); % these will enter the N to offset calculation via the equation snr = N/offset^0.5
frames = 10000; % Number of molecules to create at each setting
pixw = 6;   % size of total image molecule is created on
q = 0.122;
% End User Settings

%% PSF Developement
% load('PSF_params.mat'); % Load bead data from a ladder test

% Choose fitting parameters


x0 = rand(1) - 0.5; % Center the Molecule somewhere in the first pixel
y0 = rand(1) - 0.5; % Center the Molecule somewhere in the first pixel
N = 277; % SNR will be created from setting the offset relative to the N
phalp = 21;

% Allow user to 'choose' a sigma value based on height of the molecule
% fitted
load('z_calib.mat') % load latex calibrated data
[zs, parms] = getdz(0,0,cal.z_cal);
clear zs
% figure('Units','Normalized','Outerposition', [0.25 0.25 0.5 0.5]) % Create a full frame figure
% plot(coords(:,3)*q*1000); % Show stair step pattern 
% xlabel('Framenumber'); % proper label of graph
% ylabel('Axial position in pixels');% proper label of graph
% title('Choose a height to Model'); % instruction to user
% [x,y] = ginput(1); % Graphically chose the parameter desired
% id = round(x); % Choose molecule index determined by user
% sx = fits(id,4); % assign sigma values from molecule id
% sy = fits(id,5);

ind = find(parms(:,1) == 0);
sx = parms(ind,2);
sy = parms(ind,3);
% B = 25;
[xpix,ypix] = meshgrid(-pixw:pixw); % Create mesh grids for desired window
Ns = 100:100:10000;
% for lk = 1:numel(Ns)
%     N = Ns(lk);
%     SNRs = (N/N^0.5);
SNRs = 16;
for i = 1:numel(SNRs) % Loop over SNRs
%     x0 = rand(1) - 0.5; % Center the Molecule somewhere in the first pixel
% y0 = rand(1) - 0.5; % Center the Molecule somewhere in the first pixel
    % Variables to Loop Over
%     i1x = 1/2.*(erf((xpix - x0 + 1/2)./(2*3.92^2)^0.5)-erf((xpix - x0 - 1/2)./(2*3.92^2)^0.5)); % error function of x integration over psf for each pixel
%     i1y = 1/2.*(erf((ypix - y0 + 1/2)./(2*3.92^2)^0.5)-erf((ypix - y0 - 1/2)./(2*3.92^2)^0.5)); % error function of y integration over psf for each pixel
% id = randi(numel(fits(:,1)));
% sx = fits(id,4); % assign sigma values from molecule id
% sy = fits(id,5);
    B = ((N/SNRs(i))^2-N)/numel(xpix(:)); % SNR = N/B algebra gives us the code
    B0(i) = B;
        i1 = xpix.*0;
        % Create a gaussian
        i1x = 1/2.*(erf((xpix - x0 + 1/2)./(2*sx^2)^0.5)-erf((xpix - x0 - 1/2)./(2*sx^2)^0.5)); % error function of x integration over psf for each pixel
        i1y = 1/2.*(erf((ypix - y0 + 1/2)./(2*sy^2)^0.5)-erf((ypix - y0 - 1/2)./(2*sy^2)^0.5)); % error function of y integration over psf for each pixel
        i1 = N * i1x.*i1y+B;
        im0(:,:,i) = i1;
    for j = 1:frames
        im1(:,:,j) = double(imnoise(uint16(i1),'poisson'));
%           im1(:,:,j) = double(imnoise(uint16(i1),'poisson'));
%           im1(:,:,j) = double(imnoise(uint16(i1),'poisson')) - imgaussfilt(B,1.5);
%           imj = im1(:,:,j);
%           sim = sort(imj(:));
%           im1(:,:,j) = im1(:,:,j);
%         surf(im1(:,:,j))
%         drawnow
    end
    A{i} = im1.*(im1>0);
end


clear im1










% cord0 = coords;


for i = 1:numel(A)
   iloc = A{i};
   [fits, crlbs, llv] = slim_locs(iloc);
   [zf,parms] = getdz(fits(:,4),fits(:,5),cal.z_cal);
   coords = [fits(:,1:2),zf/q];
   crl{i} = crlbs;
   cords{i} = coords;
   fit{i} = fits;
   try
       xstd(i) = std(coords(:,1)*q*1000)
       ystd(i) = std(coords(:,2)*q*1000)
       sxstd(i) = q*mean((fits(:,4)-sx).^2).^0.5;
       systd(i) = q*mean((fits(:,5)-sy).^2).^0.5;
       zstd(i) = std(coords(:,3)*q*1000);
   catch
   end
end     
figure
histogram((coords(:,1)-mean(coords(:,1)))*q*1000)
hold on
histogram((coords(:,2)-mean(coords(:,2)))*q*1000)
% histogram(coords(:,3)*q*1000)
hold off
% 
% plot(SNRs,zstd)
% hold on
% plot(SNRs,xstd)
% plot(SNRs,ystd)
% % set(gca,'XScale','Log')
% % Bs = 
% % plot(B0,zstd);
% % hold on
% % plot(B0,xstd)
% % plot(B0,ystd)
% plot([12,12],[0,max(zstd)],'r')
% set(gca,'XScale','Log')
% legend('Z-precision','X-Precision','Y-Precision','Our results')
% % xlabel('Background (photons)')
% xlabel('SNR (ratio)')
% ylabel('Localization Prescion in nm')
% title('Uncertainty Versus SNR')
% 
% figure
% plot(B0,zstd);
% hold on
% plot(B0,xstd)
% plot(B0,ystd)
% set(gca,'XScale','Log')
% legend('Z-precision','X-Precision','Y-Precision','Our results')
% xlabel('Background (photons)')
% % xlabel('SNR (ratio)')
% ylabel('Localization Prescion in nm')
% title('Uncertainty Versus Background')
% 
% 
% 
% for i = 1:numel(crl)
%     uncx(i) = mean(crl{i}(:,1).^0.5*128);
%     uncy(i) = mean(crl{i}(:,2).^0.5*128);
%     stx(i) = std(fit{i}(:,4)*128);
%     sty(i) = std(fit{i}(:,5)*128);
% end
% figure
% plot(SNRs,sxstd*1000)
% hold on
% plot(SNRs,systd*1000)
% legend('Sigx','Sigy')
% set(gca,'XScale','Log')
% xlabel('SNR (ratio)')
% ylabel('RMS of (Fit width - True Width) (nm)')
% title('RMS of (Fit width - True Width) versus SNR')
% 
% figure
% plot(B0,sxstd*1000)
% hold on
% plot(B0,systd*1000)
% legend('Sigx','Sigy')
% set(gca,'XScale','Log')
% xlabel('Background (photons)')
% ylabel('RMS of (Fit width - True Width) (nm)')
% title('RMS of (Fit width - True Width) versus Background')
% 
% % pHluorin population SNR reduction
x= 1:300;
y = phalp^0.5./(x+phalp-1).^0.5;
% figure
% plot(x,y);
% xlabel('Number of dark pHluorins in Background')
% ylabel('Reduction in SNR to be expected')
% 
% zdeal = 200; % This is the maximum allowable Z uncertainty
% zdist = abs(zstd - zdeal); % find distance
% ind = find(zdist == min(zdist));
% redsnr = SNRs(ind);
% reduct = redsnr/max(SNRs);
% ydis = abs(y-reduct);
% mind = find(ydis == min(ydis));
% disp(['I estimate the maximum number of vesicles molecules that can be tolerated for a brightness of ', num2str(N),'is ', num2str(x(mind)/1.23),' vesicles']);
% mol(lk) = x(mind);
% end
% 
% figure
% plot(SNRs,zstd)
% hold on
% plot(SNRs,xstd)
% plot(SNRs,ystd)
% % set(gca,'XScale','Log')
% % Bs = 
% % plot(B0,zstd);
% % hold on
% % plot(B0,xstd)
% % plot(B0,ystd)
% set(gca,'XScale','Log')
% legend('Z-precision','X-Precision','Y-Precision')
% % xlabel('Background (photons)')
% xlabel('SNR (ratio)')
% ylabel('Localization Prescion in nm')
% title('Uncertainty Versus SNR')
% 
% figure
% plot(SNRs,zstd)
% hold on
% plot(SNRs,xstd)
% plot(SNRs,ystd)
% 
% plot([1,max(SNRs)],[zdeal,zdeal],'r')
% set(gca,'XScale','Log')
% legend('Z-precision','X-Precision','Y-Precision','Desired Z')
% % xlabel('Background (photons)')
% xlabel('SNR (ratio)')
% ylabel('Localization Prescion in nm')
% title('Uncertainty Versus SNR')
% 
% figure
% plot(SNRs,zstd)
% hold on
% plot(SNRs,xstd)
% plot(SNRs,ystd)
% plot([redsnr,redsnr],[0,max(zstd)],'r')
% set(gca,'XScale','Log')
% legend('Z-precision','X-Precision','Y-Precision','Required SNR')
% xlabel('SNR (ratio)')
% ylabel('Localization Prescion in nm')
% title('Uncertainty Versus SNR')
% 

% figure
% plot(x,y);
% hold on
% xlabel('Number of dark pHluorins in Background')
% ylabel('\eta')
% title('\eta vs population')
% 
% figure
% plot(x,y);
% hold on
% plot([min(x),max(x)],[reduct, reduct],'r')
% legend('\eta','Desired Value')
% xlabel('Number of dark pHluorins in Background')
% ylabel('\eta')
% title('\eta vs population')
% % 
% figure
% plot(x,y);
% hold on
% plot([x(mind),x(mind)],[0.2, 1],'r')
% legend('\eta','Desired Value')
% xlabel('Number of dark pHluorins in Background')
% ylabel('\eta')
% title('\eta vs population')
% 
