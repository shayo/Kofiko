function strctUnit = fnSinhaAnalysis(strctUnit,iStimOffset,iCatOffset,a2iPerm,acPartNames,a2iCorrectPairALargerB,strctConfig)
% What type of analysis do we want here?


acPlot0  = fnComputeFaceSelecitivyIndex(strctUnit);

% 1. Part- Intensity plot, Part-Part intensity plot

acPlot1 = fnGeneratePartIntensityPlot(a2iPerm, strctUnit,iCatOffset, iStimOffset,acPartNames,strctConfig);

% 2. Contrast polarity plot, difference in firing rate plot
fPThreshold = 1e-5;
acPlot2 = fnGenerateContrastPolarityPlot(a2iPerm, strctUnit,iCatOffset, iStimOffset, fPThreshold);

% 3. Number of correct/incorrect ratios according to sinha plot
acPlot3 = fnGenerateCorrectRatioPlot(a2iPerm, strctUnit, iStimOffset,a2iCorrectPairALargerB);


% 4. Generate pair-wise contrast tuning curves
[acPlot4,a3fContrast] = fnGeneratePairwiseContrastPlots(a2iPerm, strctUnit, iStimOffset);

% 5. Generate significance for part based tuning curves...

%[acPlot6] = fnSeparabilityComparison(a2iPerm, strctUnit, iStimOffset,a3fContrast);
%[acPlot7] = fnModelComparison2(a2iPerm, strctUnit, iStimOffset,a3fContrast,a2fPartIntensityResponse);


aiUniqueSizes = unique(strctUnit.m_strctStimulusParams.m_afStimulusSizePix);
if length(aiUniqueSizes) == 2 && all(aiUniqueSizes == [64, 128])
    acPlot7 = fnAnalyzeSizeInvariance(strctUnit,iStimOffset,iCatOffset,a2iPerm,acPartNames,a2iCorrectPairALargerB,strctConfig);
else
    acPlot7 = [];
end
acPlot5 = fnSinhaAnova(strctUnit,strctConfig,a2iPerm);
acPlot6 = fnSinhaPairWiseCorrelations(strctUnit, a3fContrast,a2iPerm,strctConfig);


strctUnit.m_acSinhaPlots = {acPlot0,acPlot1,acPlot2,acPlot3,acPlot4,acPlot5,acPlot6,acPlot7};


return;

function strctStat = fnAnalyzeSizeInvariance(strctUnit,iStimOffset,iCatOffset,a2iPerm,acPartNames,a2iCorrectPairALargerB,strctConfig)
% Assume two sizes: 64 and 128

iNumStim = 549;
afResponse = strctUnit.m_afStimulusResponseMinusBaseline  + strctUnit.m_afBaselineRes;
% %afResponse = strctUnit.m_afStimulusResponseMinusBaseline;
% 
% 
% iNumParts = 11;
% iNumIntensities = 11;
% a2fPartIntensityResponse_128 = zeros(iNumParts, iNumIntensities);
% a2fPartIntensityResponse_64 = zeros(iNumParts, iNumIntensities);
% iStimulusOffset=96;
% % compute the intensity curve
% for iPartIter=1:iNumParts
%     for iIntensityIter=1:iNumIntensities
%         aiInd = find(a2iPerm(:,iPartIter) == iIntensityIter);
%         if ~isempty(aiInd)
%             
%             aiInd128 = find(ismember(strctUnit.m_aiStimulusIndexValid, aiInd+iStimulusOffset) &  strctUnit.m_strctStimulusParams.m_afStimulusSizePix == 128 );
%             aiInd64 = find(ismember(strctUnit.m_aiStimulusIndexValid, aiInd+iStimulusOffset) &  strctUnit.m_strctStimulusParams.m_afStimulusSizePix == 64 );
%             
%             a2fPartIntensityResponse_128(iPartIter, iIntensityIter) = fnMyMean(afResponse(aiInd128));
%             a2fPartIntensityResponse_64(iPartIter, iIntensityIter) = fnMyMean(afResponse(aiInd64));
%             
%             
%         end
%     end
% end
% 
% a2fPartIntensityResponse_128 = a2fPartIntensityResponse_128 / max(a2fPartIntensityResponse_128(:));
% a2fPartIntensityResponse_64 = a2fPartIntensityResponse_64 / max(a2fPartIntensityResponse_64(:));
% figure;
% subplot(1,2,1);
% plot(a2fPartIntensityResponse_128')
% subplot(1,2,2);
% plot(a2fPartIntensityResponse_64')
strctStat.m_afAvgRes128 = zeros(1,iNumStim);
strctStat.m_afAvgRes64 = zeros(1,iNumStim);
for iStimIter=1:iNumStim
    strctStat.m_afAvgRes128(iStimIter) = fnMyMean(afResponse(ismember(strctUnit.m_aiStimulusIndexValid, iStimIter) &  strctUnit.m_strctStimulusParams.m_afStimulusSizePix == 128 ));
    strctStat.m_afAvgRes64(iStimIter) = fnMyMean(afResponse(ismember(strctUnit.m_aiStimulusIndexValid, iStimIter) &  strctUnit.m_strctStimulusParams.m_afStimulusSizePix == 64 ));
end




iNumRatios = nchoosek(11,2);
a2iPairs= nchoosek(1:11,2);
strctStat.m_afSig128 = zeros(1,iNumRatios);
strctStat.m_afSig64 = zeros(1,iNumRatios);
strctStat.m_a2fAvgRes128 = zeros(2,iNumRatios);
strctStat.m_a2fAvgRes64 = zeros(2,iNumRatios);
for iPairIter=1:iNumRatios
    iPartA = a2iPairs(iPairIter,1);
    iPartB = a2iPairs(iPairIter,2);
    
    % Find all stimuli for which A > B
    aiALargerB = find(a2iPerm(:,iPartA) > a2iPerm(:,iPartB));
    aiASmallerB = find(a2iPerm(:,iPartA) < a2iPerm(:,iPartB));
    
    aiInd_A_Larger_B_128 = find(ismember(strctUnit.m_aiStimulusIndexValid, aiALargerB + iStimOffset) & strctUnit.m_strctStimulusParams.m_afStimulusSizePix == 128 );
    aiInd_A_Smaller_B_128 = find(ismember(strctUnit.m_aiStimulusIndexValid, aiASmallerB + iStimOffset) & strctUnit.m_strctStimulusParams.m_afStimulusSizePix == 128 );
    
    aiInd_A_Larger_B_64 = find(ismember(strctUnit.m_aiStimulusIndexValid, aiALargerB + iStimOffset) & strctUnit.m_strctStimulusParams.m_afStimulusSizePix == 64 );
    aiInd_A_Smaller_B_64 = find(ismember(strctUnit.m_aiStimulusIndexValid, aiASmallerB + iStimOffset) & strctUnit.m_strctStimulusParams.m_afStimulusSizePix == 64 );
    
    % Is this pair significant ?
    afSamplesCat1_128 = afResponse(aiInd_A_Larger_B_128);
    afSamplesCat2_128 = afResponse(aiInd_A_Smaller_B_128);
    strctStat.m_afSig128(iPairIter) = ranksum(afSamplesCat1_128,afSamplesCat2_128);

    afSamplesCat1_64 = afResponse(aiInd_A_Larger_B_64);
    afSamplesCat2_64 = afResponse(aiInd_A_Smaller_B_64);
    strctStat.m_afSig64(iPairIter) = ranksum(afSamplesCat1_64,afSamplesCat2_64);
    
    
    strctStat.m_a2fAvgRes128(:,iPairIter) = [fnMyMean(afSamplesCat1_128);fnMyMean(afSamplesCat2_128)];
    strctStat.m_a2fAvgRes64(:,iPairIter) = [fnMyMean(afSamplesCat1_64);fnMyMean(afSamplesCat2_64)];
end


return;


function [acPlot0]  = fnComputeFaceSelecitivyIndex(strctUnit)
fMaximalResponseForSinha = max(strctUnit.m_afAvgStimulusResponseMinusBaseline(97:end)) / max(strctUnit.m_afAvgStimulusResponseMinusBaseline);
fMaximalResponseForFace = max(strctUnit.m_afAvgStimulusResponseMinusBaseline(1:16)) / max(strctUnit.m_afAvgStimulusResponseMinusBaseline);
fFaceRes = fnMyMean(strctUnit.m_afAvgStimulusResponseMinusBaseline(1:16));
fNonFaceRes = fnMyMean(strctUnit.m_afAvgStimulusResponseMinusBaseline(17:96));

fFaceRes1 = fnMyMean(strctUnit.m_afAvgFirintRate_Stimulus(1:16));
fNonFaceRes1 = fnMyMean(strctUnit.m_afAvgFirintRate_Stimulus(17:96));

acPlot0.m_fFaceSelectivityIndex =  (fFaceRes - fNonFaceRes) / (fFaceRes + fNonFaceRes+eps);
acPlot0.m_fFaceSelectivityIndexBounded =  (fFaceRes1 - fNonFaceRes1) / (fFaceRes1 + fNonFaceRes1+eps);
acPlot0.m_fRatio = fMaximalResponseForSinha/fMaximalResponseForFace;

return;

% function [acPlot,a2fPartIntensityResponse] = fnSeparabilityComparison(a2iPerm, strctUnit, iStimulusOffset,a3fContrast)
% % This function tests the mult, add and max models
% iNumParts = 11;
% iNumIntensities = 11;
% a2fPartIntensityResponse = NaN*ones(iNumParts, iNumIntensities);
% for iPartIter=1:iNumParts
%     for iIntensityIter=1:iNumIntensities
%         aiInd = find(a2iPerm(:,iPartIter) == iIntensityIter);
%         if ~isempty(aiInd)
%             a2fPartIntensityResponse(iPartIter, iIntensityIter) = mean(strctUnit.m_afAvgFirintRate_Stimulus(iStimulusOffset+aiInd));
%         end
%     end
% end
% 
% a3fContrast = fnAugmentWithNearestNeighbor(a3fContrast);
% a2iPartRatio = nchoosek(1:11,2);
% 
% 
% afCorrMult = zeros(1,55);
% afCorrAdd = zeros(1,55);
% afCorrMax = zeros(1,55);
% [X,Y]=meshgrid(1:iNumParts,1:iNumParts);
% afSVDSeparabilityIndex = zeros(1,55);
% a2fSingularValues = zeros(55,11);
% warning off
% for k=1:55
%     iPartA = a2iPartRatio(k,1);
%     iPartB = a2iPartRatio(k,2);
%     A = a3fContrast(:,:,k);
%     MultModel = a2fPartIntensityResponse(iPartA,:)' * a2fPartIntensityResponse(iPartB,:);
%     AddModel = a2fPartIntensityResponse(iPartA,Y) + a2fPartIntensityResponse(iPartB,X);
%     MaxModel = max(a2fPartIntensityResponse(iPartA,Y),a2fPartIntensityResponse(iPartB,X));
%     afCorrMult(k) = corr(A(:),MultModel(:));
%     afCorrAdd(k) = corr(A(:),AddModel(:));
%     afCorrMax(k) = corr(A(:),MaxModel(:));
%     
%     [U,S,V]=svd(a3fContrast(:,:,k));
%     afSingularValues = diag(S);
%     a2fSingularValues(k,:) = afSingularValues;
%     afSVDSeparabilityIndex(k) = afSingularValues(1)^2 / sum(afSingularValues.^2);
% end
% warning on
% acPlot.m_afCorrMult = afCorrMult;
% acPlot.m_afCorrAdd = afCorrAdd;
% acPlot.m_afCorrMax = afCorrMax;
% acPlot.m_afSVDSeparabilityIndex = afSVDSeparabilityIndex;
% acPlot.m_a2fSingularValues = a2fSingularValues;
% 
% return;


% function [acPlot] = fnModelComparison2(a2iPerm, strctUnit, iStimulusOffset,a3fContrast,a2fPartIntensityResponse)
% 
% 
% % Variance explained by a linear summation model
% iNumPerm = size(a2iPerm,1);
% iNumParts = 11;
% iNumIntensities = 11;
% a2fPredictedResponseComponents = zeros(iNumPerm, iNumParts);
% afRecordedAvgResponse = zeros(1,iNumPerm);
% for iStimulusIter=1:iNumPerm
%     afRecordedAvgResponse(iStimulusIter) = strctUnit.m_afAvgFirintRate_Stimulus(iStimulusOffset+iStimulusIter);
%     aiInd = sub2ind([iNumParts iNumIntensities], 1:iNumParts, double(a2iPerm(iStimulusIter,:)));
%     a2fPredictedResponseComponents(iStimulusIter,:) = a2fPartIntensityResponse(aiInd);
% end
% afOptimalWeights = a2fPredictedResponseComponents\afRecordedAvgResponse';
% 
% afPredictedResponses_LinearWeightedAddition = a2fPredictedResponseComponents * afOptimalWeights;
% 
% afPredictedResponses_LineardAddition = sum(a2fPredictedResponseComponents,2);
% 
% afPredictedResponses = afPredictedResponses_LinearWeightedAddition;
% 
% 
% % Chi-square test
% [h,p]= chi2gof(afRecordedAvgResponse-afPredictedResponses')
% 
% % Explained Variance ?
% SStot = sum( (afRecordedAvgResponse-mean(afRecordedAvgResponse)).^2);
% SSreg = sum( (afPredictedResponses-mean(afPredictedResponses)).^2);
% SSerr =   sum( (afRecordedAvgResponse-afPredictedResponses').^2);
% fCoefficientOfDetermination = 1 - SSerr/SStot
% 
% SSE = SSerr
% SST = SStot
% r2 = 1 - SSE/SST % betwen 0 ,, 1
% 
% rPearson = corr(afRecordedAvgResponse', afPredictedResponses); %sum( (afRecordedAvgResponse-mean(afRecordedAvgResponse)) .* (afPredictedResponses-mean(afPredictedResponses))') / ...
% %    ( (length(afPredictedResponses)-1) * std(afPredictedResponses) * std(afRecordedAvgResponse));
% fFractionOfVarianceUnexplained = 1- rPearson^2;
% fFractionOfVarianceExplained = rPearson^2;
% %
% %
% % figure(2);
% % clf;
% % plot(afRecordedAvgResponse);
% % hold on;
% % plot(afPredictedResponses,'r');
% 
% 
% acPlot = [];
% 
% return;

% function acPlot = fnSignificantContrastTuning(a2iPerm,strctUnit,iStimulusOffset)
% fSigLevel = 0.001;
% fPercentile = 100-fSigLevel;
% iNumShiftPredicators = 1000;
% fTimeSmoothingMS = 30;
% 
% iNumParts = 11;
% iNumIntensities = 11;
% 
% 
% fStartAvgMs = 50;
% fEndAvgMs = 200;
% 
% iStartAvg = find(strctUnit.m_aiPeriStimulusRangeMS >= fStartAvgMs,1,'first');
% iEndAvg = find(strctUnit.m_aiPeriStimulusRangeMS >= fEndAvgMs,1,'first');
% 
% a2fRasterSmooth = 1e3*conv2(double(strctUnit.m_a2bRaster_Valid), ones(1,fTimeSmoothingMS)/fTimeSmoothingMS,'same');
% 
% iNumValidStimuli = sum(strctUnit.m_aiStimulusIndexValid > iStimulusOffset);
% aiShiftPredicators = 1:iNumShiftPredicators;
% aiShiftPredicators = aiShiftPredicators( mod(aiShiftPredicators,iNumValidStimuli) > 0);
% iNumShiftPredicators = length(aiShiftPredicators);
% a3fIntensityResponseShiftPredicator = NaN*ones(iNumParts, iNumIntensities, iNumShiftPredicators);
% 
% 
% if iNumValidStimuli == 0
%     a2bSignificant = zeros(iNumParts,iNumIntensities) > 0;
%     a2iConfidenceIntervalLow = NaN*ones(iNumParts,iNumIntensities);
%     a2iConfidenceIntervalHigh = NaN*ones(iNumParts,iNumIntensities);
%     acPlot.m_iNumValidStimuli = iNumValidStimuli;
%     acPlot.m_fSigLevel = fSigLevel;
%     acPlot.m_fPercentile = fPercentile;
%     acPlot.m_iNumShiftPredicators = iNumShiftPredicators;
%     acPlot.m_a2bSignificant = a2bSignificant;
%     acPlot.m_a2iConfidenceIntervalLow = a2iConfidenceIntervalLow;
%     acPlot.m_a2iConfidenceIntervalHigh = a2iConfidenceIntervalHigh;
%     return;
% end
% 
% 
% a2iShifted = zeros(iNumShiftPredicators, sum(strctUnit.m_aiStimulusIndexValid > iStimulusOffset));
% for iShiftPredicatorIter=aiShiftPredicators
%     aiSinhaIndShifted = circshift(strctUnit.m_aiStimulusIndexValid(strctUnit.m_aiStimulusIndexValid > iStimulusOffset), iShiftPredicatorIter);
%     a2iShifted(iShiftPredicatorIter,:) = aiSinhaIndShifted;
% end
% 
% % Compute Shift Predicators
% for iPartIter=1:iNumParts
%     for iIntensityIter=1:iNumIntensities
%         aiInd = find(a2iPerm(:,iPartIter) == iIntensityIter);
%         if ~isempty(aiInd)
%             for iShiftPredicatorIter=aiShiftPredicators
%                 
%                 aiStimulusIndexShifted = strctUnit.m_aiStimulusIndexValid;
%                 aiStimulusIndexShifted(strctUnit.m_aiStimulusIndexValid > iStimulusOffset) = a2iShifted(iShiftPredicatorIter,:);
%                 a3fIntensityResponseShiftPredicator(iPartIter, iIntensityIter,iShiftPredicatorIter) = ...
%                     mean( mean(a2fRasterSmooth(ismember(aiStimulusIndexShifted,iStimulusOffset+aiInd),iStartAvg:iEndAvg),2));
%             end
%         end
%     end
% end
% a2iConfidenceIntervalHigh = zeros(iNumParts, iNumIntensities);
% a2iConfidenceIntervalMean = zeros(iNumParts, iNumIntensities);
% a2iConfidenceIntervalLow = zeros(iNumParts, iNumIntensities);
% a2fIntensityResponse = zeros(iNumParts,iNumIntensities);
% 
% for iPartIter=1:iNumParts
%     for iIntensityIter=1:iNumIntensities
%         afValues = sort( squeeze(a3fIntensityResponseShiftPredicator(iPartIter, iIntensityIter,:)));
%         afValues = afValues(~isnan(afValues));
%         if ~isempty(afValues)
%                 
%             iHighIndx = 1+round((length(afValues)-1) * fPercentile/100);
%             iMiddleIndex =1+ round((length(afValues)-1) * 50/100);
%             iLowIndex = 1+round( (length(afValues)-1) * (1-fPercentile/100));
%             a2iConfidenceIntervalHigh(iPartIter,iIntensityIter) =afValues(iHighIndx);
%             a2iConfidenceIntervalMean(iPartIter,iIntensityIter) =afValues(iMiddleIndex);
%             a2iConfidenceIntervalLow(iPartIter,iIntensityIter) = afValues(iLowIndex) ;
%             
%             aiInd = find(a2iPerm(:,iPartIter) == iIntensityIter);
%             if ~isempty(aiInd)
%                 aiRelevant = find(ismember(strctUnit.m_aiStimulusIndexValid,iStimulusOffset+aiInd));
%                 a2fIntensityResponse(iPartIter, iIntensityIter) = ...
%                     mean( mean(a2fRasterSmooth(aiRelevant,iStartAvg:iEndAvg),2));
%             end
%         end
%     end
% end
% 
% a2bSignificant = a2fIntensityResponse > a2iConfidenceIntervalHigh | a2fIntensityResponse < a2iConfidenceIntervalLow;
% acPlot.m_iNumValidStimuli = iNumValidStimuli;
% acPlot.m_fSigLevel = fSigLevel;
% acPlot.m_fPercentile = fPercentile;
% acPlot.m_iNumShiftPredicators = iNumShiftPredicators;
% acPlot.m_a2bSignificant = a2bSignificant;
% acPlot.m_a2iConfidenceIntervalLow = a2iConfidenceIntervalLow;
% acPlot.m_a2fIntensityResponse = a2fIntensityResponse;
% acPlot.m_a2iConfidenceIntervalHigh = a2iConfidenceIntervalHigh;
% acPlot.m_abSignificantParts = sum(a2bSignificant,2)'>0;
% return;






function [acPlot4,a3fContrast] = fnGeneratePairwiseContrastPlots(a2iPerm, strctUnit, iStimOffset)
a2iPartRatio = nchoosek(1:11,2);
a3fContrast = ones(11,11,55)*NaN;

for k=1:55
    iPartA = a2iPartRatio(k,1);
    iPartB = a2iPartRatio(k,2);
    for iIntIter1=1:11
        for iIntIter2=1:11
            aiStimuli = find( a2iPerm(:,iPartA) == iIntIter1 & a2iPerm(:,iPartB) == iIntIter2 );
            if ~isempty(aiStimuli)
                a3fContrast(iIntIter1,iIntIter2,k) = mean(strctUnit.m_afAvgStimulusResponseMinusBaseline(iStimOffset+aiStimuli));
            end
        end
    end
end
acPlot4.m_a3fContrast = a3fContrast;

return





function acPlot3 = fnGenerateCorrectRatioPlot(a2iPerm, strctUnit, iStimulusOffset,a2iCorrectPairALargerB)

% First, show avg response as a function of correct / incorrect number of
% ratios

iNumSinhaRatios = 12;
[abCorrect, aiNumWrongRatios] = fnIsCorrectPerm3(a2iPerm,a2iCorrectPairALargerB);
afResponse = zeros(1,iNumSinhaRatios+1);
for iIter=0:iNumSinhaRatios
    aiInd = find(aiNumWrongRatios == iIter);
    afResponse(iIter+1) =  1e3*fnMyMean(strctUnit.m_afAvgStimulusResponseMinusBaseline(iStimulusOffset+aiInd));
end

acPlot3.m_afIncorrectRatioResponse = afResponse;
return;



function [acPlot,a2fPartIntensityResponse] = fnGeneratePartIntensityPlot(a2iPerm, strctUnit,iCategoryOffset, iStimulusOffset,acPartNames,strctConfig)
iNumParts = 11;
iNumIntensities = 11;
a2fPartIntensityResponse = zeros(iNumParts, iNumIntensities);
a2fPartIntensityResponseMinusBaseline = zeros(iNumParts, iNumIntensities);

% compute the intensity curve
for iPartIter=1:iNumParts
    for iIntensityIter=1:iNumIntensities
        aiInd = find(a2iPerm(:,iPartIter) == iIntensityIter);
        if ~isempty(aiInd)
            a2fPartIntensityResponse(iPartIter, iIntensityIter) = fnMyMean(strctUnit.m_afAvgFirintRate_Stimulus(iStimulusOffset+aiInd));
            a2fPartIntensityResponseMinusBaseline(iPartIter, iIntensityIter) = 1e3*fnMyMean(strctUnit.m_afAvgStimulusResponseMinusBaseline(iStimulusOffset+aiInd));
        end
    end
end
acPlot.m_a2fPartIntensityMean = a2fPartIntensityResponse;
acPlot.m_a2fPartIntensityMeanMinusBaseline = a2fPartIntensityResponseMinusBaseline;
acPlot.m_acPartNames = acPartNames;

% Test the significance of the slope of the curve
warning off
for iPartIter=1:iNumParts
    [Dummy, strctStat] = robustfit(1:iNumIntensities,a2fPartIntensityResponse(iPartIter,:));
    acPlot.m_afPvalue(iPartIter) = strctStat.p(2);
end
warning on

return;


function acPlot = fnGenerateContrastPolarityPlot(a2iPerm, strctUnit,iCategoryOffset,iStimulusOffset, fPThreshold )
iNumRatios = nchoosek(11,2);
a2iPartRatio = nchoosek(1:11,2);

aiCatPos = iCategoryOffset+[1:55];
aiCatNeg = iCategoryOffset+[56:110];
acPlot.m_a2fPolarDiff = [strctUnit.m_afAvgFiringRateCategory(aiCatPos)',strctUnit.m_afAvgFiringRateCategory(aiCatNeg)'];
acPlot.m_afPolarDiffPvalue = strctUnit.m_a2fPValueCat(sub2ind(size(strctUnit.m_a2fPValueCat),aiCatPos,aiCatNeg));

aiSigRatios = find(acPlot.m_afPolarDiffPvalue <= fPThreshold);

afPolarityDirection = zeros(1,iNumRatios);
for iRatioIter = 1:length(aiSigRatios);
    iRatio=aiSigRatios(iRatioIter);
    iPartA = a2iPartRatio(iRatio,1);
    iPartB = a2iPartRatio(iRatio,2);
    
    aiAB = find(a2iPerm(:,iPartA) > a2iPerm(:,iPartB));
    aiBA = find(a2iPerm(:,iPartA) < a2iPerm(:,iPartB)) ;
    if fnMyMean(strctUnit.m_afAvgStimulusResponseMinusBaseline(iStimulusOffset+aiAB)) > fnMyMean(strctUnit.m_afAvgStimulusResponseMinusBaseline(iStimulusOffset+aiBA))
        afPolarityDirection(iRatio) = 1;
    else
        afPolarityDirection(iRatio) =  -1;
    end;
end

acPlot.m_afPolarityDirection = afPolarityDirection;




return;

%
% function [abCorrect, aiNumWrongRatios] = fnIsCorrectPerm(a2iPerm)
% a2iCorrectEdges = [...
%     2, 1;
%     4, 1;
%     2, 5;
%     4, 7;
%     2, 3;
%     4, 3;
%     6, 3;
%     9, 5;
%     9, 7;
%     9, 8;
%     9, 10;
%     9, 11];
%
% iNumPerm = size(a2iPerm,1);
% aiNumWrongRatios = zeros(iNumPerm,1,'uint8');
% for iEdgeIter=1:size(a2iCorrectEdges,1)
%     aiNumWrongRatios = aiNumWrongRatios + ...
%         uint8(a2iPerm(:, a2iCorrectEdges(iEdgeIter,1)) > a2iPerm(:,a2iCorrectEdges(iEdgeIter,2)));
% end;
%
% abCorrect = aiNumWrongRatios == 0;
%
% return;
%


