% Trajec Viewer
% close all
% xf_all = ncoords(:,1);
% yf_all = ncoords(:,2);
% zf_all = ncoords(:,3);
scl = 1;
xf_all = xf_fixed*q;
yf_all = yf_fixed*q;
zf_all = dcoords*q;

% s = scatter3(xf_all*q,yf_all*q,zf_all*q,-scl*llv./fits(:,3));

% plot3(q*xf_all,q*yf_all,q*zf_all,'.');
dx = [];
dy = [];
dz = [];
axis equal
hold on
for i = 1:numel(trajec)
    ind = trajec(i).t;
    rgb = get_color(numel(ind));
    dx = [dx;(xf_all(ind)-mean(xf_all(ind)))];
    dy = [dy;(yf_all(ind)-mean(yf_all(ind)))];
    dz = [dz;(zf_all(ind)-mean(zf_all(ind)))];
%     plot3(q*xf_all(ind),q*yf_all(ind),q*zf_all(ind));
%     si = scatter3(q*xf_all(ind),q*yf_all(ind),q*zf_all(ind),-scl*llv(ind)./fits(ind,3),rgb);
%     si.MarkerFaceColor = si.MarkerEdgeColor;
end
hold off
axis equal

