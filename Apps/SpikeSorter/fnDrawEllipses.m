function ahHandles = fnDrawEllipses(hAxes,a2fMu,a3fCov,a2fColors,iLineWidth,afRangeX,afRangeY)
iNumSamples = size(a2fMu,2);
afX = a2fMu(1,:);
afY = a2fMu(2,:);
afA = zeros(1,iNumSamples);
afB = zeros(1,iNumSamples);
afTheta = zeros(1,iNumSamples);
for k=1:iNumSamples
    if isnan(afX(k))
        afA(k) = NaN;
        afB(k) = NaN;
        afTheta(k) = NaN;
    else
        [V,E]=eig(a3fCov(:,:,k));
        sqrtS = sqrt((E([1,4])));
        [fDummy, iIndex] = max(sqrtS);
        afA(k) = 2*max(sqrtS);
        afB(k) = 2*min(sqrtS);
        afTheta(k) = atan2(-V(2,iIndex),V(1,iIndex));
    end
    
end;
afTheta(afTheta < 0) = afTheta(afTheta < 0) + 2*pi;
N = 60; 

%fTheta = fTheta + pi/2;
afAlpha = linspace(0,2*pi,N);%2*pi*[0:N]/N;
ahHandles = zeros(1,iNumSamples);
warning off
for k=1:iNumSamples
    apt2f = [afA(k) * cos(afAlpha); afB(k) * sin(afAlpha)];
    R = [ cos(afTheta(k)), sin(afTheta(k));
        -sin(afTheta(k)), cos(afTheta(k))];
    apt2fFinal = R*apt2f + repmat([afX(k);afY(k)],1,N);
    ahHandles(k) = plot(hAxes,min(afRangeX(end),max(afRangeX(1),apt2fFinal(1,:))),...
                              min(afRangeY(end),max(afRangeY(1),apt2fFinal(2,:))),...
                              'Color', a2fColors(k,:), 'LineWidth', iLineWidth); 
end
warning on