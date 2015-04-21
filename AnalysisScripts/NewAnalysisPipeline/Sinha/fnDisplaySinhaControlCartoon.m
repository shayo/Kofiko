function ahSubPlots =fnDisplaySinhaControlCartoon(ahPanels,strctData)
strctUnit = strctData.strctUnit;
% Show overall responses
h1 = tightsubplot(1,3,1,'Spacing',0.1,'Parent',ahPanels(1));
imagesc(strctUnit.m_aiPeriStimulusRangeMS,1:strctUnit.m_iNumStimuli, fnMyColorMap(strctUnit.m_a2fAvgFirintRate_Stimulus))
% Build a small PSTH with the major types of stimuli....

acConditionNames = {'Faces','Non Faces','Sinha','Sinha with Black hair','Sinha with white hair','Cartoon','Sinha 8','Cropped Faces','Cropped Inv','Faces Inv'};
acConditionIndices = {[1:16], [17:96],[97:549], [550:588],[576:588],[1156:1326],[1327:1608],[1609:1624],[1625:1640],[1641:1656]};
iNumCond  = length(acConditionNames);
a2fPSTH_subset = zeros(iNumCond ,length(strctUnit.m_aiPeriStimulusRangeMS));
for iCondIter=1:iNumCond 
    a2fPSTH_subset(iCondIter,:) = nanmean( strctUnit.m_a2fAvgFirintRate_Stimulus(acConditionIndices{iCondIter},:));
end
h2 = tightsubplot(3,2,2,'Spacing',0.05,'Parent',ahPanels(1));
plot(h2, strctUnit.m_aiPeriStimulusRangeMS, a2fPSTH_subset(1:5,:));hold on;
plot(h2, strctUnit.m_aiPeriStimulusRangeMS, a2fPSTH_subset(6:10,:),'--');
hl=legend(acConditionNames,'Location','NorthEastOutside');
set(h2,'Position',[  0.3141    0.6410    0.4244    0.3340]);

ahSubPlots = [h1,h2];

strctUnit.m_strctCartoonANOVA
strctUnit.m_strctCartoonFeatureTuning
strctUnit.m_strctContrastPair11Parts
strctUnit.m_strctContrastPair8Parts
strctUnit.m_strctCroppedAnalysis
strctUnit.m_strctFaceSelectivity
strctUnit.m_strctHairComparison
strctUnit.m_strctIntensityTuning11Parts
strctUnit.m_strctIntensityTuning8Parts
strctUnit.m_strctQuality
strctUnit.m_strctSinhaFeatureTuning
strctUnit.m_strctSinhaPartsCorrectFeaturesANOVA
strctUnit.m_strctSinhaPartsIncorrectFeaturesANOVA



