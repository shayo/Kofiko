function afYs = fnMyMonotonicInterp1(afX, afY, afXs)
% Super fast linear interpolation..... assuming that afX is monotonic
% increasing (!)

iNumX = length(afX);
aiMonotonic = 1:iNumX;
afDiff = diff(afX);
[ignore, aiInd] = histc(afXs,afX);
aiInd(afXs<afX(1) | ~isfinite(afXs)) = 1;
aiInd(afXs>=afX(iNumX)) = iNumX-1;

afRelative = (afXs - afX(aiInd))./afDiff(aiInd);
afYs  = afY(aiInd) + afRelative.*(afY(aiInd+1)-afY(aiInd));
afYs(aiMonotonic(afXs<afX(1) | afXs>afX(iNumX))) = NaN;

return;

% afX = sort(rand(1,100));
% afY = rand(1,100);
% afXs = linspace(min(afX),max(afX),10000);
% 
% afYs = fnMyMonotonicInterp1(afX, afY, afXs)
% afYs1 = interp1(afX, afY, afXs)