function [strctSession,strctPlexon,iSession] = fnExtractSingleSessionInfo(strctKofiko, strctPlexon, strctSystemCodes, iSession)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_bVERBOSE

bOverridePlexonWordsWithKofikoWords = false;


% Load things into memory
aiKofikoStartInd = find(strctKofiko.g_strctDAQParams.LastStrobe.Buffer == strctSystemCodes.m_iStartRecord);
aiKofikoStartRecTS = strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(aiKofikoStartInd);

aiKofikoEndInd = find(strctKofiko.g_strctDAQParams.LastStrobe.Buffer == strctSystemCodes.m_iStopRecord);
aiKofikoEndRecTS = strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(aiKofikoEndInd);

aiPlexonStartInd = find(strctPlexon.m_strctStrobeWord.m_aiWords == strctSystemCodes.m_iStartRecord);
aiPlexonStartRecTS = strctPlexon.m_strctStrobeWord.m_afTimestamp(aiPlexonStartInd);
aiPlexonEndInd = find(strctPlexon.m_strctStrobeWord.m_aiWords == strctSystemCodes.m_iStopRecord);
aiPlexonEndRecTS = strctPlexon.m_strctStrobeWord.m_afTimestamp(aiPlexonEndInd);

if length(aiKofikoEndInd) ~= length(aiKofikoStartInd)
    fnWorkerLog('Critical problem detected in kofiko file. Trying to recover...');
    if length(aiKofikoStartInd) >  length(aiKofikoEndInd) && ~isempty(aiPlexonEndInd) && length(aiPlexonEndInd) == length(aiPlexonStartInd)
        aiKofikoEndInd = aiKofikoStartInd + aiPlexonEndInd-aiPlexonStartInd;
    else

        strctSession = [];
        return;
    end
end

aiPlexonIntervalLength = aiPlexonEndInd-aiPlexonStartInd;
aiKofikoIntervalLength = aiKofikoEndInd-aiKofikoStartInd;




if bOverridePlexonWordsWithKofikoWords
    aiKofikoInterval = aiKofikoStartInd(iSession):aiKofikoEndInd(iSession);
    aiKofikoWords = squeeze(strctKofiko.g_strctDAQParams.LastStrobe.Buffer(aiKofikoInterval));

    aiPlexonInterval = aiPlexonStartInd:aiPlexonEndInd;
    aiPlexonWords = squeeze(strctPlexon.m_strctStrobeWord.m_aiWords(aiPlexonInterval));
    

    
    aiKofikoToPlexonIndexMatching = fnSubStringMatching(aiKofikoWords, aiPlexonWords);
    
    % Generate fixed plexon words from kofiko data....
    
    % Interpolate unmatched events....
    aiMatchedWords = find(aiKofikoToPlexonIndexMatching ~= 0);
    afMatchedTS = strctPlexon.m_strctStrobeWord.m_afTimestamp(aiKofikoToPlexonIndexMatching(aiMatchedWords));
    
    aiUnmatchedWords = find(aiKofikoToPlexonIndexMatching == 0);
    afExtraplotedTS = interp1( aiMatchedWords, afMatchedTS, aiUnmatchedWords,'linear','extrap');
    
    afNewPlexonTS = zeros(1,length(aiKofikoWords));
    afNewPlexonTS(aiMatchedWords) = afMatchedTS;
    afNewPlexonTS(aiUnmatchedWords) = afExtraplotedTS;
    
    strctPlexon.m_strctStrobeWord.m_aiWords = aiKofikoWords;
    strctPlexon.m_strctStrobeWord.m_afTimestamp = afNewPlexonTS;
    
    aiPlexonStartInd = 1;
    aiPlexonStartRecTS = 1;
    
    aiPlexonEndInd = length(aiKofikoWords);
    aiPlexonEndRecTS = afNewPlexonTS(end);
    
    aiPlexonIntervalLength = aiPlexonEndInd-aiPlexonStartInd;
  
     
end









if ~((all(aiKofikoEndInd(iSession)-aiKofikoStartInd(iSession) == aiPlexonEndInd-aiPlexonStartInd)))
   fnWorkerLog('Critical problem detected. Number of strobe words mismatch. Trying to recover...');
    aiKofikoInterval = aiKofikoStartInd(iSession):aiKofikoEndInd(iSession);
    aiKofikoWords = squeeze(strctKofiko.g_strctDAQParams.LastStrobe.Buffer(aiKofikoInterval));

    aiPlexonInterval = aiPlexonStartInd:aiPlexonEndInd;
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
         fnWorkerLog('OK. Managed to recover...');
        % Try to remove
    else 
        % Very strange!!! Happened in 091124 (old Rocco Session)
        % Try to match with another kofiko recording session ?
        iCorrectSessionIndex = find(aiPlexonIntervalLength == aiKofikoIntervalLength);
        if isempty(iCorrectSessionIndex)
            
  
            assert(false);
         
        else
            if ~all(aiKofikoEndInd(iCorrectSessionIndex)-aiKofikoStartInd(iCorrectSessionIndex) == aiPlexonEndInd-aiPlexonStartInd)
                assert(false);
            else
                fnWorkerLog('CRITICAL WARNING!!!');
                fnWorkerLog('Found a mismatch in session index number. But, managed to recover...');
                iSession = iCorrectSessionIndex;
            end
        end
    end
end



assert((all(aiKofikoEndInd(iSession)-aiKofikoStartInd(iSession) == aiPlexonEndInd-aiPlexonStartInd)));

% Makre sure actual strobe words are correct

aiKofikoInterval = aiKofikoStartInd(iSession):aiKofikoEndInd(iSession);
aiKofikoWords = squeeze(strctKofiko.g_strctDAQParams.LastStrobe.Buffer(aiKofikoInterval));

aiPlexonInterval = aiPlexonStartInd:aiPlexonEndInd;
aiPlexonWords = squeeze(strctPlexon.m_strctStrobeWord.m_aiWords(aiPlexonInterval));

%
% 	figure(11);
%     clf;
%     plot(aiKofikoWords,'b.');
%     hold on;
%     plot(aiPlexonWords,'ro');
%


if ~all(aiKofikoWords == aiPlexonWords)
    % Silly thing from a bug in MEX file. Remove this in the future.
    aiInd = find(aiKofikoWords ~= aiPlexonWords);
    if all(aiPlexonWords(aiInd) == 0)
        aiPlexonWords(aiInd) = aiKofikoWords(aiInd);
    else
              assert(false);
       end
end

% Match the sync strobe events to compute the clock deviations between
% the two computers...

afKofikoSyncTS = strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(aiKofikoInterval(aiKofikoWords == strctKofiko.g_strctSystemCodes.m_iSync));
afPlexonSyncTS = strctPlexon.m_strctStrobeWord.m_afTimestamp(aiPlexonInterval(aiPlexonWords == strctKofiko.g_strctSystemCodes.m_iSync))';

if isempty(afKofikoSyncTS) && isempty(afPlexonSyncTS)
    fnWorkerLog('Empty Session?');
    strctSession = []; % Empty Session...
    return;
end

% % afKofikoSyncTS_ZeroOffset = afKofikoSyncTS-afKofikoSyncTS(1);
% % afPlexonSyncTS_ZeroOffset = afPlexonSyncTS-afPlexonSyncTS(1);
% % iNumStrobeWords = length(afKofikoSyncTS);

% % if iNumStrobeWords < 10
% %    % afPlexonTime = linspace(0,afPlexonSyncTS_ZeroOffset(end),iNumStrobeWords);
% %     afKofikoTime = linspace(0,afKofikoSyncTS_ZeroOffset(end),iNumStrobeWords);
% %     afX = afKofikoTime;
% %     afY = afPlexonSyncTS_ZeroOffset-afKofikoSyncTS_ZeroOffset;
% %     afTmp = pinv([afX; ones(1,length(afX))]') * afY';
% %     afLineFit = afTmp([2,1]);
% % else
% %  %   afPlexonTime = linspace(0,afPlexonSyncTS_ZeroOffset(end),iNumStrobeWords);
% %     afKofikoTime = linspace(0,afKofikoSyncTS_ZeroOffset(end),iNumStrobeWords);
% %     warning off
% %     afLineFit = robustfit(afKofikoTime, afPlexonSyncTS_ZeroOffset-afKofikoSyncTS_ZeroOffset);
% %     warning on
% % end

%afDiffFromModel = afLineFit;
% estimate max deviation from linear model:
%afDiffFromModel2 = abs(afKofikoTime * afLineFit(2) +afLineFit(1) - (afPlexonSyncTS_ZeroOffset-afKofikoSyncTS_ZeroOffset));
%afMaxDeviationFromRegressionModel = max(afDiffFromModel2)*1e3;
%     hold on;
%     plot(afKofikoTS-afKofikoTS(1));
%     plot(afPlexonTS-afPlexonTS(1),'r');
% % 
% % if g_bVERBOSE
% %     figure(1);
% %     clf;hold on;
% %     plot(afKofikoTime,afPlexonSyncTS_ZeroOffset-afKofikoSyncTS_ZeroOffset);
% %     plot(afKofikoTime ,afKofikoTime * afLineFit(2) +afLineFit(1),'r')
% %     xlabel('Time on Kofiko Machine');
% %     ylabel('Timestamp difference(in sec)');
% % end;

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

% afParadigmSwitchTS_Kofiko = ...
%     strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(strctKofiko.g_strctDAQParams.LastStrobe.Buffer == strctSystemCodes.m_iParadigmSwitch);
% iNumSwitches = length(afParadigmSwitchTS_Kofiko);
% acstrParadigmSwitchNames = cell(1,iNumSwitches);
% 
% for k=1:iNumSwitches
%     iIndex = find(strctKofiko.g_strctLog.Log.TimeStamp > afParadigmSwitchTS_Kofiko(k),1,'first');
%     acstrParadigmSwitchNames{k} = strctKofiko.g_strctLog.Log.Buffer{iIndex}(23:end);
% end;


% Match paradigm name to the start of recording

strctSession.m_fKofikoStartTS = aiKofikoStartRecTS(iSession);
strctSession.m_fPlexonStartTS = aiPlexonStartRecTS;
strctSession.m_fKofikoEndTS = aiKofikoEndRecTS(iSession);
strctSession.m_fPlexonEndTS = aiPlexonEndRecTS;
strctSession.m_iNumStrobeWords = aiKofikoEndInd(iSession)-aiKofikoStartInd(iSession)+1;
strctSession.m_aiKofikoStrobeInterval = aiKofikoStartInd(iSession):aiKofikoEndInd(iSession);
strctSession.m_aiPlexonStrobeInterval = aiPlexonStartInd:aiPlexonEndInd;

aiKofikoInterval = aiKofikoStartInd(iSession):aiKofikoEndInd(iSession);
aiKofikoWords = squeeze(strctKofiko.g_strctDAQParams.LastStrobe.Buffer(aiKofikoInterval));
aiPlexonInterval = aiPlexonStartInd:aiPlexonEndInd;
aiPlexonWords = squeeze(strctPlexon.m_strctStrobeWord.m_aiWords(aiPlexonInterval));

strctSession.m_afKofikoSyncTS = strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(aiKofikoInterval(aiKofikoWords == strctKofiko.g_strctSystemCodes.m_iSync));
strctSession.m_afPlexonSyncTS = strctPlexon.m_strctStrobeWord.m_afTimestamp(aiPlexonInterval(aiPlexonWords == strctKofiko.g_strctSystemCodes.m_iSync))';

%strctSession.m_afKofikoTStoPlexonTS = afDiffFromModel';
% to go from a kofiko timestamp (Tsk) in session j to plexon timestamp, use the following
% steps:
% D = Tsk - Tsk0     ( subtract the first timestamp in session j)
% Tsp = Tsp0 + (Tsk-Tsk0) + D * m_afKofikoTStoPlexonTS(2) + m_afKofikoTStoPlexonTS(1)

fnWorkerLog('Recorded experiment %d , (%.2f Min) \n', iSession,...
    (aiKofikoEndRecTS(iSession)-aiKofikoStartRecTS(iSession))/60);

return;
