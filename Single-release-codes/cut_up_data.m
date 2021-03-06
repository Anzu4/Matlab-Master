%%% Cutting up the data

clearvars;
close all;
clc;
load('back_subtract.mat');
mkdir('Cut_up');
i1 = (readtiff()-mi1)/33.33;
stims = 98;
presc = 100;
imsafter = 10;
[m,n,o] = size(i1);

nstim = floor((o-presc)/stims);

%% Image cleaning
ip1 = rollingball(i1);
dip1 = [];
fms = [];
for i = 1:nstim
    ind = 100 + (i)*stims;
    dip1 = cat(3,dip1, ip1(:,:,ind:ind+imsafter-1) - mean(ip1(:,:,ind-10:ind-1),3));
    fms =[fms,ind:ind + imsafter-1]; 
end
imagesc(dip1(:,:,2));