function i1 = func_3D_hist(coord,bin)
xf = coord(:,1);
yf = coord(:,2);
zf = coord(:,3);

sbin = bin/1000;
xl = [min(xf), max(xf)];
yl = [min(yf), max(yf)];
zl = [min(zf), max(zf)];
m = round(diff(yl)/sbin)+1;
n = round(diff(xl)/sbin)+1;
o = round(diff(zl)/sbin)+1;
i1 = zeros(m,n,o); % Create 3D histogram

% Populate the 3D Histogram
for i = 1:numel(xf)
    n = floor((xf(i) - min(xf))/sbin)+1;
    m = floor((yf(i) - min(yf))/sbin)+1;
    o = floor((zf(i) - min(zf))/sbin)+1;
    i1(m,n,o) = i1(m,n,o) +1;
end

 

