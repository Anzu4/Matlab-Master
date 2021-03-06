%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Peak counters.m
% This script will load files containing radial distribution function
% results, smooth them with a gaussian, then determine whether or not a
% peak exists, as well as fit a gaussian to that peak to determine width
%
%
% AJN 3/3/16
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
clc

%% User controlled settings
x = -30:30;
sig = 6;
peak_min = 200;  % minimum distance to start looking for peaks
peak_max = 500;  % maximum distance to start looking for peaks
min_width = 50;
max_width = 1000;
frac_max = 0.4;

% peak_thresh =
%% Gaussian for smoothing
gauss = exp(-x.*x/(2*sig^2));
ngauss = gauss./sum(gauss);

%% File manipulation
[fname, fpath] = uigetfile('*rdf.mat'); %load file
cd(fpath); % change to folder containing file
finfo = dir('*rdf.mat'); % find all files with rdf.mat ending
widths = zeros(200,numel(finfo))-1;
widths_err_all = widths;
peaklocs = widths;
for i = 1:numel(finfo)  % loop over each file to find all peaks in the file
    load(finfo(i).name); % load file
    mindex = find(R>peak_min, 1, 'first');
    maxdex = find(R<peak_max, 1, 'last');
    peaks = 0; % initialize peaks
    for j = 1: numel(g(1,:)) % loop over all g's in a file
        gs(:,j) = conv(g(:,j),ngauss,'same'); % smooth g
        plot(R,gs(:,j)) % plot G
        hold on
        %plot bounds for visual
        plot([R(mindex) R(mindex)],[0 20], 'r')
        plot([R(maxdex) R(maxdex)],[0 20], 'r')
        ylim([0 max(gs(:,j))+2])
        [pks, locs] = findpeaks(gs(mindex:maxdex,j)); % find peaks in the window
        
        if ~isempty(locs) % if a peak is found
            pks = pks(1); % only look at first peak
            locs = locs(1);
            peaks = peaks +1; % increment peak count by 1
            plot(R(locs+mindex), pks, '.r','MarkerSize',30); % plot found peak for visual
            ind051 = find(gs(:,j) >= pks * exp(-1/2),1,'first'); % find left side width
            ind052 = find(gs(locs+mindex:end,j) <= pks * exp(-1/2),1,'first')+locs+mindex; % find right width
            if ind051 > 1 && ind052 < numel(R) && pks == max(gs(:,j)) % if the width is within bounds fit a guassian to it
                x051 = R(locs+mindex) - R(ind051);
                x052 = R(ind052) - R(locs+mindex);
                sigma = (x051+x052)/2; % estimate the sigma of a gaussian
                beta0 = [R(locs+mindex), pks, sigma, 1]; % build beta vector 1 is used as average density
                % NLINFIT of a gaussian of 1 d
                [betafit,resid,J,COVB,mse] = nlinfit(R(mindex:maxdex),gs(mindex:maxdex,j),@gauss1d,beta0);
                ci = nlparci(betafit,resid,'covar',COVB); %calculate error estimates on parameters
                ci_err=(ci(:,2)-ci(:,1))/2;
                % build fitted gaussian
                gaussshow = betafit(2)*exp(-(R-betafit(1)).^2./(2*betafit(3)^2))+betafit(4);
                plot(R,gaussshow,'g'); % show fitted gaussian for visual
                if betafit(3) >= min_width && betafit(3) <= max_width && ci_err(3)/betafit(3) < frac_max
                    peaklocs(peaks,i) = betafit(1);
                    widths(peaks,i) = betafit(3); % save width value
                    widths_err_all(peaks,i) = ci_err(3); % save error of the fit
                    
                else
                    peaks = peaks -1;
                end
                
            end
            
        end
        hold off
        title(finfo(i).name);
%         waitforbuttonpress;
drawnow
    end
    num_peaks(i) = peaks; % record number of peaks found
    perc_peaks(i) = peaks/numel(g(1,:)); % record percentage of peaks in a file
end
%% rebuild widths matrix to a vector
width = widths(:);
peakloc = peaklocs(:);
width_err_all = widths_err_all(:);
width_err_all(width <= 0) = [];
peakloc(width <= 0) = [];
width(width <= 0) = [];
width_err_all(width > 10000) = [];
peakloc(width > 10000) = [];
width(width > 10000) = [];
frac = width_err_all./width;



%% Reorganize data to represent sequence of data taken and build a temporal vector
perc_peaks_t = 0.*perc_peaks;
perc_peaks_t(2:10) = perc_peaks(3:11);
perc_peaks_t(10:11) = perc_peaks(12:13);
perc_peaks_t(12:20) = perc_peaks(14:end);
perc_peaks_t(21) = perc_peaks(1);
t1 = [2 7 12 17 22 27 33 42 48 55 61];
t2 = [3 8 13 19 24 31 37 43 48 52 46];

% plot results
plot(t1, perc_peaks_t(1:11),'.b','MarkerSize',30)
hold on
plot(t2, perc_peaks_t(12:end), '.r','MarkerSize',30)
hold off
xlabel('Time Since Exposure(min)');
ylabel('Percentages of peaks detected to areas analyzed');
legend('TCS','Control')
save('rdf_compilation 3-8-16.mat');