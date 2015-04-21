function [afResFace, afResNonFace,afResFaceMax, afResNonFaceMax,dPrime,fPerecentCorrect,afStdFace,afStdNonFace] =...
    fnFiringRateNumberOfCorrectRatios(strctUnit, aiNumCorrectSinhaInFaces,aiNumCorrectSinhaInNonFaces,bNorm,bSubtractBaseline)
afNumRatio = [aiNumCorrectSinhaInFaces; aiNumCorrectSinhaInNonFaces];
abFace = zeros(length(afNumRatio),1) > 0;
abFace(1:length(aiNumCorrectSinhaInFaces)) = 1;

afResPos =strctUnit.m_afAvgStimulusResponseMinusBaseline(1:207);
afResPos = afResPos(~isnan(afResPos));

afResNeg =strctUnit.m_afAvgStimulusResponseMinusBaseline(208:411);
afResNeg = afResNeg(~isnan(afResNeg));

fDeno = sqrt( (std(afResPos).^2+std(afResNeg).^2)/2);
dPrime = abs(mean(afResPos) - mean(afResNeg)) / (fDeno+eps);
fPerecentCorrect = normcdf(dPrime / sqrt(2)) * 100;

afResFace    = zeros(1,13);
afResNonFace = zeros(1,13);
afResFaceMax = zeros(1,13);
afResNonFaceMax = zeros(1,13);

for k=1:13
        
        
        
    aiInd = find(afNumRatio == k-1 & abFace);
    if ~bSubtractBaseline
        [afResFace(k),T,afStdFace(k)] =  fnMyMean(strctUnit.m_afAvgFirintRate_Stimulus(aiInd));
        afResFaceMax(k) = fnMyMax(strctUnit.m_afAvgFirintRate_Stimulus(aiInd));
        aiInd = find(afNumRatio == k-1 & ~abFace);
        [afResNonFace(k),T, afStdNonFace(k)]  = fnMyMean(strctUnit.m_afAvgFirintRate_Stimulus(aiInd));
        afResNonFaceMax(k) = fnMyMax(strctUnit.m_afAvgFirintRate_Stimulus(aiInd));
    else
        [afResFace(k),T,afStdFace(k)] = fnMyMean(strctUnit.m_afAvgStimulusResponseMinusBaseline(aiInd));
        afResFaceMax(k) = fnMyMax(strctUnit.m_afAvgStimulusResponseMinusBaseline(aiInd));
        aiInd = find(afNumRatio == k-1 & ~abFace);
        [afResNonFace(k),T, afStdNonFace(k)] = fnMyMean(strctUnit.m_afAvgStimulusResponseMinusBaseline(aiInd));
        afResNonFaceMax(k) = fnMyMax(strctUnit.m_afAvgStimulusResponseMinusBaseline(aiInd));
    end
end
if bNorm
%fNormalizing = max(strctUnit.m_afAvgStimulusResponseMinusBaseline(:));
fNormalizing = max([afResFace, afResNonFace]);
afResFace = afResFace./ fNormalizing;
afStdFace = afStdFace ./ fNormalizing;
afResNonFace = afResNonFace./ fNormalizing;
afStdNonFace = afStdNonFace ./ fNormalizing;
fNormalizing = max([afResFaceMax, afResNonFaceMax]);
afResFaceMax = afResFaceMax /fNormalizing;
afResNonFaceMax = afResNonFaceMax /fNormalizing;
end
return;

function A = fnMyMax(B)
if isempty(B)
    A = NaN;
else
    A = max(B);
end;