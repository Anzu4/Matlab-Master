% The Perfect Storm
% This is a batch script that will fully analyze a collection of folders 
% specified by the user. We will be calling the batch version of all our
% functions so the user variables setting will be a bit expansive
% AJN 9-27-2020
clearvars;
close all;
clc;

%% Regular Change User Variables
folders_to_analyze = {'D:\Dropbox\Data\9-23-20 fixed hek gpi-halo\'};

%% Set and forget Variables
% Hurricane Variables
emg = 0; % Enter the EM Gain value used on the camera
pix2pho = em_gain(emg);    %Pixel to photon ratio
q = 0.122;          % Pixel size in um
pixw = 6;       % radius to localize (final image size is (2*pixw+1)^2 pixels)
an_dir = 'Analysis'; % name of analysis directory
angle = 0; %approximate astig rotation in degrees
sv_im = 'n'; % set to y/Y to save image of localizations
thresh = 5;

%% Perform the Hurricane Process
% Hurricane Optionals
  % This section is dedicated to a list of variables for the user to select
  % 1 indicates go 0 indicates do not
  savewaves = 0;
  showlocs = 1;
  savepsfs = 0;
  saverb = 0;
  two_color = 3;
  varys = [savewaves, showlocs, savepsfs, saverb, two_color];


cd(folders_to_analyze{1});
try
load('back_subtract.mat');
catch lsterr
    mi1 = 0;
end

files = dir('*.tif');
% if ~isempty([fpath,'\',an_dir])
% sendit2(an_dir);
% end
mkdir(an_dir);
%% Localize the files with the thresholds found
% thresh = findathresh(files,pix2pho,mi1);
% mi1 = 0;
if varys(1) == 1
    mkdir('Waves');
elseif varys(3) == 1
    mkdir('psfs');
elseif varys(4) == 1
    mkdir('Rolling_Ball');
end
disp('Hurricane')
for i = 1:numel(files)
    
    if isempty(strfind(files(i).name,'scan'))
        func_da_storm(files(i).name, dpath, an_dir, q, pix2pho, pixw,thresh, angle, sv_im, mi1, varys);
    end
end
disp('Tolerance')

%Batch H_tol
% files = dir('*dast*');

for i = 1:numel(files)
    filename = ['\Analysis\',files(i).name(1:end-4),'_dast.mat'];
    func_batch_h2_tol_ps(filename);

end
