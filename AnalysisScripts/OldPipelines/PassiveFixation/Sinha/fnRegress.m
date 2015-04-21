function [afOptimalWeights, afResiduals, fExplainedVariance,fExplainedVarianceAdjusted,afPred,abSignificantRegressors] = fnRegress(a2fX, afResponses)
a2fX1 = [ones(size(a2fX,1),1),a2fX];
fAlpha = 0.01;
[afOptimalWeights,bint,afResiduals,rint,stats]= regress(afResponses(:),a2fX1,fAlpha);
afPred = a2fX1*afOptimalWeights;
fExplainedVariance = stats(1);
p=rank(a2fX);
n=size(a2fX,1);
%
fExplainedVarianceAdjusted = 1-(1-fExplainedVariance)*(n-1)/(n-p-1); % = variance explained (adjusted R2)
%
% p-value ?
abSignificantRegressors = (bint(2:end,1) > 0 & bint(2:end,2) > 0) | (bint(2:end,1) < 0 & bint(2:end,2) < 0);
return;
% The exaplined variance is Rsqr