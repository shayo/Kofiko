function [Mue, Kappa] = fnVonMisesFit(afAngles)
% Estimates the von Mises distribution
N=length(afAngles);
Z=exp(1i*afAngles);
Zbar = mean(Z);
Mue = angle(Zbar);
Rsqr = Zbar*Zbar';
Rsqr_unbiased = N/(N-1) * (Rsqr - 1/N);

R = sqrt(Rsqr_unbiased);

% Binary search
fLower = 0;
fUpper = 1000;
fAccuracy = 1;
while fAccuracy > 1e-5
    afKappa = linspace(fLower,fUpper,10000);
    afBessel = besseli(1,afKappa)./besseli(0,afKappa);
    [fAccuracy,iIndex]=min(abs(afBessel-R));
    Kappa = afKappa(iIndex);
    fLower = Kappa*0.9;
    fUpper = Kappa*1.1;
end

% figure(11);
% clf;
% [afHist,afCent]=hist(afAngles,30);
% plot(afCent,afHist/sum(afHist));
% hold on;
% afX = linspace(-pi,pi,1000);
% 
% I0 = besseli(0,Kappa);
% afY = 1/(2*pi*I0)* exp(Kappa * cos(afX-Mue));
% 
% plot(afX,afY/sum(afY),'r');

return;
