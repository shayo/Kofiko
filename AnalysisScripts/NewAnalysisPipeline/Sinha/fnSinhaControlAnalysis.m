function strctUnit = fnSinhaControlAnalysis(strctUnit, strctKofiko, strctInterval,strctConfig,aiTrialIndices)
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
strctUnit.m_strctHairComparison = fnAddHairComparison(strctUnit);
strctUnit.m_strctSinhaFeatureTuning = fnAddSinhaFeatureTuning(strctUnit);

% 8 parts sinha parts ANOVA analysis
acFactorNames = {'Forehead','Hair','Bounding Ellipse','Pupils','Eyes','EyeBrow','Nose','Mouth'};
strctUnit.m_strctSinhaPartsCorrectFeaturesANOVA= fnPartsANOVA(strctUnit, 644:899,acFactorNames);
strctUnit.m_strctSinhaPartsIncorrectFeaturesANOVA= fnPartsANOVA(strctUnit, 900:1155,acFactorNames);

 % 7 parts cartoon ANOVA analysis
acCartoonFactorNames = {'Hair','Bounding Ellipse','Pupils','Eyes','EyeBrow','Nose','Mouth'};
strctUnit.m_strctCartoonANOVA= fnPartsANOVA(strctUnit, 1156:1283,acCartoonFactorNames);
strctUnit.m_strctCartoonFeatureTuning = fnAddCartoonFeatureTuning(strctUnit);

% 8 parts Sinha intensity tuning
strctTmp2=load('SinhaControlPermutations');
acPartNames8 = strctTmp2.acPartNames8;
strctUnit.m_strctIntensityTuning8Parts = fnAddSinhaIntensityPerPartInformation(strctUnit,strctTmp2.a2iInitialPerm, 1326, 8, 8);
strctUnit.m_strctContrastPair8Parts = fnGetContrastPairTuning(strctUnit, 8, 1326,strctTmp2.a2iInitialPerm,acPartNames8,fSigThres);

% Cropped - Inverted analysis
strctUnit.m_strctCroppedAnalysis = fnAddCroppedFacesAndContrastInversionAnalysis(strctUnit);

return;



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

strctIntensityTuning.m_a2fPartIntensityResponse = a2fPartIntensityResponse;
strctIntensityTuning.m_a2fPartIntensityResponseMinusBaseline = a2fPartIntensityResponseMinusBaseline;

% Test the significance of the slope of the curve
warning off
for iPartIter=1:iNumParts
    strctIntensityTuning.m_afIntensityTuningSigPvalue(iPartIter) = fnSafeRobustFit(1:iNumIntensities,a2fPartIntensityResponse(iPartIter,:));
end
warning on

return;


function strctContrastPair = fnGetContrastPairTuning(strctUnit, iNumParts, iStimulusOffset, a2iAllPerm,acPartNames,fSigThres)
a2iPartRatio = nchoosek(1:iNumParts,2);
iNumPairs = size(a2iPartRatio,1);
a2fAvgFiring = zeros(iNumPairs,2); % A > B, A < B
a2fAvgFiring_Sub= zeros(iNumPairs,2); % A > B, A < B
afPvalue = zeros(1,iNumPairs);
afPvalue_Sub = zeros(1,iNumPairs);
acPairNames = cell(1,iNumPairs);
for iPairIter=1:iNumPairs
        iPartA = a2iPartRatio(iPairIter,1);
        iPartB = a2iPartRatio(iPairIter,2);
        aiRelevantStimuliAlargerB = find(a2iAllPerm(:,iPartA) > a2iAllPerm(:,iPartB));
        aiRelevantStimuliAsmallerB = find(a2iAllPerm(:,iPartA) < a2iAllPerm(:,iPartB));
        % Compute the average firing rate per condition, and its p-value
        
        afSamplesCond1 = strctUnit.m_afAvgFirintRate_Stimulus(iStimulusOffset+aiRelevantStimuliAlargerB);
        afSamplesCond2 = strctUnit.m_afAvgFirintRate_Stimulus(iStimulusOffset+aiRelevantStimuliAsmallerB);
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


function strctHairComparison = fnAddHairComparison(strctUnit)

aiGoodSinhaPermutations = [23,  43,    44,   105,   121,   162,   203,   206,   237,   270,   327,   409,   426];
aiIncorrectPermutations = [151,   134,    85,   263,    55,    69,   250,   127,    57,    37,   302,   139,    398,   367,    26];
aiCorrectPermutations = 96+aiGoodSinhaPermutations;
aiBlackHairCorrectFeatures = 550:562;
aiBlackHairIncorrectFeatures = 563:575;
aiWhiteHairCorrectFeatures = 576:588;
aiWhiteHairIncorrectFeatures = 589:601;

acCondInd = {aiCorrectPermutations, aiIncorrectPermutations,aiBlackHairCorrectFeatures,aiBlackHairIncorrectFeatures,aiWhiteHairCorrectFeatures,aiWhiteHairIncorrectFeatures};
strctHairComparison.m_acConditionNames = {'No Hair, Correct Features','No Hair, Incorrect Features','Black Hair, Correct Features','Black Hair, Incorrect Features','White Hair, Correct Features','White Hair, Incorrect Features'};
iNumConditions = length(strctHairComparison.m_acConditionNames);
strctHairComparison.m_a2bCondPValue = NaN*ones(iNumConditions,iNumConditions);
strctHairComparison.m_a2bCondPValueBaseSub = NaN*ones(iNumConditions,iNumConditions);
strctHairComparison.m_afAvgFiringCondition = zeros(1,iNumConditions);
strctHairComparison.m_afAvgFiringConditionBaseSub = zeros(1,iNumConditions);
for iCond1=1:iNumConditions
    strctHairComparison.m_afAvgFiringCondition(iCond1) = nanmean(strctUnit.m_afAvgFirintRate_Stimulus( acCondInd{iCond1}));
    strctHairComparison.m_afAvgFiringConditionBaseSub(iCond1) = 1e3*nanmean(strctUnit.m_afAvgStimulusResponseMinusBaseline( acCondInd{iCond1}));
    for iCond2=1:iNumConditions
        afCond1 = strctUnit.m_afAvgFirintRate_Stimulus( acCondInd{iCond1});
        afCond2 = strctUnit.m_afAvgFirintRate_Stimulus( acCondInd{iCond2});
        [strctHairComparison.m_a2bCondPValue(iCond1,iCond2)] = ranksum(afCond1(~isnan(afCond1)),afCond2(~isnan(afCond2)));

        afCond1 = strctUnit.m_afAvgStimulusResponseMinusBaseline( acCondInd{iCond1});
        afCond2 = strctUnit.m_afAvgStimulusResponseMinusBaseline( acCondInd{iCond2});
        
        [strctHairComparison.m_a2bCondPValueBaseSub(iCond1,iCond2)] =ranksum(afCond1(~isnan(afCond1)),afCond2(~isnan(afCond2)));
    end
end


return;

function strctSinhaFeatureTuning = fnAddSinhaFeatureTuning(strctUnit)

aiAspectRatio = 602:612; % -5:5
aiAssemblyHeight = 613:623; % -5:5
aiEyeDistance = 624:634; % -5:5
aiIrisSize = 635:643; % -3:5

strctSinhaFeatureTuning.m_acCondNames = {'Aspect Ratio','Assembly Height','Eye Distance','Iris Size'};
iNumConditions = length(strctSinhaFeatureTuning.m_acCondNames);
acCondInd = {aiAspectRatio, aiAssemblyHeight, aiEyeDistance,aiIrisSize};
strctSinhaFeatureTuning.m_a2fTuning = NaN*ones(iNumConditions,11);
strctSinhaFeatureTuning.m_a2fTuningBaseLineSub = NaN*ones(iNumConditions,11);
strctSinhaFeatureTuning.m_afSigTuning = NaN*ones(1,iNumConditions);
strctSinhaFeatureTuning.m_afSigTuningBaseSub = NaN*ones(1,iNumConditions);
for iCondIter=1:iNumConditions
    % Build the curve, and test the extreme 
    if iCondIter ~= 4
        strctSinhaFeatureTuning.m_a2fTuning(iCondIter,:) = strctUnit.m_afAvgFirintRate_Stimulus( acCondInd{iCondIter});
        strctSinhaFeatureTuning.m_a2fTuningBaseLineSub(iCondIter,:) = 1e3*strctUnit.m_afAvgStimulusResponseMinusBaseline( acCondInd{iCondIter});
        afRange = -5:5;
        strctSinhaFeatureTuning.m_afSigTuning(iCondIter) =  fnSafeRobustFit(afRange,strctSinhaFeatureTuning.m_a2fTuning(iCondIter,:));
       strctSinhaFeatureTuning.m_afSigTuningBaseSub(iCondIter) = fnSafeRobustFit(afRange,strctSinhaFeatureTuning.m_a2fTuningBaseLineSub(iCondIter,:));
    else
        strctSinhaFeatureTuning.m_a2fTuning(iCondIter,3:11) = strctUnit.m_afAvgFirintRate_Stimulus( acCondInd{iCondIter});
        strctSinhaFeatureTuning.m_a2fTuningBaseLineSub(iCondIter,3:11) = 1e3*strctUnit.m_afAvgStimulusResponseMinusBaseline( acCondInd{iCondIter});
        afRange=-3:5;
        strctSinhaFeatureTuning.m_afSigTuning(iCondIter) =  fnSafeRobustFit(afRange,strctSinhaFeatureTuning.m_a2fTuning(iCondIter,3:11));
        strctSinhaFeatureTuning.m_afSigTuningBaseSub(iCondIter) = fnSafeRobustFit(afRange,strctSinhaFeatureTuning.m_a2fTuningBaseLineSub(iCondIter,3:11));
    end
end

return;


function strctPartsANOVA = fnPartsANOVA(strctUnit, aiStimuliIndex,acFactorNames)
 %Build data strcture needed to run N-way Anova, which main factors being
 %components present or absent.

iNumFactors = length(acFactorNames);
 iNumStimuli = 2^iNumFactors;
acFactors = cell(1,iNumFactors);
for i=1:iNumFactors
    acFactors{i} = zeros(1,iNumStimuli);
end;
 for k=1:iNumStimuli
     strBinary = dec2bin(k-1,iNumFactors);
     for i=1:iNumFactors
         acFactors{i}(k) = str2num(strBinary(i));
     end
 end

[p,table,stat,terms]=anovan(strctUnit.m_afAvgFirintRate_Stimulus(aiStimuliIndex)' ,acFactors,'varnames' ,acFactorNames,'model','interaction','display','off');
[p_sub,table_sub,stat_sub,terms_sub]=anovan(strctUnit.m_afAvgStimulusResponseMinusBaseline(aiStimuliIndex)' ,acFactors,'varnames' ,acFactorNames,'model','interaction','display','off');

a2iInteractionTable =  nchoosek(1:iNumFactors,2);
 
a2fPValue = NaN*ones(iNumFactors,iNumFactors);
a2fPValue_Sub = NaN*ones(iNumFactors,iNumFactors);
for i=1:iNumFactors
    for j=i:iNumFactors
        if (i==j)
            a2fPValue(i,j) = p(i);
            a2fPValue_Sub(i,j) = p_sub(i);
        else
            % Obtain the value from the interactions.
            iIndex = find( (a2iInteractionTable(:,1) == i & a2iInteractionTable(:,2) == j) | (a2iInteractionTable(:,1) == j & a2iInteractionTable(:,2) == i));
            a2fPValue(i,j) = p(iIndex);
            a2fPValue(j,i) = p(iIndex);
            a2fPValue_Sub(i,j) = p_sub(iIndex);
            a2fPValue_Sub(j,i) = p_sub(iIndex);
        end
    end
end
  
strctPartsANOVA.m_a2fPValue = a2fPValue;
strctPartsANOVA.m_a2fPValue_Sub = a2fPValue_Sub;
strctPartsANOVA.m_a2fPValue_Sub = a2fPValue_Sub;
strctPartsANOVA.m_strctTable = table;
strctPartsANOVA.m_strctTableSub = table_sub;
strctPartsANOVA.m_strctStats= stat;
strctPartsANOVA.m_strctStatsSub= stat_sub;
strctPartsANOVA.m_acFactorNames = acFactorNames;
return;


function strctCartoonFeatureTuning = fnAddCartoonFeatureTuning(strctUnit)

aiAspectRatio = 1284:1294; % -5:5
aiAssemblyHeight = 1295:1305; % -5:5
aiEyeDistance = 1306:1316; % -5:5
aiIrisSize = 1317:1325; % -4:4

strctCartoonFeatureTuning.m_acCondNames = {'Aspect Ratio','Assembly Height','Eye Distance','Iris Size'};
iNumConditions = length(strctCartoonFeatureTuning.m_acCondNames);
acCondInd = {aiAspectRatio, aiAssemblyHeight, aiEyeDistance,aiIrisSize};
strctCartoonFeatureTuning.m_a2fTuning = NaN*ones(iNumConditions,11);
strctCartoonFeatureTuning.m_a2fTuningBaseLineSub = NaN*ones(iNumConditions,11);
strctCartoonFeatureTuning.m_afSigTuning = NaN*ones(1,iNumConditions);
strctCartoonFeatureTuning.m_afSigTuningBaseSub = NaN*ones(1,iNumConditions);
for iCondIter=1:iNumConditions
    % Build the curve, and test the extreme 
    if iCondIter ~= 4
        strctCartoonFeatureTuning.m_a2fTuning(iCondIter,:) = strctUnit.m_afAvgFirintRate_Stimulus( acCondInd{iCondIter});
        strctCartoonFeatureTuning.m_a2fTuningBaseLineSub(iCondIter,:) = 1e3*strctUnit.m_afAvgStimulusResponseMinusBaseline( acCondInd{iCondIter});
        afRange = -5:5;
        strctCartoonFeatureTuning.m_afSigTuning(iCondIter) = fnSafeRobustFit(afRange,strctCartoonFeatureTuning.m_a2fTuning(iCondIter,:));
       strctCartoonFeatureTuning.m_afSigTuningBaseSub(iCondIter) = fnSafeRobustFit(afRange,strctCartoonFeatureTuning.m_a2fTuningBaseLineSub(iCondIter,:));
    else
        strctCartoonFeatureTuning.m_a2fTuning(iCondIter,3:11) = strctUnit.m_afAvgFirintRate_Stimulus( acCondInd{iCondIter});
        strctCartoonFeatureTuning.m_a2fTuningBaseLineSub(iCondIter,3:11) = 1e3*strctUnit.m_afAvgStimulusResponseMinusBaseline( acCondInd{iCondIter});
        afRange=-4:4;
        strctCartoonFeatureTuning.m_afSigTuning(iCondIter) = fnSafeRobustFit(afRange,strctCartoonFeatureTuning.m_a2fTuning(iCondIter,3:11));
       strctCartoonFeatureTuning.m_afSigTuningBaseSub(iCondIter) = fnSafeRobustFit(afRange,strctCartoonFeatureTuning.m_a2fTuningBaseLineSub(iCondIter,3:11));
    end
 end

return;


% 
function strctCroppedAnalysis = fnAddCroppedFacesAndContrastInversionAnalysis(strctUnit)
% Build the relevant PSTH for the different conditions...

aiFullFaces = 1:16;
aiFullFacesInv = 1641:1656;
aiCropped = 1609:1624;
aiCroppedInv = 1625:1640;

acConditionNames = {'Full Faces','Cropped Faces','Full Faces, Inverted Contrast','Cropped Faces, Inverted Contrast'};
acCondInd = {aiFullFaces, aiCropped, aiFullFacesInv,aiCroppedInv};
iNumTimePoints = size(strctUnit.m_a2fAvgFirintRate_Stimulus,2);
iNumConditions = length(acConditionNames);
a2fPSTH = zeros(iNumConditions,iNumTimePoints);
afLatencyMS = zeros(1,iNumConditions);
for iCondIter=1:iNumConditions
    a2fPSTH(iCondIter,:) = nanmean(strctUnit.m_a2fAvgFirintRate_Stimulus( acCondInd{iCondIter},:));
    
    [fDummy,iInd]=max(a2fPSTH(iCondIter,:));
    afLatencyMS(iCondIter) = strctUnit.m_aiPeriStimulusRangeMS( iInd);
end

a2fPValue = nans(iNumConditions,iNumConditions);
a2fPValueSub = nans(iNumConditions,iNumConditions);
for iCondIter1=1:iNumConditions
    for iCondIter2=1:iNumConditions
        a2fPValue(iCondIter1,iCondIter2) = ttest( strctUnit.m_afAvgFirintRate_Stimulus(acCondInd{iCondIter1}), strctUnit.m_afAvgFirintRate_Stimulus(acCondInd{iCondIter2}));
        a2fPValueSub(iCondIter1,iCondIter2) = ttest( strctUnit.m_afAvgStimulusResponseMinusBaseline(acCondInd{iCondIter1}), strctUnit.m_afAvgStimulusResponseMinusBaseline(acCondInd{iCondIter2}));
    end
end

strctCroppedAnalysis.m_afLatencyMS = afLatencyMS;
strctCroppedAnalysis.m_acConditionNames = acConditionNames;
strctCroppedAnalysis.m_a2fPSTH = a2fPSTH;
strctCroppedAnalysis.m_a2fPValue = a2fPValue;
strctCroppedAnalysis.m_a2fPValueSub = a2fPValueSub;

return;


function pValue = fnSafeRobustFit(X,Y)
try
    [Dummy, strctStat] = robustfit(X,Y);
    pValue  = strctStat.p(2);
catch
    pValue = NaN;
end
return;
