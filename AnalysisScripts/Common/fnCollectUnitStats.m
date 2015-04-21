function acUnitsStat = fnCollectUnitStats(strctConfig,strctKofiko, strctPlexon, strctSession, iExperimentIndex)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

% This function analyzes the information from the recorded units according
% to the paradigm
% 


% % This is no longer true. There are multiple paradigms in each recorded session!

if isfield(strctKofiko.g_strctAppConfig,'ParadigmSwitch')
    % Easiler to know which paradigm started when...
    afParadigmSwitchTS_Kofiko = strctKofiko.g_strctAppConfig.ParadigmSwitch.TimeStamp;
    acstrParadigmNames = strctKofiko.g_strctAppConfig.ParadigmSwitch.Buffer;
else
    % Older way to extract this information (using the Log...)

    % This is from the entire day
    afParadigmSwitchTS_Kofiko = ...
        strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(strctKofiko.g_strctDAQParams.LastStrobe.Buffer == strctKofiko.g_strctSystemCodes.m_iParadigmSwitch);
    iNumSwitches = length(afParadigmSwitchTS_Kofiko);
    acstrParadigmNames = cell(1,iNumSwitches);
    for k=1:iNumSwitches
        iIndex = find(strctKofiko.g_strctLog.Log.TimeStamp > afParadigmSwitchTS_Kofiko(k),1,'first');
        acstrParadigmNames{k} = strctKofiko.g_strctLog.Log.Buffer{iIndex}(23:end);
    end;
end

% Find out which ones are in the recorded interval
iStartIndex = find(afParadigmSwitchTS_Kofiko <= strctSession.m_fKofikoStartTS,1,'last');
iEndIndex = find(afParadigmSwitchTS_Kofiko <= strctSession.m_fKofikoEndTS,1,'last');
acParadigmsRecorded = unique(acstrParadigmNames(iStartIndex:iEndIndex));

iNumAnalysisAvailableInConfigFile = length(strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis);
acUnitsStat = [];
for k=1:iNumAnalysisAvailableInConfigFile
    if ismember(strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{k}.m_strctGeneral.m_strParadigmName,acParadigmsRecorded)
        acUnitsStat = [acUnitsStat,feval(strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{k}.m_strctGeneral.m_strStatisticsFunction, ...
            strctKofiko, strctPlexon, strctSession,iExperimentIndex,strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{k})];
        
        if isfield(strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{k}.m_strctGeneral,'m_strMultiChannelStatisticsFunction') && ...
             ~isempty(strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{k}.m_strctGeneral.m_strMultiChannelStatisticsFunction)
            acUnitsStat = [feval(strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{k}.m_strctGeneral.m_strMultiChannelStatisticsFunction, ...
                acUnitsStat,strctKofiko, strctPlexon, strctSession,iExperimentIndex,strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{k})];
        end        
    end
end
abIsEmpty = zeros(1,length(acUnitsStat)) > 0;
for k=1:length(acUnitsStat)
    abIsEmpty(k) =  isempty(acUnitsStat{k});
end
acUnitsStat = acUnitsStat(~abIsEmpty);
%fnWorkerLog('************ No analysis function defined for paradigm %s. Skipping that one... *************',strParadigmName);
%acUnitsStat = [];
return;

