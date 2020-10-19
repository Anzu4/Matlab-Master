function show_overlaid_data(cdata)
    load('C:\Users\andre\Documents\GitHub\Matlab-Master\2-Channel Codes\2_color_calibration.mat');
    s= scatter3(cdata.red.xf,cdata.red.yf,-cdata.red.zf_raw,5,'filled');
    vector = xyz_feature(cdata.orange.xf,cdata.orange.yf, cdata.orange.zf);
xfo = o2rx.'*vector.';
yfo = o2ry.'*vector.';
hold on
scatter3(xfo,yfo,-cdata.orange.zf_raw,5,'filled')
hold off
legend('Glut4','vGlut1')
axis equal
xlim([3.6 23.6])
ylim([2.8 22.8])
end