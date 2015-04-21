function strctUnit = fnFOB_v6_PassiveFixationAnalysis(strctUnit, strctKofiko, strctInterval,strctConfig,aiTrialIndices)
% Add the Face Selectivity Index Attribute 
aiFaceInd = [1:16,97:105];
aiNonFaceInd = [17:96];
fFaceRes = nanmean(strctUnit.m_afAvgFirintRate_Stimulus(aiFaceInd));
fNonFaceRes = nanmean(strctUnit.m_afAvgFirintRate_Stimulus(aiNonFaceInd));
fFaceSelectivityIndex =  (fFaceRes - fNonFaceRes) / (fFaceRes + fNonFaceRes+eps);

strctUnit = fnAddAttribute(strctUnit,'FSI',sprintf('%.2f',fFaceSelectivityIndex),fFaceSelectivityIndex);
%%

% Proper d' is :Z(hit rate)-Z(false alarm rate)
% since we don't know the optimal threshold, we can test for all possible
% ones and take the maximal (!)
%norminv(0.8)5
    
afResPos =strctUnit.m_afAvgStimulusResponseMinusBaseline(aiFaceInd);
afResPos = afResPos(~isnan(afResPos));
    
afResNeg =strctUnit.m_afAvgStimulusResponseMinusBaseline(aiNonFaceInd);
afResNeg = afResNeg(~isnan(afResNeg));
    
fdPrimeBaselineSub = fnDPrimeROC(afResPos, afResNeg);

strctUnit = fnAddAttribute(strctUnit,'DprimeBS',sprintf('%.2f',fdPrimeBaselineSub),fdPrimeBaselineSub);

afResPos =strctUnit.m_afAvgFirintRate_Stimulus(aiFaceInd);
afResPos = afResPos(~isnan(afResPos));
    
afResNeg =strctUnit.m_afAvgFirintRate_Stimulus(aiNonFaceInd);
afResNeg = afResNeg(~isnan(afResNeg));
    
fdPrime = fnDPrimeROC(afResPos, afResNeg);
    
strctUnit = fnAddAttribute(strctUnit,'Dprime',sprintf('%.2f',fdPrime),fdPrime);

return;

