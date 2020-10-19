function plot_2D_overlay(cdata)
% Function to make a scatter plot showing the overlay of localization data
% between two channels
load('C:\Users\andre\Documents\GitHub\Matlab-Master\2-Channel Codes\2_color_calibration.mat')
scatter3(cdata.red.xf,cdata.red.yf,-cdata.red.zf_raw,4,repmat([1 0 0],numel(cdata.red.xf),1),'filled')
vector = xyz_feature(cdata.orange.xf,cdata.orange.yf, cdata.orange.zf);
xfo = o2rx.'*vector.';
yfo = o2ry.'*vector.';
hold on
scatter3(xfo,yfo,-cdata.orange.zf_raw,4,repmat([0 0 1],numel(xfo),1),'filled')
hold off

axis equal

end