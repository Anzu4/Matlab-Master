%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PSF sim for z position
% AJN 3/30/15
%
% This script will generate a stack of gaussian point spread functions with
% the variables B, ntrue, x0true, y0true, z0true
% The outputs of this script are xf, yf, zf, a0, off0 the 3D coords, number of photons and offset (background) respectively
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc
load('z_cal.mat');
%% Initialization
global xpix ypix wbox
load('C:\Users\AJN Lab\Documents\GitHub\Matlab-Master\Hurricane\hurricane_functions\z_calib.mat');
rbox = 9;
[xpix, ypix] = meshgrid(-rbox:rbox,-rbox:rbox);
% xpix = single(xpix);
% ypix = single(ypix);
% xpix = gpuArray(xpix);
% ypix = gpuArray(ypix);
wbox = 2*rbox+1;
i1 = xpix.*0;
% sxo = xsig;
% syo = ysig;
% axo = Ax;
% bxo = Bx;
% ayo = Ay;
% byo = By;
% gxo = - gx/1000;
% gyo = gy/1000;
% dxo = dx/1000;
% dyo = dy/1000;
% xs = 1.08;
% ys = 1.01;
% ax = -0.0708;
% bx = -0.073;
% ay = 0.164;
% by = 0.0417;
% gx = 0.389;
% gy = -0.389;
% dx = 0.531;
% dy = 0.531;

xs = z_cal(1);
gx = z_cal(2);
dx = z_cal(3);
ax = z_cal(4);
bx = z_cal(5);

ys = z_cal(6);
gy = z_cal(7);
dy = z_cal(8);
ay = z_cal(9);
by = z_cal(10);
zcurve = ([xs, ys, ax, ay, bx, by, dx, dy, gx, gy]);
% gxo = -(gx*0.5+gy*0.5)/1000;
% gyo = (gx*0.5+gy*0.5)/1000;
% dxo = (dx*0.5 + dy*0.5)/1000;
% dyo = (dx*0.5 + dy*0.5)/1000;
% variables of image
B = 0;
ntrue = 1000;
x0true = (rand-0.5);
y0true = (rand - 0.5);
% x0true = 0;
% y0true = 0;
z(1) = 0;
z(2) = 0;
frames = 1;

zs = -1:0.01:1;
% zs = 0.155;
% Zfin = cell(numel(z),1);
 for op = 1:numel(zs)
    z0true = zs(op);
    sigx = xs*(1 + ((z0true - gx)/dx).^2 + ax*((z0true - gx)/dx).^3 + bx*((z0true - gx)/dx).^4).^0.5;
    sigy = ys*(1 + ((z0true - gy)/dy).^2 + ay*((z0true - gy)/dy).^3 + by*((z0true - gy)/dy).^4).^0.5;
    % r0t_pix = 2*sigma; % 1/e^2 radius
    sigma2 = (1.9773);
    r0t_um = 0.61*0.581/(1.4);        % Rayleigh radius in um
    pix2pho = 1;
    q = 0.128;
    wbox_um = q*wbox;
    Ns = 1000;
%  op = 1;  
        tic

        for i = 1:frames % create psf frames
            
            i1 = xpix.*0;
            % Create a gaussian
            % i1 = ntrue.*(2*pi*sigma^2)^-1.*exp(-((xpix-x0true).^2 +(ypix-y0true).^2)./(2*sigma.^2))+B;
            i1x = 0.5*(erf((xpix - x0true + 1/2)./(2*sigx^2)^0.5)-erf((xpix - x0true - 1/2)./(2*sigx^2)^0.5)); % error function of x integration over psf for each pixel
            i1y = 0.5*(erf((ypix - y0true + 1/2)./(2*sigy^2)^0.5)-erf((ypix - y0true - 1/2)./(2*sigy^2)^0.5)); % error function of y integration over psf for each pixel
            i1 = ntrue * i1x.*i1y+B;
            
            %% Create Frames with noise
            
            %     waitbar(i/frames,w2, 'Creating points');
            i2(:,:,i) = double(imnoise(uint16(i1), 'poisson'));
%             i2 = i1;
            i3 = i2(:,:,i);
            il(:,i) = i3(:);
            %     i2(:,:,i) = i1;
        end
     
        
        %% Find molecules and fit them
        for l = 1:frames
            %     waitbar(l/frames,w1 , 'Fitting be patient')
            % i3 = gpui2(:,:,l);
            i3 = i2(:,:,l);
            % i3 = i1;
            
            N = sum(i3(:));
            offguess = 0;
            xguess = sum(sum(xpix.*i3./N));
            yguess = sum(sum(ypix.*i3./N));
            
            % beta0 = [ xguess, yguess, peakguess, sigma2/2, sigma2/2, offguess];
            %
            % [beta,R,J,CovB,MSE] = nlinfit(xfake,zlin,@gaussguess, beta0);
            % elapsed_nlon = toc;
            %% MLE approximation
            % sigma = sx;
            xf = (xguess);
            yf = yguess;
            zf = 0;
            sx = 1.5;
            sy = 1.5;
            offs = offguess;
            % u = gpuArray(zeros(wbox,wbox,frames));
            % while fittime(l) < 100
            flag = 0;
            for k = 1:20
                
                %Define psf and error function for each pixel
%                 if abs(zf) > 10 || flag == 1
%                     zf = 0;
%                     flag = 1;
%                 end
%                 sx = (xs*(1 + ((zf - gx)/dx).^2 + ax*((zf - gx)/dx).^3 + bx*((zf - gx)/dx).^4).^0.5);
%                 sy = (ys*(1 + ((zf - gy)/dy).^2 + ay*((zf - gy)/dy).^3 + by*((zf - gy)/dy).^4).^0.5);
%                 if k == 1
%                     sx = 1.2;
%                     sy = 1.2;
%                 end
                Ex = 1/2*(erf((xpix - xf + 1/2)./(2*sx^2)^0.5)-erf((xpix - xf - 1/2)./(2*sx^2)^0.5)); % error function of x integration over psf for each pixel
                Ey = 1/2*(erf((ypix - yf + 1/2)./(2*sy^2)^0.5)-erf((ypix - yf - 1/2)./(2*sy^2)^0.5)); % error function of y integration over psf for each pixel
                
                u(:,:,k) = N.*Ex.*Ey + offs; % The underlying image is being created identical to
                imagesc(i3-u(:,:,k));
                drawnow
                % partial derivatives of variables of interest
                dudx = N*(2*pi*sx^2)^-0.5.*(exp(-(xpix -xf - 1/2).^2.*(2*sx^2)^-1)-exp(-(xpix -xf + 1/2).^2.*(2*sx^2)^-1)).*Ey; % these derivatives are correct
                dudy = N*(2*pi*sy^2)^-0.5.*(exp(-(ypix -yf - 1/2).^2.*(2*sy^2)^-1)-exp(-(ypix -yf + 1/2).^2.*(2*sy^2)^-1)).*Ex;
               
                %these derivatives are correct
                dudsx = N*(2*pi)^(-1/2)*sx^(-2).*((xpix - xf - 1/2).*exp(-(xpix -xf - 1/2).^2.*(2*sx^2)^-1) - (xpix - xf + 1/2) .*exp(-(xpix -xf + 1/2).^2.*(2*sx^2)^-1)).*Ey; % pd sigx
                dudsy = N*(2*pi)^(-1/2)*sy^(-2).*((ypix - yf - 1/2).*exp(-(ypix -yf - 1/2).^2.*(2*sy^2)^-1) - (ypix - yf + 1/2) .*exp(-(ypix -yf + 1/2).^2.*(2*sy^2)^-1)).*Ex; % pd sigy
               
                dsxdz = xs*(2 * (zf - gx) / (dx*dx) + ax * 3 * ((zf-gx)^2/dx^3) + bx*4*((zf-gx)^3/dx^4))/ (2*(1 + ((zf - gx)/dx).^2 + ax*((zf - gx)/dx).^3 + bx*((zf - gx)/dx).^4).^0.5);
                dsydz = ys*(2 * (zf - gy) / (dy*dy) + ay * 3 * ((zf-gy)^2/dy^3) + by*4*((zf-gy)^3/dy^4))/ (2*(1 + ((zf - gy)/dy).^2 + ay*((zf - gy)/dy).^3 + by*((zf - gy)/dy).^4).^0.5);
%                 dsxdz = xs*(2 * (zf - gx) / (dx*dx) + ax * 3 * ((zf-gx)^2/dx^2) + bx*4*((zf-gx)^3/dx^2))/ (2*(1 + ((zf - gx)/dx).^2 + ax*((zf - gx)^3/dx^2) + bx*((zf - gx)^4/dx^2)).^0.5);
%                 dsydz = ys*(2 * (zf - gy) / (dy*dy) + ay * 3 * ((zf-gy)^2/dy^2) + by*4*((zf-gy)^3/dy^2))/ (2*(1 + ((zf - gy)/dy).^2 + ay*((zf - gy)^3/dy^2) + by*((zf - gy)^4/dy^2)).^0.5);
                
                dudz = dudsx.*dsxdz + dudsy.*dsydz;
                % It was noticed in the current GPU codes that there was a parentheses
                % error putting a major denominator term in the numerator
                
                dudi = Ex.*Ey;
                dudb = 1;
                
                
                % Second partial derivatives of variables of interest
                %these derivatives are fine
                d2udx2 = N*(2*pi)^-0.5*sx^-3*((xpix - xf - 1/2).*exp(-(xpix -xf - 1/2).^2.*(2*sx^2)^-1) - (xpix - xf + 1/2) .*exp(-(xpix -xf + 1/2).^2.*(2*sx^2)^-1)).*Ey;
                d2udy2 = N*(2*pi)^-0.5*sy^-3*((ypix - yf - 1/2).*exp(-(ypix -yf - 1/2).^2.*(2*sy^2)^-1) - (ypix - yf + 1/2) .*exp(-(ypix -yf + 1/2).^2.*(2*sy^2)^-1)).*Ex;
                
                d2udsx2 = N.*Ey.*(2*pi)^-0.5.*((sx^-5.* ((xpix - xf - 1/2).^3.*exp(-(xpix -xf - 1/2).^2.*(2*sx^2)^-1) - (xpix - xf + 1/2).^3.*exp(-(xpix -xf + 1/2).^2.*(2*sx^2)^-1))) ...
                    - 2.*sx.^-3.*((xpix - xf - 1/2).*   exp(-(xpix -xf - 1/2).^2.*(2*sx^2)^-1) - (xpix - xf + 1/2) .*  exp(-(xpix -xf + 1/2).^2.*(2*sx^2)^-1)));
                % second partial for sigmay
                d2udsy2 = N.*Ex.*(2*pi)^-0.5.*((sy^-5.* ((ypix - yf - 1/2).^3.*exp(-(ypix -yf - 1/2).^2.*(2*sy^2)^-1) - (ypix - yf + 1/2).^3.*exp(-(ypix -yf + 1/2).^2.*(2*sy^2)^-1))) ...
                    - 2.*sy.^-3.*((ypix - yf - 1/2).*   exp(-(ypix -yf - 1/2).^2.*(2*sy^2)^-1) - (ypix - yf + 1/2) .*  exp(-(ypix -yf + 1/2).^2.*(2*sy^2)^-1)));
                
                d2sxdz2 = xs*(2/(dx)^2 + ax*6*(zf-gx)/(dx)^3 + bx*12*(zf-gx)^2/(dx)^4)/ (2*(1 + ((zf - gx)/dx).^2 + ax*((zf - gx)/dx).^3 + bx*((zf - gx)/dx).^4).^0.5)...
                    - xs*(2 * (zf - gx) / (dx*dx) + ax * 3 * ((zf-gx)^2/dx^3) + bx*4*((zf-gx)^3/dx^4))^2/ (4*(1 + ((zf - gx)/dx).^2 + ax*((zf - gx)/dx).^3 + bx*((zf - gx)/dx).^4).^1.5);
                d2sydz2 = ys*(2/(dy)^2 + ay*6*(zf-gy)/(dy)^3 + by*12*(zf-gy)^2/(dy)^4)/ (2*(1 + ((zf - gy)/dy).^2 + ay*((zf - gy)/dy).^3 + by*((zf - gy)/dy).^4).^0.5)...
                    - ys*(2 * (zf - gy) / (dy*dy) + ay * 3 * ((zf-gy)^2/dy^3) + by*4*((zf-gy)^3/dy^4))^2/ (4*(1 + ((zf - gy)/dy).^2 + ay*((zf - gy)/dy).^3 + by*((zf - gy)/dy).^4).^1.5);
                
                d2udz2 = d2udsx2.*dsxdz.^2 + dudsx.*d2sxdz2 + d2udsy2.*dsydz.^2 + dsydz.*d2sydz2;
                d2udi2 = 0;
                d2udb2 = 0;
                
                xlap(k,l) = xf;
                ylap(k,l) = yf;
                zlap(k,l) = zf;
                nlap(k,l) = N;
                bglap(k,l) = offs;
                % update variables
                xf = xf - sum(sum(dudx.*((i3./u(:,:,k))-1)))/(sum(sum(d2udx2.*((i3./u(:,:,k))-1) - dudx.^2.*i3./(u(:,:,k).^2))));
                yf = yf - sum(sum(dudy.*((i3./u(:,:,k))-1)))/(sum(sum(d2udy2.*((i3./u(:,:,k))-1) - dudy.^2.*i3./(u(:,:,k).^2))));
                zf = zf - sum(sum(dudz.*((i3./u(:,:,k))-1)))/(sum(sum(d2udz2.*((i3./u(:,:,k))-1) - dudz.^2.*i3./(u(:,:,k).^2))));
                N = N - sum(sum(dudi.*((i3./u(:,:,k))-1)))/(sum(sum(d2udi2.*((i3./u(:,:,k))-1) - dudi.^2.*i3./(u(:,:,k).^2))));
                offs = offs - sum(sum(dudb.*((i3./u(:,:,k))-1)))/(sum(sum(d2udb2.*((i3./u(:,:,k))-1) - dudb.^2.*i3./(u(:,:,k).^2))));
                sx = sx - sum(sum(dudsx.*((i3./u(:,:,k))-1)))/(sum(sum(d2udsx2.*((i3./u(:,:,k))-1) - dudsx.^2.*i3./(u(:,:,k).^2))));
                sy = sy - sum(sum(dudsy.*((i3./u(:,:,k))-1)))/(sum(sum(d2udsy2.*((i3./u(:,:,k))-1) - dudsy.^2.*i3./(u(:,:,k).^2))));
                
                
            end
            xlap(k+1,l) = xf;
            ylap(k+1,l) = yf;
            zlap(k+1,l) = zf;
            nlap(k+1,l) = N;
            bglap(k+1,l) = offs;
            flagy(l) = flag;
            p(l) = sum(sum(i3.*real(log(u(:,:,end)))-u(:,:,end)-i3.*real(log(i3))+i3));
            
            % end
            
            xfa(l,op) = xf;
            yfa(l,op) = yf;
            a0(l,op) = N;
            r0(l,op) = (sx*sy)^0.5;
            zfa(l,op) = zf;
            off0(l,op) = offs;
            xf0(l,op) = x0true;
            yf0(l,op) = y0true;
            zf0(l,op) = z0true;
            N0(l,op) = ntrue;
            off0(l,op) = B;
        end
        t(op) = toc;
%         ajn_wait(t, op, numel(zs))
 end
ind = abs(zfa) < 1;
histogram((zfa(ind)-zf0(ind)))
std(zfa(ind))
figure
plot(zfa)
ylim([-1.5, 1.5])
%     [xmf, xmc, ymf, ymc, zmf, zmc, Npm, Ncm, omff, ofmfc, lmv] = chain_d_loc13(single(il), single(zcurve), 100, single(0));    
%     disp(num2str([xmf,ymf,zmf,Npm,omff,lmv]));
%     Zfin{op} = (zlap(end,:));
%     Zmfin{op} = (zmf);
%  end
%  
% for i =1:numel(Zfin)
%     dzs = Zfin{i};
%     dzms = Zmfin{i};
%     ind = abs(dzs) < 1;
%     ind1 = abs(dzms) <1;
%     meanz(i) = mean(dzs(ind));
%     mzms(i) = mean(dzms(ind1));
%     stdz(i) = std(dzs(ind));
%     clear dzs
% end
% plot(zs,meanz)
% hold on
% plot(zs,mzms,'.');
% legend('CPU','GPU')
% xlabel('Simulated Axial Position [um]')
% ylabel('Fitted Axial Position [um]')
% title('Comparison between CPU and GPU calculation')
% close (w1)
% xf = xf;
% yf = yf;
% a0 = N;
% r0 = sx;
% off0 = sy;
% rf = (xf.^2+yf.^2).^0.5;
% hist(rf*q*1000,1:2:80);
% drawnow
% % end
% imagesc(u*1000);
% subplot(1,2,1);imagesc(i2);
% subplot(1,2,2);imagesc(u(:,:,l)*1000000);
% axis image
% colormap('gray');
% plot(1:60,xf.*q)
% % numel(find(fittime==101));
% imagesc(i2(:,:,1));
% axis image
% colormap('gray')
% hold on
% plot(xfa+rbox+1, yfa+rbox+1, '.b');
% plot(x0true+rbox+1,y0true+rbox+1,'.r');
% title('PSF with blue localizations and red source')
% figure
% plot(1:k+1,zlap);
% title('Convergence of fitting parameter')
% xlabel('Iteration')
% ylabel('Value')
% figure
% h = histogram(zfa(:,logical(1-flagy)));
% vals = h.Values;
% hold on
% plot([z0true, z0true],[0, max(vals)],'r');
% hold off