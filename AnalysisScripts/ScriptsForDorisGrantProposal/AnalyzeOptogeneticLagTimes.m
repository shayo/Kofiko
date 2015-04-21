acFiles = {'E:\Data\Doris\Electrophys\Benjamin\Optogenetics\140303\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-03-03_14-00-53_Exp_NaN_Ch_017_Unit_017_Passive_Fixation_New_FOB_Microstim_lag0_50ms.mat',...
'E:\Data\Doris\Electrophys\Benjamin\Optogenetics\140303\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-03-03_14-00-53_Exp_NaN_Ch_017_Unit_017_Passive_Fixation_New_FOB_Microstim_lag50_50ms.mat',...
'E:\Data\Doris\Electrophys\Benjamin\Optogenetics\140303\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-03-03_14-00-53_Exp_NaN_Ch_017_Unit_017_Passive_Fixation_New_FOB_Microstim_lag100_50ms.mat',...
'E:\Data\Doris\Electrophys\Benjamin\Optogenetics\140303\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-03-03_14-00-53_Exp_NaN_Ch_017_Unit_017_Passive_Fixation_New_FOB_Microstim_lag150_50ms.mat',...
'E:\Data\Doris\Electrophys\Benjamin\Optogenetics\140303\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-03-03_14-00-53_Exp_NaN_Ch_017_Unit_017_Passive_Fixation_New_FOB_Microstim_lag200_50ms.mat'};

    figure(11);
    clf;    

for k=1:5
    strctTmp = load(acFiles{k});
    strctUnit = strctTmp.strctUnit;
    subplot(5,1,k);
    afMeanNonFaces = mean(strctUnit.m_a2fAvgFirintRate_Stimulus(17:36,:),1);
    afMeanFaces = mean(strctUnit.m_a2fAvgFirintRate_Stimulus(1:4,:),1);
    
    afMeanStimFaces = mean(strctUnit.m_a2fAvgFirintRate_Stimulus(37:40,:),1);
    afMeanStimNonFaces = mean(strctUnit.m_a2fAvgFirintRate_Stimulus(41:60,:),1);
    
    plot(strctUnit.m_aiPeriStimulusRangeMS, afMeanNonFaces,'k')
    hold on;
    plot(strctUnit.m_aiPeriStimulusRangeMS, afMeanFaces,'r')
    hold on; plot(strctUnit.m_aiPeriStimulusRangeMS,    afMeanStimFaces,'c');
    hold on; plot(strctUnit.m_aiPeriStimulusRangeMS,    afMeanStimNonFaces,'k--');
    set(gca,'xlim',[-50 300])
    
end
legend({'Non Faces','Faces','Faces+Stim','Non Faces+Stim'},'Location','NorthOutside');

