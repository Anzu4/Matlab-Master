% H_tol
% a script to apply tolerances to the fitting function for localization
% data that was acquired with the 'Hurricane' program
clearvars; close all; clc;

%Tolerance data
zlims= [-0.1941, 0.75]; % Limit of the absolute value of z-data in pixels
flims = [0,-1];
lat_max = 0.1; % Maximum lateral uncertainty in micrometers
N_tol = [1400, 1400000]; % Tolerance on N
offlim = [0, 1250];

iln = -2;  % lower bound on llv/N
frac_lim = 0.15; % Limit on the fractional uncertainty of any value
off_frac = 0.3;



[fname, fpath] = uigetfile('*dast.mat');
cd(fpath)
load([fpath,fname]);
if flims(2) == -1
    flims(2) = max(framenumber);
end
[~, p] = getdz(1,1,cal.z_cal);

s_tol = [min(min([p(:,2),p(:,3)])),max(max([p(:,2),p(:,3)]))]; % sigma tolerances
% s_tol = [0.8, 8]; % sigma tolerances
fits(:,4) = abs(fits(:,4));
fits(:,5) = abs(fits(:,5));
%Define fractionals
fr_N =  crlbs(:,3).^0.5./fits(:,3);
fr_sx = crlbs(:,4).^0.5./fits(:,4);
fr_sy = crlbs(:,5).^0.5./fits(:,5);
fr_o =  crlbs(:,6).^0.5./fits(:,6);
ilv = llv(:)./fits(:,3);
eps = abs(fits(:,4)./fits(:,5));

% Apply Tolerances
% ind = start_w_z(ncoords(:,3)*q,eps, cal.z_cal);


ind = fits(:,3) > N_tol(1) & fits(:,3) < N_tol(2); % Photon Tolerance

ind = ind & abs(framenumber - mean(flims)) <= diff(flims)/2;

ind = ind & abs(ncoords(:,3)*q-mean(zlims)) <= diff(zlims)/2;

ind = ind & abs(fits(:,6)-mean(offlim)) <= diff(offlim)/2;

ind = ind & (abs(fits(:,4)).*abs(fits(:,5))).^0.5 > s_tol(1) & (abs(fits(:,4)).*abs(fits(:,5))).^0.5 < s_tol(2); % Photon Tolerance
% ind = ind & fits(:,5) > s_tol(1) & fits(:,5) < s_tol(2); % Photon Tolerance

ind = ind & q*crlbs(:,1).^.5 < lat_max & q*crlbs(:,2).^.5 < lat_max; % Lateral Uncertainty Tolerance

ind = ind & ilv > iln; % llv tolerance

ind = ind & fr_N < frac_lim & abs(fr_o) < off_frac; % Fraction photon tolerance

ind = ind & fr_sx < frac_lim & fr_sy < frac_lim; % Fraction width tolerance

% ind = ind & eps <= maxe & eps >= mine;

save('Tolfile.mat','flims','zlims','lat_max','N_tol','s_tol','iln','frac_lim','off_frac','offlim');
% Setting up our figure
zf = func_build_ramp(ncoords(:,3)*q,framenumber,40,5,0);
f = figure;
tg = uitabgroup(f);
t1 = uitab(tg,'Title','Localizations');
tg1 = uitabgroup(t1);
t21 = uitab(tg1,'Title','Pre-Tolerance');
ax = axes(t21);
plot(ax, ncoords(:,1)*q,ncoords(:,2)*q,'.');
xlabel(ax,'microns');
ylabel(ax,'microns');
axis equal
t2 = uitab(tg1,'Title','Post-Tolerance');
ax = axes(t2);
plot(ax, ncoords(ind,1)*q,ncoords(ind,2)*q,'.');
xlabel(ax,'microns');
ylabel(ax,'microns');
axis equal
t3 = uitab(tg1,'Title','Post-Tolerance 3D');
ax = axes(t3);
plot3(ax, ncoords(ind,1)*q,ncoords(ind,2)*q,zf(ind),'.');
xlabel(ax,'microns');
ylabel(ax,'microns');
zlabel(ax,'microns');
axis equal
clear t1 t2 t3 t21 ax

t2 = uitab(tg,'Title','Fit-Histograms');

tg2 = uitabgroup(t2);
t21 = uitab(tg2,'Title','Z-Histogram');
ax = axes(t21);
histogram(ax,zf(ind));
xlabel('Z-position(um)')
ylabel('Frequency')
title('Z-Position Histogram')

t22 = uitab(tg2,'Title','N-Histogram');
ax = axes(t22);
histogram(ax,fits(ind,3));
xlabel('N (photons)')
ylabel('Frequency')
title('Photons Fitted Histogram')

t23 = uitab(tg2,'Title','sigma-Histogram');
ax = axes(t23);
histogram(ax,fits(ind,4));
hold on
histogram(ax,fits(ind,5));
hold off
legend(ax,'\sigma_x','\sigma_y')
xlabel(ax,'\sigma (pixels)')
ylabel(ax,'Frequency')
title('\sigma Fitted Histogram')

t24 = uitab(tg2,'Title','Offsets-Histogram');
ax = axes(t24);
histogram(ax,fits(ind,6));
xlabel(ax,'Offset (photons)')
ylabel(ax,'Frequency')
title('Offset Histogram')

clear t2 tg2 t21 t22 t23 t24

t2 = uitab(tg,'Title','CRlB-Histograms');
tg2 = uitabgroup(t2);

t21 = uitab(tg2,'Title','Lateral-CRLB');
ax = axes(t21);
histogram(ax,crlbs(ind,1).^0.5*q)
hold on
histogram(ax,crlbs(ind,2).^0.5*q)
hold off
legend(ax,'X-unc','Y-unc');
xlabel(ax,'Lateral Uncertainty (um)')
ylabel(ax,'Frequency')
title('Lateral Uncertainty');
clear t21

t22 = uitab(tg2,'Title','Frac N');
ax = axes(t22);
histogram(ax,fr_N(ind))
xlabel(ax,'Frac Uncertainty N')
ylabel(ax,'Frequency')
title('N Uncertainty');
clear t22

t23 = uitab(tg2,'Title','Frac sigma');
ax = axes(t23);
histogram(ax,fr_sx(ind))
hold on
histogram(ax,fr_sy(ind))
xlabel(ax,'Frac Uncertainty \sigma')
ylabel(ax,'Frequency')
title('\sigma Uncertainty');clear t21
clear t23

t24 = uitab(tg2,'Title','Frac offset');
ax = axes(t24);
histogram(ax,fr_o(ind))
xlabel(ax,'Frac Uncertainty offset')
ylabel(ax,'Frequency')
title('Offset Uncertainty');
clear t24

t24 = uitab(tg2,'Title','Iln');
ax = axes(t24);
histogram(ax,ilv(ind))
xlabel(ax,'llv/N')
ylabel(ax,'Frequency')
title('llv/N');
clear t24

clear tg2 t2
t2 = uitab(tg,'Title','Sigma Curves');
ax = axes(t2);
plot(ax,ncoords(ind,3)*q,fits(ind,4),'.')
hold on
plot(ax,ncoords(ind,3)*q,fits(ind,5),'.')
legend(ax,'\sigma_x','\sigma_y')
clear t2 tg tg1 f ax