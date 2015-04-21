function [xleft, xright]=fnOptimalThreshold(fMue1, fSig1, fMue2, fSig2)

% fMue1 = 2;
% fSig1 = 3;
% fMue2 = 9;
% fSig2 = 13;
% 
% afX = linspace(-15,20,1000);
% afY1 = normpdf(afX,fMue1,fSig1);
% afY2 = normpdf(afX,fMue2,fSig2);

A = fSig2^2-fSig1^2;
B = 2*fMue2*fSig1^2 - 2*fMue1*fSig2^2;
C = fMue1^2*fSig2^2-fMue2^2*fSig1^2-2*fSig1^2*fSig2^2*log(fSig2/fSig1);

D = sqrt(B^2-4*A*C);

if A > 0
    xright = (-B + D)/ (2*A);
    xleft = (-B - D)/ (2*A);
    % Interval is xleft..xright
elseif A < 0
    xleft = (-B + D)/ (2*A);
    xright = (-B - D)/ (2*A);
    % Interval is [-inf..xleft, xright..inf]
else
    % A == 0
    xleft = -C/B;
    xright = xleft;
    % Interval is [-inf .. xleft]
    
end

return;


% 
% figure(1);
% clf;
% plot(afX,afY1,afX,afY2);
% hold on;
% plot([xleft xleft],[0 0.2],'r');
% plot([xright xright],[0 0.2],'r');
