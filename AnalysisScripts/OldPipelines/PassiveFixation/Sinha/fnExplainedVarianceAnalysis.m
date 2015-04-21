for k=1:length(acUnits)
    a2iNumPres(k,:) = hist(acUnits{k}.m_aiStimulusIndexValid,1:549);
end

figure;imagesc(a2iNumPres)

figure;
plot(mean(a2iNumPres,2))
plot(max(a2iNumPres,[],2))


figure;plot(acUnits{210}.m_afAvgFirintRate_Stimulus)
iNumStimuli = 549;
iUnitIter = 211;

iStart= find(acUnits{iUnitIter}.m_aiPeriStimulusRangeMS>= acUnits{iUnitIter}.m_strctStatParams.m_iStartAvgMS,1,'first');
iEnd = find(acUnits{iUnitIter}.m_aiPeriStimulusRangeMS>= acUnits{iUnitIter}.m_strctStatParams.m_iEndAvgMS,1,'first');
iStartB= find(acUnits{iUnitIter}.m_aiPeriStimulusRangeMS>= acUnits{iUnitIter}.m_strctStatParams.m_iStartBaselineAvgMS,1,'first');
iEndB = find(acUnits{iUnitIter}.m_aiPeriStimulusRangeMS>= acUnits{iUnitIter}.m_strctStatParams.m_iEndBaselineAvgMS,1,'first');
%%
a2fResponse = zeros(length(acUnits),iNumStimuli);
a2fResponseBaselineSub = zeros(length(acUnits),iNumStimuli);
for iUnitIter=1:length(acUnits)
    afBaseline = zeros(1,iNumStimuli);
    afAvgFiringRate = zeros(1,iNumStimuli);
    for iStimulusIndex=1:iNumStimuli
        %iAvgLen = 15; % ms
        %afSmoothingKernelMS = fspecial('gaussian',[1 7*iAvgLen],iAvgLen);
        %a2fRasterSmooth = conv2(a2fAvg,afSmoothingKernelMS ,'same');
        aiInd = find( acUnits{iUnitIter}.m_aiStimulusIndexValid == iStimulusIndex);
        if ~isempty(aiInd)
            afResponses = sum(acUnits{iUnitIter}.m_a2bRaster_Valid(aiInd, iStart:iEnd),2) / (iEnd-iStart)*1e3;
            afBaseRes = sum(acUnits{iUnitIter}.m_a2bRaster_Valid(aiInd, iStartB:iEndB),2) / (iEndB-iStartB)*1e3;
            afBaseline(iStimulusIndex) = mean(afBaseRes);
            afAvgFiringRate(iStimulusIndex) = mean(afResponses);
        else
            afBaseline(iStimulusIndex) = NaN;
            afAvgFiringRate(iStimulusIndex) = NaN;
        end
    end
    a2fResponse(iUnitIter,:) = afAvgFiringRate;
    a2fResponseBaselineSub(iUnitIter,:) = afAvgFiringRate-afBaseline;
end


strctTmp = load('D:\Data\Doris\Stimuli\Sinha_v2_FOB\SelectedPerm.mat');
a2iPerm = double(strctTmp.a2iAllPerm);
iNumPerm = size(a2iPerm,1);
a2iPairs = nchoosek(1:11,2);
iNumPairs = size(a2iPairs,1);
a2iPermExt = zeros(iNumPerm, iNumPairs);
for k=1:iNumPerm
    a2iPermExt(k,:) = sign(a2iPerm(k, a2iPairs(:,1))-a2iPerm(k, a2iPairs(:,2)));
end
afFractionOfVarianceUnexplainedLinear = zeros(1,length(acUnits));
afFractionOfVarianceUnexplainedSign = zeros(1,length(acUnits));
for iUnitIter=1:length(acUnits)
    afResponses = a2fResponse(iUnitIter,97:97+432-1);
    abValid = ~isnan(afResponses);
    [afOptimalWeights, afResiduals, afFractionOfVarianceUnexplainedLinear(iUnitIter),afExplainedVarianceLinear(iUnitIter)] = fnRegress(a2iPerm(abValid,:), afResponses(abValid));
    [afOptimalWeights, afResiduals, afFractionOfVarianceUnexplainedSign(iUnitIter),afExplainedVarianceSign(iUnitIter)] = fnRegress([a2iPermExt(abValid,:), ones(sum(abValid),1)], afResponses(abValid));
    
    
end

mean(afExplainedVarianceLinear(aiFaceSelectivityIndex>0.3))
mean(afExplainedVarianceSign(aiFaceSelectivityIndex>0.3))
%%

a2iPairs
for k=1:55
    aiAvg(k)=sum(a2iPerm(:,a2iPairs(k,1)) > a2iPerm(:,a2iPairs(k,2)) );
end


for k=1:length(
acUnits{51}.m_acSinhaPlots{2}.m_a2fPartIntensityMean