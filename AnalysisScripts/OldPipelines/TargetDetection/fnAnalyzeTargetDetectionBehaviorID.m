function strctStatistics =  fnAnalyzeTargetDetectionBehaviorID(strctStatistics, astrctTrials,acObjectNames, strctKofiko, strctConfig)
%% Extracts SyncTime from Kofiko data structure
if isfield(strctKofiko.g_strctDAQParams,'StimulusServerSync')
    SyncTime = strctKofiko.g_strctDAQParams.StimulusServerSync;
else
    iParadigmIndex = fnFindParadigmIndex(strctKofiko, 'Target Detection');
    SyncTime = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.SyncTime;
end
%%

fFlipStimulusON_TS_Kofiko = fnStimulusServerTimeToKofikoTime(SyncTime, astrctTrials{10}.m_fFlipStimulusON_TS_StimulusServer);
fResponseTime = astrctTrials{10}.m_fTrialEndTimeLocal-fFlipStimulusON_TS_Kofiko

iIndexOfSaccadedObjectInArray = find(astrctTrials{10}.m_iGazedAtObject == astrctTrials{10}.m_aiSelectedObjects)

astrctTrials{10}.m_apt2fPos(:,iIndexOfSaccadedObjectInArray )
return;
