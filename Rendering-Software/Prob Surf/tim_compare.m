%% Speed Test
close all;
% clearvars;
clc;
radi = 10;
pnts = 100000;
% cd('C:\Users\AJN Lab\Documents\GitHub\Matlab-Master\Rendering-Software\Prob Surf');
% load('C:\Users\AJN Lab\Dropbox\Data\4-26-19 HEK Cell data\Analysis\toleranced\DC\HEK CELL 3_1_dast_tol_dc.mat')
xf = xf_fixed*q;
yf = yf_fixed*q;
zf = ncoords(:,3)*q;
% zf = func_shift_correct(ncoords(:,3)*q,framenumber,2).';
%% Generate Simulation Data
R = 1; % Radius in microns
% for i = 1:pnts
%     theta = rand*2*pi;
%     phi = rand*pi;
%     xf(i,1) = R*cos(theta)*sin(phi);
%     yf(i,1) = R*sin(theta)*sin(phi);
%     zf(i,1) = R*cos(phi);
% end
% xf = xf - mean(xf);
% yf = yf - mean(yf);
% zf = zf - mean(zf);
% for i = 1:90
[rx,ry,rz] = rot_mat(deg2rad(0));
rots = rx*[xf,yf,zf].';

% sizes = [500, 400, 300, 200, 100, 90, 80, 70, 60, 50, 40, 30, 25]; 
% for kk = 1:numel(sizes)
% for i = 1:100
    tic
% disp('GOING!')
% try
    [ix] = func_3D_dens(single([rots]).',100,0.1);
% catch lsterr
% end
    
%     gpu_t(1) = toc
%    i1(1,1,1)
% toc
% %     
% imagesc(max(ix,[],3))
% drawnow
% axis image
% M(i) = getframe(gcf);
% end

[m,n,o] = size(ix);
% pixes(kk) = m*n*o;
% gputim(kk) = mean(gpu_t);
% for tm = 1:100
%     tic
%     i2 = func_3D_hist(rots.',sizes(kk),0.06);
%     cpu_t(tm) = toc;
%     ajn_wait(cpu_t,kk,100);
% end
% cputim(kk) = mean(cpu_t);
% end

%     for i = 1:o
%         imagesc(i1(:,:,i));
% imagesc(mean(i1,3));
% subplot(1,3,1);
% imagesc(mean(ix,3));
% axis image
% title('DX')
% subplot(1,3,2);
% imagesc(mean(iy,3));
% axis image
% title('DY')
% subplot(1,3,3);
% imagesc(mean(iz,3));
%     imagesc(i1(:,:,2));
%         axis image
%         title('DZ')
        drawnow
%         M(i) = getframe(gcf);
%     end
    for i = 1:o
        imagesc(abs(ix(:,:,i)).*(ix(:,:,i)>0));
        axis image
        title([num2str(radi),'nm radius'])
        drawnow
        M(i) = getframe(gcf);
    end
    for i = o:-1:1
        imagesc(abs(ix(:,:,i)).*(ix(:,:,i)>0));
        axis image
        title([num2str(radi),'nm radius'])
        drawnow
        M(numel(M)+1) = getframe(gcf);
end
    movie2gif(M,['diffraction_roll_image_',num2str(radi),'.gif'],'Delaytime', 0.05,'LoopCount',Inf);
%     plot3(rots(1,:),rots(2,:),rots(3,:),'.')
%     xlim([-10 10])
%     ylim([-10 10])
%     zlim([-10 10])
%     drawnow
% end