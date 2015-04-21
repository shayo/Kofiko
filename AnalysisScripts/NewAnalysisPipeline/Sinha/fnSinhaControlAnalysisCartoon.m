function strctUnit = fnSinhaControlAnalysisCartoon(strctUnit, strctKofiko, strctInterval,strctConfig,aiTrialIndices)
% load('C:\DeleteMeUnit.mat');
% figure;
% imagesc(strctUnit.m_aiPeriStimulusRangeMS, 1:strctUnit.m_iNumStimuli, fnMyColorMap(strctUnit.m_a2fAvgFirintRate_Stimulus))


% Add quality information about the unit (MUA/single/...)
strctUnit = fnAddQualityInformation(strctUnit);

%  Add FSI/AUC/d' information.
strctUnit = fnAddFaceSelectivityInformation(strctUnit);

% Sinha-11 analysis 
strctTmp = load('Sinha11Parts_SelectedPerm');
acPartNames = {'Forehead','Left Eye','Nose','Right Eye','Left Cheek','Upper Lip','Right Cheek','Lower Left Cheek','Mouth','Lower Right Cheek','Chin'};
fSigThres = 1e-5;
strctUnit.m_strctIntensityTuning11Parts = fnAddSinhaIntensityPerPartInformation(strctUnit,strctTmp.a2iAllPerm, 96, 11,11);
strctUnit.m_strctContrastPair11Parts = fnGetContrastPairTuning(strctUnit, 11, 96, strctTmp.a2iAllPerm,acPartNames,fSigThres);

strctUnit.m_strctCartoonTuningPSTH = fnExtractCartoonFeaturePSTH(strctUnit);
strctUnit.m_strctCartoonTuning = fnAddCartoonTuningSigUsingSurrogateTests(strctUnit,5000);

return;

figure(11);
clf;
subplot(3,1,1);
imagesc(strctUnit.m_a2fAvgFirintRate_Stimulus(1:96,:));
subplot(3,1,2);
imagesc(strctUnit.m_a2fAvgFirintRate_Stimulus(97:545,:));
subplot(3,1,3);
imagesc(strctUnit.m_a2fAvgFirintRate_Stimulus(546:end,:));

function strctCartoonTuning = fnAddCartoonTuningSigUsingSurrogateTests(strctUnit,iNumSurrogateTests)

aiAllRelevantStimuli = 545:6556;
abRelevantStimuli = ismember(strctUnit.m_aiStimulusIndexValid,  aiAllRelevantStimuli);
aiRelevantStimuli = find(abRelevantStimuli);
aiStimuli = strctUnit.m_aiStimulusIndexValid(abRelevantStimuli);
%iNumSurrogateTests =  100;% 5016;
iBeforeMS = 0;
iAfterMS = 300;
iPSTH_Len = iAfterMS-iBeforeMS+1;
iNumFeatures = 21;
iOffset = 544;
iNumFeatureValues = 11;
 strctCartoon = load('D:\Data\Doris\Stimuli\cartoon\a2iCartoonMatrix.mat');
a2iCartoonMatrix = strctCartoon.a2iCartoonMatrix;
iTimeSmoothingMS = 5;

    
% Build the conditions....
a2cConditions = cell(iNumFeatures,iNumFeatureValues); 
 for iFeatureIter=1:iNumFeatures
     for iFeatureValue = 0:10
        %a2cConditions{iFeatureIter,1+iFeatureValue} = iOffset+find(a2iCartoonMatrix(:,1+iFeatureIter) == iFeatureValue);
        aiStimuliForThisCondition = iOffset+find(a2iCartoonMatrix(:,1+iFeatureIter) == iFeatureValue);
        a2cConditions{iFeatureIter,1+iFeatureValue} = find(ismember(aiStimuli, aiStimuliForThisCondition));
     end
 end
 acConditions = a2cConditions(:);
iNumConditions = length(acConditions);
% Build the averaging indices for fast computation 
 
 
a2bRasterCartoonOnly = fnRasterAux(strctUnit.m_afSpikeTimes, strctUnit.m_afStimulusONTime(aiRelevantStimuli), iBeforeMS, iAfterMS);  
iRaster_Length = size(a2bRasterCartoonOnly,2);

a3fHetro = zeros(iNumFeatures, iPSTH_Len,iNumSurrogateTests);
afSmoothingKernelMS = fspecial('gaussian',[1 7*iTimeSmoothingMS],iTimeSmoothingMS);
fprintf('Surrogate tests...\n');
 for iSurrogateIter=1:iNumSurrogateTests
     iNumAppear = size(a2bRasterCartoonOnly,1);
     aiPerm = randperm(iNumAppear);
     %aiPerm = circshift(1:iNumAppear,[1,iSurrogateIter]);
     a2bRasterShifted = a2bRasterCartoonOnly(aiPerm  ,:);
     
     a2fAvg = NaN*ones(iNumConditions, iRaster_Length);
     for iConditionIter=1:iNumConditions
         a2fAvg(iConditionIter,:) = mean(a2bRasterShifted(acConditions{iConditionIter}  ,:),1);
     end
     a2fAvg = conv2(a2fAvg,afSmoothingKernelMS ,'same');
     a2fTemp  = 1e3 * a2fAvg;
     
     a3fTuning = reshape(a2fTemp,  iNumFeatures, iNumFeatureValues,  iPSTH_Len);
     for iFeatureIter=1:iNumFeatures
         a3fHetro(iFeatureIter, :, iSurrogateIter) = fnHeterogeneity(squeeze(a3fTuning(iFeatureIter,:,:)));
     end
 end
 
 % Generate the confidence interval?
 a2fHetroThreshold = zeros(iNumFeatures,iPSTH_Len);
 for iFeatureIter=1:iNumFeatures
     a2fHetro = squeeze(a3fHetro(iFeatureIter,:,:));
     % Sort each time bin 
     a2fSortedHetro = sort(a2fHetro,2);
     % Take 99 percentile?
     iEntry99 = floor(0.99*iNumSurrogateTests);
     a2fHetroThreshold(iFeatureIter,:) = a2fSortedHetro(:,iEntry99);
 end
 
 % Non Shuffled Hetrogenity
 
a2bRasterShifted = a2bRasterCartoonOnly;
a2fAvg = NaN*ones(iNumConditions, iRaster_Length);
for iConditionIter=1:iNumConditions
    a2fAvg(iConditionIter,:) = mean(a2bRasterShifted(acConditions{iConditionIter}  ,:),1);
end
a2fAvg = conv2(a2fAvg,afSmoothingKernelMS ,'same');
a2fTemp  = 1e3 * a2fAvg;
a3fTuningNoShift = reshape(a2fTemp,  iNumFeatures, iNumFeatureValues,  iPSTH_Len);
a2fHetroNoShuffle = zeros(iNumFeatures,iPSTH_Len);
for iFeatureIter=1:iNumFeatures
    a2fHetroNoShuffle(iFeatureIter, :) = fnHeterogeneity(squeeze(a3fTuningNoShift(iFeatureIter,:,:)));
end

 strctCartoonTuning.m_a2fHetroThreshold = a2fHetroThreshold;
strctCartoonTuning.m_a2fHetroNoShuffle = a2fHetroNoShuffle;
strctCartoonTuning.m_a3fTuningNoShift = a3fTuningNoShift;

if 0
 figure(100);clf;
 subplot(2,1,1);
 plot(a2fHetroNoShuffle(1,:))
 hold on;
 plot(a2fHetroThreshold(1,:),'r');
 set(gca,'xlim',[0 301]);
 subplot(2,1,2);
 imagesc(squeeze(a3fTuningNoShift(1,:,:)))
end
return;


function strctCartoonTuningPSTH = fnExtractCartoonFeaturePSTH(strctUnit)
strctCartoon = load('D:\Data\Doris\Stimuli\cartoon\a2iCartoonMatrix.mat');
a2iCartoonMatrix = strctCartoon.a2iCartoonMatrix;

% Plot tuning curves

iOffset = 544;
iNumFeatures = 21;
strctCartoonTuningPSTH.m_a3fPSTH = zeros(11,701, iNumFeatures);
for iFeatureIter=1:iNumFeatures
    for iFeatureValue=0:10
        aiInd = find(a2iCartoonMatrix(:,1+iFeatureIter) == iFeatureValue);
        if ~isempty(aiInd)
            strctCartoonTuningPSTH.m_a3fPSTH(iFeatureValue+1,:,iFeatureIter) = nanmean( strctUnit.m_a2fAvgFirintRate_Stimulus(iOffset+aiInd,:),1);
        end
    end
%     subplot(5,4,iFeatureIter);
%     imagesc(-100:400,0:10,a2fPSTH(:,100:end-100))
%     title(num2str(iFeatureIter));
end

bPlot = false;
if bPlot
figure(100);
clf;
    for iFeatureIter=1:iNumFeatures
    subplot(5,5,iFeatureIter);
    a2fPSTH = strctCartoonTuningPSTH.m_a3fPSTH(:,:,iFeatureIter);
    imagesc(-100:400,0:10,a2fPSTH(:,100:end-100))
    title(num2str(iFeatureIter));
    end
end

% 
% % Sinha 50
% strctTmp.a2iAllPerm(50,:)
% 
% impixelinfo
% 
% aiInd=1:545;figure;imagesc(-200:500,aiInd,strctUnit.m_a2fAvgFirintRate_Stimulus(aiInd,:))
% 


% 545:6556
% 85ms - 120ms

return;



function fnLookIntoThingsCarefully()
a2iPairs = nchoosek(1:11,2);
figure(99);
clf;
aiInd=1:96;imagesc(-200:500,aiInd,strctUnit.m_a2fAvgFirintRate_Stimulus(aiInd,:))

figure(100);
clf;

aiPeri = -200:500;
fStartMS = 70;
fEndMS = 250;
iStartAvgInd = find(aiPeri == fStartMS);
iEndAvgInd = find(aiPeri == fEndMS);
for iPairIter=1:55
iPartA = a2iPairs(iPairIter,1);
iPartB = a2iPairs(iPairIter,2);
aiNeg = 96+find(strctTmp.a2iAllPerm(:,iPartA) < strctTmp.a2iAllPerm(:,iPartB));
aiPos = 96+find(strctTmp.a2iAllPerm(:,iPartA) > strctTmp.a2iAllPerm(:,iPartB));

afResponse = nanmean(strctUnit.m_a2fAvgFirintRate_Stimulus(:,iStartAvgInd:iEndAvgInd),2);
afNeg = mean(strctUnit.m_a2fAvgFirintRate_Stimulus(aiNeg,:));
afPos = mean(strctUnit.m_a2fAvgFirintRate_Stimulus(aiPos,:));

afPosRes = afResponse(aiPos);
afNegRes = afResponse(aiNeg);

afPvalue(iPairIter)=ranksum(afPosRes,afNegRes);
% [afHistPos, afCentPos] = hist(afPosRes,10);
% [afHistNeg, afCentNeg] = hist(afNegRes,10);
% figure(143);
% clf;
% plot(afCentPos,afHistPos,afCentNeg,afHistNeg );
% figure(144);
% plot(aiPeri,afNeg,aiPeri,afPos);


subplot(8,8,iPairIter);
plot(-200:500,afNeg,'r');
hold on;
plot(-200:500,afPos,'b');
title(num2str(iPairIter));
end;

function strctUnit = fnAddQualityInformation(strctUnit)
% Quality information includes 
% 1. Contamination: the percentage of spikes with ISI < 1ms
% 2. Spike Amplitude
% 3. Wave form standard deviation (not very good...can shift)

iIndex = find(strctUnit.m_afISICenter >= 1,1,'first');
fPercentageOfSmallISI = sum(strctUnit.m_afISIDistribution(1:iIndex))/  sum(strctUnit.m_afISIDistribution) * 100;
strctUnit.m_strctQuality.m_fContaminationPerc= fPercentageOfSmallISI;
strctUnit.m_strctQuality.m_fSpikeAmplitude = max(strctUnit.m_afAvgWaveForm)-min(strctUnit.m_afAvgWaveForm);
strctUnit = fnAddAttribute(strctUnit,'ISI Contamination',sprintf('%.2f',fPercentageOfSmallISI),fPercentageOfSmallISI);

return;

function strctUnit = fnAddFaceSelectivityInformation(strctUnit)
% Add the Face Selectivity Index Attribute 
aiFaceInd = 1:16;
aiNonFaceInd = 17:96;
fNaN_PercPos = sum(isnan(strctUnit.m_afAvgFirintRate_Stimulus(aiFaceInd))) / length(aiFaceInd);
fNaN_PercNeg = sum(isnan(strctUnit.m_afAvgFirintRate_Stimulus(aiNonFaceInd))) / length(aiNonFaceInd);
if fNaN_PercPos > 0.3 || fNaN_PercNeg > 0.3
    % Face selectivit information cannot be reliably extracted because we
    % do not have enough data.
    return;
end;
    
fFaceRes = nanmean(strctUnit.m_afAvgFirintRate_Stimulus(aiFaceInd));
fNonFaceRes = nanmean(strctUnit.m_afAvgFirintRate_Stimulus(aiNonFaceInd));
fFaceSelectivityIndex =  (fFaceRes - fNonFaceRes) / (fFaceRes + fNonFaceRes+eps);

strctUnit.m_strctFaceSelectivity.m_fFaceSelectivityIndex = fFaceSelectivityIndex;
strctUnit = fnAddAttribute(strctUnit,'FSI',sprintf('%.2f',fFaceSelectivityIndex),fFaceSelectivityIndex);

% Add d' and AUC statistics, for positive and baseline subtracted
% version....

afResPos =strctUnit.m_afAvgStimulusResponseMinusBaseline(aiFaceInd);
afResPos = afResPos(~isnan(afResPos));
    
afResNeg =strctUnit.m_afAvgStimulusResponseMinusBaseline(aiNonFaceInd);
afResNeg = afResNeg(~isnan(afResNeg));
    
[strctUnit.m_strctFaceSelectivity.m_fdPrimeBaselineSub,  strctUnit.m_strctFaceSelectivity.m_fAreaUnderROCSub, strctUnit.m_strctFaceSelectivity.m_fTwoSidedpValueSub]= fnDPrimeROC(afResPos, afResNeg, true);
afResPos =strctUnit.m_afAvgFirintRate_Stimulus(aiFaceInd);
afResPos = afResPos(~isnan(afResPos));
afResNeg =strctUnit.m_afAvgFirintRate_Stimulus(aiNonFaceInd);
afResNeg = afResNeg(~isnan(afResNeg));
[strctUnit.m_strctFaceSelectivity.m_fdPrime, strctUnit.m_strctFaceSelectivity.m_fAreaUnderROC, strctUnit.m_strctFaceSelectivity.m_fTwoSidedpValue] = fnDPrimeROC(afResPos, afResNeg);
    

return;

function strctIntensityTuning = fnAddSinhaIntensityPerPartInformation(strctUnit,a2iAllPerm, iStimulusOffset, iNumParts, iNumIntensities)
a2fPartIntensityResponse = NaN*ones(iNumParts, iNumIntensities);
a2fPartIntensityResponseMinusBaseline = NaN*zeros(iNumParts, iNumIntensities);
strctIntensityTuning.m_afIntensityTuningSigPvalue = NaN*ones(1,iNumParts);

% compute the intensity curve
for iPartIter=1:iNumParts
    for iIntensityIter=1:iNumIntensities
        aiInd = find(a2iAllPerm(:,iPartIter) == iIntensityIter);
        if ~isempty(aiInd)
            a2fPartIntensityResponse(iPartIter, iIntensityIter) = nanmean(strctUnit.m_afAvgFirintRate_Stimulus(iStimulusOffset+aiInd));
            a2fPartIntensityResponseMinusBaseline(iPartIter, iIntensityIter) = 1e3*nanmean(strctUnit.m_afAvgStimulusResponseMinusBaseline(iStimulusOffset+aiInd));
        end
    end
end

fNaNPerc = sum(isnan(a2fPartIntensityResponse(:))) / length(a2fPartIntensityResponse(:));
if fNaNPerc > 0.3
    strctIntensityTuning = [];
    return;
end

strctIntensityTuning.m_a2fPartIntensityResponse = a2fPartIntensityResponse;
strctIntensityTuning.m_a2fPartIntensityResponseMinusBaseline = a2fPartIntensityResponseMinusBaseline;

% Test the significance of the slope of the curve
warning off
for iPartIter=1:iNumParts
    if ~all(isnan(a2fPartIntensityResponse(iPartIter,:)))
        strctIntensityTuning.m_afIntensityTuningSigPvalue(iPartIter) = fnSafeRobustFit(1:iNumIntensities,a2fPartIntensityResponse(iPartIter,:));
    end
end
warning on

return;


function strctContrastPair = fnGetContrastPairTuning(strctUnit, iNumParts, iStimulusOffset, a2iAllPerm,acPartNames,fSigThres)
a2iPartRatio = nchoosek(1:iNumParts,2);
iNumPairs = size(a2iPartRatio,1);
a2fAvgFiring = nans(iNumPairs,2); % A > B, A < B
a2fAvgFiring_Sub= nans(iNumPairs,2); % A > B, A < B
afPvalue = nans(1,iNumPairs);
afPvalue_Sub = nans(1,iNumPairs);
acPairNames = cell(1,iNumPairs);
for iPairIter=1:iNumPairs
        iPartA = a2iPartRatio(iPairIter,1);
        iPartB = a2iPartRatio(iPairIter,2);
        aiRelevantStimuliAlargerB = find(a2iAllPerm(:,iPartA) > a2iAllPerm(:,iPartB));
        aiRelevantStimuliAsmallerB = find(a2iAllPerm(:,iPartA) < a2iAllPerm(:,iPartB));
        % Compute the average firing rate per condition, and its p-value
        
        afSamplesCond1 = strctUnit.m_afAvgFirintRate_Stimulus(iStimulusOffset+aiRelevantStimuliAlargerB);
        afSamplesCond2 = strctUnit.m_afAvgFirintRate_Stimulus(iStimulusOffset+aiRelevantStimuliAsmallerB);
        fPercNaN1 = sum(isnan(afSamplesCond1)) / length(afSamplesCond1);
        fPercNaN2 = sum(isnan(afSamplesCond2)) / length(afSamplesCond2);
        if fPercNaN1 > 0.3 || fPercNaN2 > 0.3
            
            continue;
        end;
        
        a2fAvgFiring(iPairIter,1) = nanmean(afSamplesCond1);
        a2fAvgFiring(iPairIter,2) = nanmean(afSamplesCond2);
        afPvalue(iPairIter) = ranksum(afSamplesCond1(~isnan(afSamplesCond1)),afSamplesCond2(~isnan(afSamplesCond2)));
        
        afSamplesCond1 = strctUnit.m_afAvgStimulusResponseMinusBaseline(iStimulusOffset+aiRelevantStimuliAlargerB);
        afSamplesCond2 = strctUnit.m_afAvgStimulusResponseMinusBaseline(iStimulusOffset+aiRelevantStimuliAsmallerB);
        a2fAvgFiring_Sub(iPairIter,1) = nanmean(afSamplesCond1);
        a2fAvgFiring_Sub(iPairIter,2) = nanmean(afSamplesCond2);
        afPvalue_Sub(iPairIter) = ranksum(afSamplesCond1(~isnan(afSamplesCond1)),afSamplesCond2(~isnan(afSamplesCond2)));
        
        acPairNames{iPairIter} = [acPartNames{iPartA},'-',acPartNames{iPartB}];
end

if sum(isnan(a2fAvgFiring(:)))/2 > 5
    % 5 condisions are missing. Drop this interval.
    strctContrastPair = [];
    return;
end

strctContrastPair.m_acPairNames = acPairNames;
strctContrastPair.m_a2fAvgFiring = a2fAvgFiring;
strctContrastPair.m_afPvalue = afPvalue;

strctContrastPair.m_a2fAvgFiring_Sub = a2fAvgFiring_Sub;
strctContrastPair.m_afPvalue_Sub = afPvalue_Sub;


strctContrastPair.m_abALargerB = a2fAvgFiring(:,1) > a2fAvgFiring(:,2);
strctContrastPair.m_afTuning = zeros(1,iNumPairs); %0 - not sig. 1 - A>B, -1: A<B
strctContrastPair.m_afTuning(strctContrastPair.m_abALargerB & strctContrastPair.m_afPvalue' < fSigThres) = 1;
strctContrastPair.m_afTuning(~strctContrastPair.m_abALargerB & strctContrastPair.m_afPvalue'< fSigThres) = -1;



strctContrastPair.m_abALargerB_Sub = a2fAvgFiring_Sub(:,1) > a2fAvgFiring_Sub(:,2);
strctContrastPair.m_afTuning_Sub = zeros(1,iNumPairs); %0 - not sig. 1 - A>B, -1: A<B
strctContrastPair.m_afTuning_Sub(strctContrastPair.m_abALargerB_Sub & strctContrastPair.m_afPvalue_Sub' < fSigThres) = 1;
strctContrastPair.m_afTuning_Sub(~strctContrastPair.m_abALargerB_Sub & strctContrastPair.m_afPvalue_Sub'< fSigThres) = -1;

return;

function pValue = fnSafeRobustFit(X,Y)
try
    [Dummy, strctStat] = robustfit(X,Y);
    pValue  = strctStat.p(2);
catch
    pValue = NaN;
end
return;



%
function fnRegeneratePermutationFromImages()
apt2fSampleCoords = [60,35; % Forehead
                                         49,59; % Left Eye
                                         64,72; % Nose
                                         80,58; % Right Eye
                                         44,76; % Left Cheek
                                         64,88; % Upper lip
                                         84,74; % Right Cheek
                                         41,96; % Lower left cheek
                                         65,97; % Mouth
                                         89, 92; % Lower right cheek
                                         65,109; % Chin
                                         ];
                                     
a2iSinhaPerm = zeros(432,11);
for k=1:432
    I=imread(sprintf('\\\\192.168.50.93\\StimulusSet\\Sinha_Exp\\Sinha_v2_FOB\\Sinha%04d.bmp',k));
    aiIntensity = zeros(1,11);
    for i=1:11
        aiIntensity(i) = I( apt2fSampleCoords(i,2), apt2fSampleCoords(i,1));
    end
     afSorted=sort(aiIntensity);
     for i=1:11
         aiPerm(i) = find(aiIntensity(i) ==afSorted);
     end
       a2iSinhaPerm(k,:) = aiPerm;
end

save('Sinha432Perm','a2iSinhaPerm');

figure(11);
clf;
imshow(a2fResize);
hold on;
plot(apt2fSampleCoords(:,1),apt2fSampleCoords(:,2),'b.');

 % 10    7    1    3    2    6    9    8    5    4   11
 