clearvars; clc; close all;
%% F_trace
% This script will allow the user to select a number of points and create a
% series of images showing the average F over a user selected number of
% boutons as well as a where cutoffs are to measure the noise associated
% with that signal. This should work with any image file type
figure
%% USER VARIABLES
im_type = 'tif';  % image extension currently either 'tif' or 'fits'
stim_fr = 100;        % First frame stimulation occurs on
stims = 15;            % Total number of stimulations
str = 30;            % Stimulation rate in Hz
pixw = 3;           % Pixel width in radius (i.e. value of 7 gives 15x15 square window)
%%%%%%%%%%%%%%%%%%%%%END USER CONTROL%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Analysis
% c = scrub_config();  % reads camera configuration file
[i1, mname, mpath] = read_im(im_type); % loads in an image and corrects
i1 = i1 - min(i1);
[m,n,o] = size(i1); % get image size in [rows, cols, frames]
try
    stim_fr = markerget(mname,'f');
    str = markerget(mname,'h');
    stims = markerget(mname,'s');
catch lsterr
end
% tex = c.AccumulateCycleTime;
tex = 0.02945;
si1 = std(i1,1,3);  % create standard deviation image for selection
imagesc(si1)    % display standard deviation image
axis image

if exist([mpath,mname(1:end-4),'_ROIlist.mat'])
    roi_load = input('A ROI file has been found, would you like to load it(y/n)?', 's');
    if strcmp(roi_load,'y') || strcmp(roi_load,'Y')
        load([mpath,mname(1:end-4),'_ROIlist.mat']);
    end
end

if ~exist('x')
    while true  % ensure user must input a number
        try
            num = input('How many points?');  % ask user how many points to select
            break
        catch lsterr
        end
    end
    
    for i = 1:num  % Select regions and create boxes around selections
        [x(i),y(i)] = ginput(1);
        draw_boxes([x(i),y(i)],pixw);
    end
    
    wind = -pixw:pixw;  % define a variable for easy sub_image selection
    
    for i = 1:num  % select out each sub region and measurements
        sub1 = i1(round(y(i)) + wind, round(x(i)) + wind,:);  % grab image subregion
        sfl = sum(sum(sub1));    % sum up region fluorescence in each frame
        sfluor = sum(sum(sub1)); % creates a 1x1xo variable of total fluorescence/region/frame
        sfluor = sfluor(:);   % linearize array
        ifluor(:,i) = sfl(:);  % ifluor is for individual fluor
    end
    mfluor = mean(ifluor,2);  % average over all individuals gives mfluor (mean fluorescence)
end
t = (1:o)*tex;

%% DATA PLOTTING
plot(t,ifluor,'color', [0, 0, 0] + 0.75); % make individuals traces gray
hold on
plot(t,mfluor, 'color', 'k');  % make mean trace black
% plot stims
for i = 1:stims
    plot([stim_fr*tex + (i-1)/str,stim_fr*tex + (i-1)/str],[min(mfluor),max(mfluor)],'r'); % plot a red line at stim_frame * s/frame + (stimnumber-1)/stimspersec
end
strt_max = stim_fr + ceil(stims/(tex*str));
end_max = strt_max + ceil(1/tex);
snr = (mean(mfluor(strt_max:end_max)) - mean(mfluor(1:stim_fr-1)))/std(mfluor(1:stim_fr-1));
plot([1,stim_fr-1]*tex,[mean(mfluor(1:stim_fr-1)),mean(mfluor(1:stim_fr-1))],'r')
plot([1,end_max]*tex,[mean(mfluor(strt_max:end_max)),mean(mfluor(strt_max:end_max))],'g')

hold off
xlabel('Time in [s]')
ylabel('F in [A.U.]');
title(['Trace of mean F for ',num2str(stims),'AP @ ',num2str(str),'Hz']);
% create new figure of just average fluorescence
figure % make new figure

dfluor = (mfluor - mean(mfluor(1:90)))/mean(mfluor(1:90));
plot(t,dfluor,'k');  % plot only average trace
hold on
% plot stims
for i = 1:stims
    plot([stim_fr*tex + (i-1)/str,stim_fr*tex + (i-1)/str],[min(dfluor),max(dfluor)],'r'); % plot a red line at stim_frame * s/frame + (stimnumber-1)/stimspersec
df = (mfluor - mean(mfluor(1:90)))/mean(mfluor(1:90));
plot(t,df,'k');  % plot only average trace
hold on
end
% plot stims
for i = 1:stims
    plot([stim_fr*tex + (i-1)/str,stim_fr*tex + (i-1)/str],[min(df),max(df)],'r'); % plot a red line at stim_frame * s/frame + (stimnumber-1)/stimspersec
end
hold off
xlabel('Time in [s]')
% ylabel('F in [A.U.]');
ylabel('dF/F_0');
title(['Trace of mean F for ',num2str(stims),'AP @ ',num2str(str),'Hz']);


save([mpath,mname(1:end-4),'_ROIlist.mat'],'x','y','ifluor','mfluor');

