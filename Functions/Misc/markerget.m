function output = markerget(str,marker)
output = [];
ind1 = strfind(str(1:end-4),marker);
ind1 = ind1(end);
ind2 = -1 + ind1 + strfind(str(ind1:end),'_');
if isempty(ind2) == 1
    ind2 = numel(str)+1-4;
end
output = str(ind1+1:ind2(1)-1);
output = str2num(output);

