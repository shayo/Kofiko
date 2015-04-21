function ApplySameSinhaAnalysisOnOldData()
strPath = 'D:\Data\Doris\Data For Publications\Sinha\SinhaExp\';
astrctFiles = dir([strPath,'Houdini*']);

strctTmp = load('Sinha11Parts_SelectedPerm');
acPartNames = {'Forehead','Left Eye','Nose','Right Eye','Left Cheek','Upper Lip','Right Cheek','Lower Left Cheek','Mouth','Lower Right Cheek','Chin'};
fSigThres = 1e-5;

acOldData = cell(1, length(astrctFiles));
for k=1:length(astrctFiles)
    fprintf('Loading Old Data %d ...\n',k);
    acOldData{k} = load([strPath,astrctFiles(k).name]);
    afFSI(k) = acOldData{k}.strctUnit.m_acSinhaPlots{1}.m_fFaceSelectivityIndexBounded;
    acOldData{k}.strctUnit.m_strctContrastPair11Parts = fnGetContrastPairTuning(acOldData{k}.strctUnit, 11, 96, strctTmp.a2iAllPerm,acPartNames,fSigThres);
end

aiRelevant = afFSI > 0.3;
acData = acOldData(aiRelevant);
iNumRelevant = length(acData);
fPThres = 1e-5;

for iIter=1:iNumRelevant
    a2fResponses(iIter,:)=acData{iIter}.strctUnit.m_afAvgFirintRate_Stimulus;
    
    a2fPValue(iIter,:) = acData{iIter}.strctUnit.m_strctContrastPair11Parts.m_afPvalue;
    abLarger = acData{iIter}.strctUnit.m_strctContrastPair11Parts.m_a2fAvgFiring(:,1) > acData{iIter}.strctUnit.m_strctContrastPair11Parts.m_a2fAvgFiring(:,2) ;
    afTuning = zeros(1,55);
    afTuning(abLarger' & a2fPValue(iIter,:)<fPThres) = 1;
    afTuning(~abLarger' & a2fPValue(iIter,:)<fPThres) = 0.5;
    a2fTmp(iIter,:) = afTuning;%acData{iIter}.strctUnit.m_strctContrastPair11Parts.m_afTuning;
end

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