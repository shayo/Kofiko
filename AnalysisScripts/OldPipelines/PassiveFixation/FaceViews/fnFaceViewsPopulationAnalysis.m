function fnFaceViewsPopulationAnalysis(acUnits,strctConfig)

aiNumSpikes = zeros(1,length(acUnits));
afFaceSelectivity = zeros(1,length(acUnits));
afAmpRange = zeros(1,length(acUnits));
afMaxStd = zeros(1,length(acUnits));

for k=1:length(acUnits)
    aiNumSpikes(k) = length(acUnits{k}.m_afSpikeTimes);
    fFace = fnMyMean(acUnits{k}.m_afAvgStimulusResponseMinusBaseline(1:207));
    fNonFace = fnMyMean(acUnits{k}.m_afAvgStimulusResponseMinusBaseline(208:end));
    afFaceSelectivity(k) =(fFace-fNonFace)/(fFace+fNonFace);
    afAmpRange(k) = max(acUnits{k}.m_afAvgWaveForm)-min(acUnits{k}.m_afAvgWaveForm);
    afMaxStd(k) = max(acUnits{k}.m_afStdWaveForm);
end
acUnits = acUnits(aiNumSpikes > 500 & afMaxStd./afAmpRange < 0.5);
iNumUnits = length(acUnits);
abRocco = zeros(1,iNumUnits)>0;

for j=1:iNumUnits
    abRocco(j) = strcmpi(acUnits{j}.m_strSubject,'Rocco');
end
fprintf('%d Units survived (%d In Rocco and %d in Houdini)\n',iNumUnits,sum(abRocco),sum(~abRocco));
%%
iNumUnits = length(acUnits);
iNumCat = size(acUnits{1}.m_a2bStimulusCategory,2);
a2fCatResNorm = zeros(iNumUnits, iNumCat);
for iUnitIter=1:iNumUnits
    afResNorm = acUnits{iUnitIter}.m_afStimulusResponseMinusBaseline / max(acUnits{iUnitIter}.m_afStimulusResponseMinusBaseline);
    for k=1:iNumCat
        aiRelevantStim = find(acUnits{iUnitIter}.m_a2bStimulusCategory(:,k));
        a2fCatResNorm(iUnitIter,k) = fnMyMean(afResNorm(ismember(acUnits{iUnitIter}.m_aiStimulusIndexValid,aiRelevantStim)));
    end
    
end
figure(11);
clf;
bar(mean(a2fCatResNorm,1))
set(gca,'xticklabel',acUnits{1}.m_acCatNames);
ylabel('Average Normalized Response');
title(sprintf('Grand Average, %d units from Houdini (chamber on right hemisphere)',iNumUnits));
xticklabel_rotate
