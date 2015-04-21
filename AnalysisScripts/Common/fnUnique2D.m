function [afUniqueX, afUniqueY]=fnUnique2D(afX,afY)
% Extends unique to 2D arrays, or correlated data (X,Y).

% afX  = [1,2,2,4,5,1,2,4];
% afY =  [4,2,5,6,4,6,5,1];
    

xedges = unique(afX);
yedges = unique(afY);

[xn, xbin] = histc(afX,xedges);
[yn, ybin] = histc(afY,yedges);

xbin(find(xbin == 0)) = 1;
ybin(find(ybin == 0)) = 1;

xnbin = length(xedges);
ynbin = length(yedges);

if xnbin >= ynbin
    xy = ybin*(xnbin) + xbin;
      indexshift =  xnbin; 
else
    xy = xbin*(ynbin) + ybin;
      indexshift =  ynbin; 
end

[xyuni, ii,jj] = unique(xy);
afUniqueX=afX(ii);
afUniqueY = afY(ii);

return;

