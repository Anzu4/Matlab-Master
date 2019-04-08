% Trajec Viewer
% close all
% xf_all = ncoords(:,1);
% yf_all = ncoords(:,2);
% zf_all = ncoords(:,3);
% for lk = 1:60
lk = 197;
zf_all = func_build_ramp(ncoords(:,3)*q,framenumber,-30,3,lk)/q;
scl = 1;
xf_all = xf_fixed;
yf_all = yf_fixed;
% zf_all = ncoords(:,3);

% s = scatter3(xf_all*q,yf_all*q,zf_all*q,-scl*llv./fits(:,3));

plot3(q*xf_all,q*yf_all,q*zf_all,'.');
axis equal
hold on
dx = [];
dy = [];
dz = [];
n = [];
zd = 0;
for i = 1:numel(trajec)
    ind = trajec(i).t;
    nums(i) = numel(ind);
    rgb = get_color(numel(ind));
    dx = [dx;q*(xf_all(ind)-mean(xf_all(ind)))];
    dy = [dy;q*(yf_all(ind)-mean(yf_all(ind)))];
    dz = [dz;q*(zf_all(ind)-mean(zf_all(ind)))];
%     zd = zd + sum(zf_all(ind));
%     N{i} = fits(ind,3);
    n = [n;fits(ind,3) - mean(fits(ind,3))];
    plot3(q*xf_all(ind),q*yf_all(ind),q*zf_all(ind),'LineWidth',1);
%     si = scatter3(q*xf_all(ind),q*yf_all(ind),q*zf_all(ind),-scl*llv(ind)./fits(ind,3),rgb);
%     si.MarkerFaceColor = si.MarkerEdgeColor;
%     plot3(q*(xf_all(ind)-xf_all(ind(1))),q*(yf_all(ind)-yf_all(ind(1))),i+q*(zf_all(ind)-zf_all(ind(1))))
    hold on
end
hold off
drawnow
% axis equal
% vals(lk) = mean(abs(dz));
% end
% for i = 1:numel(N)
%     plot(N{i})
%     hold on
% end
