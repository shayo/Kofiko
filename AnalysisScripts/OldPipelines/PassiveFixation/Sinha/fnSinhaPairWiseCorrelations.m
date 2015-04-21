function strctStat = fnSinhaPairWiseCorrelations(strctUnit, a3fContrast,a2iPerm,strctConfig)
iStimulusOffset = 96;
iNumParts = 11;
iNumIntensities = 11;
a2fPartIntensityResponse = NaN*ones(iNumParts, iNumIntensities);
for iPartIter=1:iNumParts
    for iIntensityIter=1:iNumIntensities
        aiInd = find(a2iPerm(:,iPartIter) == iIntensityIter);
        if ~isempty(aiInd)
            a2fPartIntensityResponse(iPartIter, iIntensityIter) = mean(strctUnit.m_afAvgFirintRate_Stimulus(iStimulusOffset+aiInd));
        end
    end
end;

if sum(isnan(a3fContrast(:)))/prod(size(a3fContrast)) > 0.9
    strctStat = [];
    return;
end
    

a3fContrast = fnAugmentWithNearestNeighbor(a3fContrast);
a2iPairs = nchoosek(1:11,2);
iNumPairs = size(a2iPairs,1);
afCorrSum = zeros(1,iNumPairs);
afCorrMax = zeros(1,iNumPairs);
afCorrMult = zeros(1,iNumPairs);
a2fDiffResponse = ones(iNumPairs,21)*NaN;
for iPairIter=1:iNumPairs
    iPartA = a2iPairs(iPairIter,1);
    iPartB = a2iPairs(iPairIter,2);
    
    [a2fXX,a2fYY] = meshgrid(a2fPartIntensityResponse(iPartB,:),a2fPartIntensityResponse(iPartA,:));
    a2fSumModel = a2fXX+a2fYY;
    a2fMaxModel = max(a2fXX,a2fYY);
    a2fMultModel = a2fXX.*a2fYY;
    a2fZ = a3fContrast(:,:,iPairIter);
    afCorrSum(iPairIter) = corr(a2fZ(:),a2fSumModel(:));
    afCorrMax(iPairIter) = corr(a2fZ(:),a2fMaxModel(:));
    afCorrMult(iPairIter) = corr(a2fZ(:),a2fMultModel(:));

    
    for iIntensityDiff = -10:10
        aiInd = find( double(a2iPerm(:,iPartA)) -double(a2iPerm(:,iPartB)) == iIntensityDiff );
        if ~isempty(aiInd)
            a2fDiffResponse(iPairIter,iIntensityDiff+11) =  mean(strctUnit.m_afAvgFirintRate_Stimulus(iStimulusOffset+aiInd));
        end
    end
    a2fDiffResponse(iPairIter,11) = mean(strctUnit.m_afAvgFirintRate_Stimulus( 534:544));
    
end
strctStat.m_afCorrSum = afCorrSum;
strctStat.m_afCorrMax = afCorrMax;
strctStat.m_afCorrMult = afCorrMult;
strctStat.m_a2fDiffResponse = a2fDiffResponse;

%%

aiPeriStimulusRangeMS = strctConfig.m_strctParams.m_iBeforeMS:strctConfig.m_strctParams.m_iAfterMS;
iStartAvg = find(aiPeriStimulusRangeMS>=strctConfig.m_strctParams.m_iStartAvgMS,1,'first');
iEndAvg = find(aiPeriStimulusRangeMS>=strctConfig.m_strctParams.m_iEndAvgMS,1,'first');

iSmoothMS = 15;
afSmoothingKernelMS = fspecial('gaussian',[1 7*iSmoothMS],iSmoothMS);

a2fSmoothRasterHz = 1e3*conv2(double(strctUnit.m_a2bRaster_Valid),afSmoothingKernelMS ,'same');


aiInd = find( (strctUnit.m_aiStimulusIndexValid >= 97 & strctUnit.m_aiStimulusIndexValid <= 528) | ...
              (strctUnit.m_aiStimulusIndexValid >= 534 & strctUnit.m_aiStimulusIndexValid <= 544) );

a2fRasterCropped = a2fSmoothRasterHz(aiInd,:);
aiStimuliIndex = strctUnit.m_aiStimulusIndexValid(aiInd);
aiStimuliIndex(aiStimuliIndex >= 97 & aiStimuliIndex <= 528) = aiStimuliIndex(aiStimuliIndex >= 97 & aiStimuliIndex <= 528) - 96; 
aiStimuliIndex(aiStimuliIndex >= 534 & aiStimuliIndex <= 544) = aiStimuliIndex(aiStimuliIndex >= 534 & aiStimuliIndex <= 544) - 533 + 432; 

afFiringRate = mean(a2fRasterCropped(:,iStartAvg:iEndAvg),2);

strctTmp = load('SinhaV2.mat');
a2iPerm = double(strctTmp.a2iAllPerm);
% append last ones
for k=1:11
    a2iPerm(432+k,:) = k;
end

a2iIntensityLevels = a2iPerm(aiStimuliIndex,:);

afFiringRateZeroMean = afFiringRate-mean(afFiringRate);

strctStat.m_afOptW = a2iIntensityLevels \ afFiringRateZeroMean;
afPredFiring = a2iIntensityLevels*strctStat.m_afOptW;
afResiduals = afFiringRateZeroMean-afPredFiring;


afSStot = sum(afFiringRateZeroMean.^2);
afSSreg = sum(afPredFiring.^2);
afSSerr = sum(afResiduals.^2);

strctStat.m_fUnexplainedVariance = afSSreg/afSStot * 100;
strctStat.m_fVarianceExplained = 100-strctStat.m_fUnexplainedVariance;

return;