%
% PAL_SDT_MAFC_DPtoPCpartFunc
%   
%   Internal function
%
% Introduced: Palamedes version 1.0.0 (FK)

function Y=PAL_SDT_MAFC_DPtoPCpartFunc(X,dP,M)

N=normpdf(X-dP);
P=PAL_ZtoP(X);
Y=N.*P.^(M-1);