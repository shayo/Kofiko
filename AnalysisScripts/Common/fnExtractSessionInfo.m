function [astrctSession,strctPlexon] = fnExtractSessionInfo(strctKofiko, strctPlexon, strctSystemCodes)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_bVERBOSE

bUseAsserts = true;

% Load things into memory
aiKofikoStartInd = find(strctKofiko.g_strctDAQParams.LastStrobe.Buffer == strctSystemCodes.m_iStartRecord);
aiKofikoStartRecTS = strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(aiKofikoStartInd);

aiKofikoEndInd = find(strctKofiko.g_strctDAQParams.LastStrobe.Buffer == strctSystemCodes.m_iStopRecord);
aiKofikoEndRecTS = strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(aiKofikoEndInd);


if 0
    % If plexon has an extra strobe word, this will fix things up....
    iProblematicInterval = 4;
    
    aiKofikoInterval = aiKofikoStartInd(iProblematicInterval):aiKofikoEndInd(iProblematicInterval);
    aiKofikoWords = squeeze(strctKofiko.g_strctDAQParams.LastStrobe.Buffer(aiKofikoInterval));
    aiPlexonStartInd = find(strctPlexon.m_strctStrobeWord.m_aiWords == strctSystemCodes.m_iStartRecord);
    aiPlexonEndInd = find(strctPlexon.m_strctStrobeWord.m_aiWords == strctSystemCodes.m_iStopRecord);
    
    aiPlexonInterval = aiPlexonStartInd(iProblematicInterval):aiPlexonEndInd(iProblematicInterval);
    aiPlexonWords = squeeze(strctPlexon.m_strctStrobeWord.m_aiWords(aiPlexonInterval));
    
    iMinLen = min(length(aiKofikoWords), length(aiPlexonWords));
    iStartProblem = find(aiKofikoWords(1:iMinLen) ~= aiPlexonWords(1:iMinLen),1,'first');
    aiPlexonInterval = aiPlexonStartInd(iProblematicInterval):aiPlexonEndInd(iProblematicInterval);
    iIndex = aiPlexonInterval(iStartProblem);
    strctPlexon.m_strctStrobeWord.m_afTimestamp = strctPlexon.m_strctStrobeWord.m_afTimestamp([1:iIndex-1, iIndex+1:end]);
    strctPlexon.m_strctStrobeWord.m_aiWords  = strctPlexon.m_strctStrobeWord.m_aiWords([1:iIndex-1, iIndex+1:end]);
    
    
    
    aiPlexonStartInd = find(strctPlexon.m_strctStrobeWord.m_aiWords == strctSystemCodes.m_iStartRecord);
    aiPlexonStartRecTS = strctPlexon.m_strctStrobeWord.m_afTimestamp(aiPlexonStartInd);
    aiPlexonEndInd = find(strctPlexon.m_strctStrobeWord.m_aiWords == strctSystemCodes.m_iStopRecord);
    aiPlexonEndRecTS = strctPlexon.m_strctStrobeWord.m_afTimestamp(aiPlexonEndInd);
    
    aiPlexonIntervalLength = aiPlexonEndInd-aiPlexonStartInd;
    aiKofikoIntervalLength = aiKofikoEndInd-aiKofikoStartInd;
    
end


aiPlexonStartInd = find(strctPlexon.m_strctStrobeWord.m_aiWords == strctSystemCodes.m_iStartRecord);
aiPlexonStartRecTS = strctPlexon.m_strctStrobeWord.m_afTimestamp(aiPlexonStartInd);
aiPlexonEndInd = find(strctPlexon.m_strctStrobeWord.m_aiWords == strctSystemCodes.m_iStopRecord);
aiPlexonEndRecTS = strctPlexon.m_strctStrobeWord.m_afTimestamp(aiPlexonEndInd);

if length(aiPlexonStartInd) > length(aiPlexonEndInd)
    fnWorkerLog('CRITICAL ERROR !!! WARNING:');
    fnWorkerLog('* There are more Start recording events that end recording events!');
    fnWorkerLog('Trying to recover data by cropping unmatched sessions');
    iNumSessions = length(aiPlexonEndInd);
    aiPlexonStartInd = aiPlexonStartInd(1:iNumSessions);
    aiKofikoEndInd = aiKofikoEndInd(1: iNumSessions);
    aiKofikoStartInd = aiKofikoStartInd(1: iNumSessions);
    
end

aiPlexonIntervalLength = aiPlexonEndInd-aiPlexonStartInd;
aiKofikoIntervalLength = aiKofikoEndInd-aiKofikoStartInd;

% The number of intervals WILL NOT Match...if:
% Two reasons:
% 1. We forgot to press the "Start Record" in plexon
% 2. We accidently pressed "Stop Record" early.
% This thing will only handle events of the first type
%
%
if length(aiPlexonIntervalLength) < length(aiKofikoIntervalLength)
    iNewStart = find(aiKofikoIntervalLength == aiPlexonIntervalLength(1));
    iNewEnd = find(aiKofikoIntervalLength == aiPlexonIntervalLength(end));
    
    fnWorkerLog('WARNING');
    fnWorkerLog('* The first %d Kofiko intervals were discarded because the corresponding Plexon intervals are missing!',iNewStart-1);
    aiKofikoStartInd = aiKofikoStartInd(iNewStart:iNewEnd);
    aiKofikoStartRecTS = aiKofikoStartRecTS(iNewStart:iNewEnd);
    aiKofikoEndInd = aiKofikoEndInd(iNewStart:iNewEnd);
    aiKofikoEndRecTS = aiKofikoEndRecTS(iNewStart:iNewEnd);
end;

if ~((all(aiKofikoEndInd-aiKofikoStartInd == aiPlexonEndInd-aiPlexonStartInd)))
    fnWorkerLog('Critical problem detected. Number of strobe words mismatch. Trying to recover...');
    iProblematicSession = find(aiKofikoEndInd-aiKofikoStartInd  ~= aiPlexonEndInd-aiPlexonStartInd);
    if length(iProblematicSession) > 1
        fnWorkerLog('More than one problematic session detected. Go and talk with Shay.');
        assert(false);
    end
    
    aiKofikoInterval = aiKofikoStartInd(iProblematicSession):aiKofikoEndInd(iProblematicSession);
    aiKofikoWords = squeeze(strctKofiko.g_strctDAQParams.LastStrobe.Buffer(aiKofikoInterval));
    
    aiPlexonInterval = aiPlexonStartInd(iProblematicSession):aiPlexonEndInd(iProblematicSession);
    aiPlexonWords = squeeze(strctPlexon.m_strctStrobeWord.m_aiWords(aiPlexonInterval));
    iDiff = length(aiPlexonWords)-length(aiKofikoWords);
    if iDiff == 1
        
        iProblematicWord = find(aiPlexonWords(1:end-iDiff) ~= aiKofikoWords,1,'first');
        assert(all(aiPlexonWords([1:iProblematicWord-1,iProblematicWord+1:end]) == aiKofikoWords))
        
        strctPlexon.m_strctStrobeWord.m_aiWords(aiPlexonInterval(1) + iProblematicWord-1) = [];
        strctPlexon.m_strctStrobeWord.m_afTimestamp(aiPlexonInterval(1) + iProblematicWord-1) = [];
        
        
        aiPlexonStartInd = find(strctPlexon.m_strctStrobeWord.m_aiWords == strctSystemCodes.m_iStartRecord);
        aiPlexonStartRecTS = strctPlexon.m_strctStrobeWord.m_afTimestamp(aiPlexonStartInd);
        aiPlexonEndInd = find(strctPlexon.m_strctStrobeWord.m_aiWords == strctSystemCodes.m_iStopRecord);
        aiPlexonEndRecTS = strctPlexon.m_strctStrobeWord.m_afTimestamp(aiPlexonEndInd);
        
        aiPlexonIntervalLength = aiPlexonEndInd-aiPlexonStartInd;
        aiKofikoIntervalLength = aiKofikoEndInd-aiKofikoStartInd;
        assert(all(aiKofikoIntervalLength==aiPlexonIntervalLength));
        fnWorkerLog('OK. Managed to recover...');
        % Try to remove
    else
        
        % Multiple errors... What the hell?
        % Assume that plexon has errorounsly duplicated strobe words ?
        % Find the longest stretch of same words...this is going to be SLOW
        % !!!
        %X=fnLongestCommonString(aiPlexonWords',aiKofikoWords');
        
        fnWorkerLog('Failed to automatically recover from this error. Call Shay. You probably have a wiring issue problem...');
        if bUseAsserts
            assert(false);
        else
            
        end
    end
end




% Makre sure actual strobe words are correct
iNumSessions = length(aiKofikoStartInd);
%a2fDiffFromModel = zeros(2,iNumSessions);
% figure(1);
% clf;
%afMaxDeviationFromRegressionModel = zeros(1,iNumSessions);

for k=1:iNumSessions
    aiKofikoInterval = aiKofikoStartInd(k):aiKofikoEndInd(k);
    aiKofikoWords = squeeze(strctKofiko.g_strctDAQParams.LastStrobe.Buffer(aiKofikoInterval));
    
    aiPlexonInterval = aiPlexonStartInd(k):aiPlexonEndInd(k);
    aiPlexonWords = squeeze(strctPlexon.m_strctStrobeWord.m_aiWords(aiPlexonInterval));
    if bUseAsserts
        assert(all(aiKofikoWords == aiPlexonWords));
    end
end

if 0
    %     iMinLen = min(length(aiKofikoWords), length(aiPlexonWords));
    %     iStartProblem = find(aiKofikoWords(1:iMinLen) ~= aiPlexonWords(1:iMinLen),1,'first')
    %     [aiKofikoWords(iStartProblem-1:iStartProblem + 15)';
    %     aiPlexonWords(iStartProblem-1:iStartProblem + 15)']
    
    
    %
    % 	figure(11);
    %     clf;
    %     plot(aiKofikoWords,'b.');
    %     hold on;
    %     plot(aiPlexonWords,'ro');
    %
    
    % Match the sync strobe events to compute the clock deviations between
    % the two computers...
    
    afKofikoSyncTS = strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(aiKofikoInterval(aiKofikoWords == strctKofiko.g_strctSystemCodes.m_iSync));
    afPlexonSyncTS = strctPlexon.m_strctStrobeWord.m_afTimestamp(aiPlexonInterval(aiPlexonWords == strctKofiko.g_strctSystemCodes.m_iSync))';
    
    afKofikoSyncTS_ZeroOffset = afKofikoSyncTS-afKofikoSyncTS(1);
    afPlexonSyncTS_ZeroOffset = afPlexonSyncTS-afPlexonSyncTS(1);
    iNumStrobeWords = length(afKofikoSyncTS);
    
    if iNumStrobeWords < 10
        afPlexonTime = linspace(0,afPlexonSyncTS_ZeroOffset(end),iNumStrobeWords);
        afKofikoTime = linspace(0,afKofikoSyncTS_ZeroOffset(end),iNumStrobeWords);
        afX = afKofikoTime;
        afY = afPlexonSyncTS_ZeroOffset-afKofikoSyncTS_ZeroOffset;
        afTmp = pinv([afX; ones(1,length(afX))]') * afY';
        afLineFit = afTmp([2,1]);
    else
        afPlexonTime = linspace(0,afPlexonSyncTS_ZeroOffset(end),iNumStrobeWords);
        afKofikoTime = linspace(0,afKofikoSyncTS_ZeroOffset(end),iNumStrobeWords);
        warning off
        afLineFit = robustfit(afKofikoTime, afPlexonSyncTS_ZeroOffset-afKofikoSyncTS_ZeroOffset);
        warning on
    end
    
    %    a2fDiffFromModel(:,k) = afLineFit;
    % estimate max deviation from linear model:
    %    afDiffFromModel = abs(afKofikoTime * afLineFit(2) +afLineFit(1) - (afPlexonSyncTS_ZeroOffset-afKofikoSyncTS_ZeroOffset));
    %    afMaxDeviationFromRegressionModel(k) = max(afDiffFromModel)*1e3;
    %     hold on;
    %     plot(afKofikoTS-afKofikoTS(1));
    %     plot(afPlexonTS-afPlexonTS(1),'r');
    
    if g_bVERBOSE
        figure(k);
        clf;hold on;
        plot(afKofikoTime,afPlexonSyncTS_ZeroOffset-afKofikoSyncTS_ZeroOffset);
        plot(afKofikoTime ,afKofikoTime * afLineFit(2) +afLineFit(1),'r')
        xlabel('Time on Kofiko Machine');
        ylabel('Timestamp difference(in sec)');
    end;

end

% Plexon does not know which paradigm was started. This information is only
% stored in Kofiko data structure.
%
% Every time the user changes a paradigm, a
% strctSystemCodes.m_iParadigmSwitch code is sent to plexon.
% However, this code typically does not arrive because we can't change a
% paradigm while recording in plexon....

% The following corresponding line is added to the log:
% fnLOG('Switching to paradigm %s',g_strctParadigm.m_strName);
%

afParadigmSwitchTS_Kofiko = ...
    strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(strctKofiko.g_strctDAQParams.LastStrobe.Buffer == strctSystemCodes.m_iParadigmSwitch);
iNumSwitches = length(afParadigmSwitchTS_Kofiko);
acstrParadigmSwitchNames = cell(1,iNumSwitches);

for k=1:iNumSwitches
    iIndex = find(strctKofiko.g_strctLog.Log.TimeStamp > afParadigmSwitchTS_Kofiko(k),1,'first');
    acstrParadigmSwitchNames{k} = strctKofiko.g_strctLog.Log.Buffer{iIndex}(23:end);
end;


% Match paradigm name to the start of recording
acSessionParadigm = cell(1,iNumSessions);
for k=1:iNumSessions
    iIndex = find(afParadigmSwitchTS_Kofiko < aiKofikoStartRecTS(k),1,'last');
%    acSessionParadigm{k} = acstrParadigmSwitchNames{iIndex};
%    astrctSession(k).m_strParadigmName = acSessionParadigm{k};
    astrctSession(k).m_fKofikoStartTS = aiKofikoStartRecTS(k);
    astrctSession(k).m_fPlexonStartTS = aiPlexonStartRecTS(k);
    astrctSession(k).m_fKofikoEndTS = aiKofikoEndRecTS(k);
    astrctSession(k).m_fPlexonEndTS = aiPlexonEndRecTS(k);
    astrctSession(k).m_iNumStrobeWords = aiKofikoEndInd(k)-aiKofikoStartInd(k)+1;
    astrctSession(k).m_aiKofikoStrobeInterval = aiKofikoStartInd(k):aiKofikoEndInd(k);
    astrctSession(k).m_aiPlexonStrobeInterval = aiPlexonStartInd(k):aiPlexonEndInd(k);
    
    %    astrctSession(k).m_afKofikoTStoPlexonTS = a2fDiffFromModel(:,k)';
    % to go from a kofiko timestamp (Tsk) in session j to plexon timestamp, use the following
    % steps:
    % D = Tsk - Tsk0     ( subtract the first timestamp in session j)
    % Tsp = Tsp0 + D + D * m_afKofikoTStoPlexonTS(2) + m_afKofikoTStoPlexonTS(1)
    
    aiKofikoInterval = aiKofikoStartInd(k):aiKofikoEndInd(k);
    aiKofikoWords = squeeze(strctKofiko.g_strctDAQParams.LastStrobe.Buffer(aiKofikoInterval));
    aiPlexonInterval = aiPlexonStartInd(k):aiPlexonEndInd(k);
    aiPlexonWords = squeeze(strctPlexon.m_strctStrobeWord.m_aiWords(aiPlexonInterval));
    astrctSession(k).m_afKofikoSyncTS = strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(aiKofikoInterval(aiKofikoWords == strctKofiko.g_strctSystemCodes.m_iSync));
    astrctSession(k).m_afPlexonSyncTS = strctPlexon.m_strctStrobeWord.m_afTimestamp(aiPlexonInterval(aiPlexonWords == strctKofiko.g_strctSystemCodes.m_iSync))';
    
    fnWorkerLog('Recorded experiment %d, (%.2f Min)', k,...
        (aiKofikoEndRecTS(k)-aiKofikoStartRecTS(k))/60);
end;

return;
