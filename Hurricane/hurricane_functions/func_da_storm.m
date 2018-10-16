function func_da_storm(fname,data_d, an_dir, q, pix2pho, pixw,thresh, angle, sv_im, mi1)

% Convert Variabls
pix2pho = single(pix2pho);
q = single(q);
load('z_calib.mat')
% if exist([data_d, 'z_calib.mat'])
%     cal = load([data_d 'z_calib.mat']);
% else
%     cal = load('z_calib.mat');
% end
% mi1 = 0
% Load file and dark current background subtraction
i1 = (readtiff(fname) - mi1);
i1 = i1.*(i1>0);
[m,n,o] = size(i1);
% i1(1:30,:,:) = 0;
% i1(m-30:m,:,:) = 0;
% i1(:,1:30,:) = 0;
% i1(:,n-30:n,:) = 0;
% Rolling Ball Background Subtract
iprod = rollingball(i1);
% iprod = bp_subtract(i1);
% iprod = imgaussfilt(i1,0.8947);
% iprod = i1;
% Peak Detection


% thrsh = 300/pix2pho;
% diprod = diff(iprod,3);
% for i = 1:o
ifind = denoise_psf(iprod,2);
% thrsh = thresh/100*mean(max(max(iprod)));
% tic
% thrsh = 3*std(iprod(:)) + mean(iprod(:));
% toc
% thrsh = thresh/100*mean(max(max(diprod)));
dps = get_das_peaks(ifind,10);
% end
sum(dps(:))

clear ip ipf i1

% divide up the data
[iloc, fnum, cents] = divide_up(iprod, pixw, dps);
[m,n,o] = size(iloc);
% remove duplicate data
[ind] = find_fm_dupes(cents,fnum,pixw*1.5);
iloc(:,:,ind) = [];
cents(ind,:) = [];
fnum(ind) = [];



% Localize the Data
% [xf_all,xf_crlb, yf_all,yf_crlb,sigx_all, sigx_crlb, sigy_all, sigy_crlb, N, N_crlb,off_all, off_crlb, framenum_all, llv, y, inloc, xin, yin] = da_locs_sigs(iloc, fnum, cents, angle);
% zf_all = getdz(sigx_all,sigy_all)/q;
% [xf_all,xf_crlb, yf_all,yf_crlb,zf_all, zf_crlb, N, N_crlb,off_all, off_crlb, framenum_all, llv, y, inloc, xin, yin] = da_locs(iloc, fnum, cents, angle);zf_all = zf_all/q;                        % This is to handle Z informtation uncomment once calibration is fixed
% [xf_all,xf_crlb, yf_all,yf_crlb,zf_all, zf_crlb, N, N_crlb,off_all, off_crlb, framenum_all, llv, iters, cex, cey] = da_splines(iloc, fnum, cents, cal, pixw);
% [~,~, ~,~,zf_all, zf_crlb, N, N_crlb,off_all, off_crlb, framenum_all, llv, iters, cex, cey] = da_splines(iloc, fnum, cents, cal, pixw);
% i2 = reshape(iloc,m*n,o);
[fits, crlbs, llv, framenumber] = slim_locs(iloc, fnum, cents, cal.ang);
zf = getdz(fits(:,4),fits(:,5),cal.z_cal)/q;
coords = [fits(:,1:2),zf];
[ncoords] = astig_tilt(coords,cal);

%% Find all molecules that pass the initial localization requirements



% Save the Analysis
%  save([an_dir,'\', fname(1:end-4),'_dast.mat'], 'zf_all','sigx_all' ,'sigy_all','sigx_crlb','sigy_crlb','y','iloc','xf_all' , 'xf_crlb' , 'yf_all' , 'yf_crlb' , 'N' , 'N_crlb' ,'off_all' , 'off_crlb', 'framenum_all', 'llv','pixw','q','pix2pho');
% if strcmp(sv_im,'Y') || strcmp(sv_im,'y')
% save([an_dir,'\', fname(1:end-4),'_dast.mat'], 'cents','zf_all','zf_crlb','xf_all' , 'xf_crlb' , 'yf_all' , 'yf_crlb' , 'N' , 'N_crlb' ,'off_all' , 'off_crlb', 'framenum_all', 'llv','iters','pixw','q','pix2pho','ilocs');
% else
    
save([an_dir,'\', fname(1:end-4),'_dast.mat'], 'cents','pixw','q','ncoords','fits','crlbs','llv','framenumber','cal');
% end
% catch lsterr
%      save([an_dir,'\', fname(1:end-4),'_dast.mat'], 'zf_all','sigx_all' ,'sigy_all','sigx_crlb','sigy_crlb','y','iloc','xf_all' , 'xf_crlb' , 'yf_all' , 'yf_crlb' , 'N' , 'N_crlb' ,'off_all' , 'off_crlb', 'framenum_all', 'llv','pixw','q','pix2pho');
end

