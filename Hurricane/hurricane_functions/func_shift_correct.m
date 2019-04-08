
function z_out = func_shift_correct(zin,frames,r)

% Cycle over offset to minimize standard deviation of height corrected
% positions. THis is an analytical equivalent of a sum of least squares
% calculation.
load('C:\Users\AJN Lab\Dropbox\Data\4-3-19 calibration\Analysis\dz10_r1_template.mat');
fnumber = frames - offset;
cyc = numel(y)-1;
y = r*y; % this is an approximation we make away from truth. We can't measure the 2um 20nm scan or higher as they are outside our dynamic range

for i = 1:numel(zin)
    correc(i) = y(mod(fnumber(i),cyc)+1);
    z_out(i) = zin(i) - correc(i);
end
