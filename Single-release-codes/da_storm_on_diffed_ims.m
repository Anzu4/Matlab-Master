% function func_da_storm(fname,data_d, an_dir, q, pix2pho, pixw,thresh, angle, sv_im, mi1)
clc; clearvars; close all;
[fname, fpath] = uigetfile('*.mat');
load([fpath,fname]);
iprod = dip1;
% Convert Variabls
% pix2pho = single(pix2pho);
% q = single(q);
q = 0.133;
pix2pho = 33.33;
thresh = 60;
pixw = 7;
an_dir = 'analysis';
if exist([fpath, 'bead_astig_3dcal.mat'])
    cal = load([fpath, 'bead_astig_3dcal.mat']);
else
    cal = load('bead_astig_3dcal.mat');
end
% mi1 = 0
% Load file and dark current background subtraction
% i1 = (readtiff(fname) - mi1)/pix2pho;
% i1 = i1.*(i1>0);
% [m,n,o] = size(i1);
% i1(1:30,:,:) = 0;
% i1(m-30:m,:,:) = 0;
% i1(:,1:30,:) = 0;
% i1(:,n-30:n,:) = 0;
% Rolling Ball Background Subtract
% iprod = rollingball(i1);
% iprod = bp_subtract(i1);
% iprod = i1;
% Peak Detection


% thrsh = 300/pix2pho;
% diprod = diff(iprod,3);
thrsh = thresh/100*mean(max(max(iprod)));
% tic
% thrsh = 3*std(iprod(:)) + mean(iprod(:));
% toc
% thrsh = thresh/100*mean(max(max(diprod)));
dps = get_das_peaks(iprod,thrsh);
sum(dps(:))

clear ip ipf i1

% divide up the data
[iloc, fnum, cents] = divide_up(iprod, pixw, dps);

% remove duplicate data
[ind] = find_dupes(cents,fnum);
iloc(:,:,ind) = [];
cents(ind,:) = [];
fnum(ind) = [];
% Localize the Data
% [xf_all,xf_crlb, yf_all,yf_crlb,sigx_all, sigx_crlb, sigy_all, sigy_crlb, N, N_crlb,off_all, off_crlb, framenum_all, llv, y, inloc, xin, yin] = da_locs_sigs(iloc, fnum, cents, angle);
% zf_all = getdz(sigx_all,sigy_all)/q;
% [xf_all,xf_crlb, yf_all,yf_crlb,zf_all, zf_crlb, N, N_crlb,off_all, off_crlb, framenum_all, llv, y, inloc, xin, yin] = da_locs(iloc, fnum, cents, angle);zf_all = zf_all/q;                        % This is to handle Z informtation uncomment once calibration is fixed
[xf_all,xf_crlb, yf_all,yf_crlb,zf_all, zf_crlb, N, N_crlb,off_all, off_crlb, framenum_all, llv, iters] = da_splines(iloc, fnum, cents, cal, pixw);
try
zf_crlb = zf_crlb/(q)^2; % this puts the CRLB in units of pix^2
zf_all = zf_all/q; % this puts zf_all in units of pix

%% Find all molecules that pass the initial localization requirements



% Save the Analysis
%  save([an_dir,'\', fname(1:end-4),'_dast.mat'], 'zf_all','sigx_all' ,'sigy_all','sigx_crlb','sigy_crlb','y','iloc','xf_all' , 'xf_crlb' , 'yf_all' , 'yf_crlb' , 'N' , 'N_crlb' ,'off_all' , 'off_crlb', 'framenum_all', 'llv','pixw','q','pix2pho');
 save([an_dir,'\', fname(1:end-4),'_dast.mat'], 'fms','cents','zf_all','zf_crlb','xf_all' , 'xf_crlb' , 'yf_all' , 'yf_crlb' , 'N' , 'N_crlb' ,'off_all' , 'off_crlb', 'framenum_all', 'llv','iters','pixw','q','pix2pho');
catch lsterr
end

