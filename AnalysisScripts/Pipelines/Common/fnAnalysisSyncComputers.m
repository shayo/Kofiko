function strctSync = fnAnalysisSyncComputers(strStrobeFile,strAnalogFile, strKofikoFile, strStatServerFile)

%% Plexon:
% Read all strobe words
% Read the A/D channel to find TS gaps which indicate different "frames"
strctPlexon.m_strctStrobeWord = fnReadDumpStrobeFile(strStrobeFile);

strctAnalogHeader = fnReadDumpAnalogFile(strAnalogFile,'ReadHeaderOnly');
% [iNumStrobeEvents, afStrobeTimeStamps, aiStrobeWordsInvBit] = plx_event_ts(strPlexonFile, 257);
% iChannel = 1;
%[fADFreq, iTotalNumberOfADSamplesNumSamples, afStartFrame, aiNumSamplesInFrame] = plx_ad_gap_info(strPlexonFile, iChannel);



Tmp = cumsum([1;strctAnalogHeader.m_aiNumSamplesPerFrame]);
strctPlexon.m_strctFrames.m_afStartTS_PLX = strctAnalogHeader.m_afStartTS;
strctPlexon.m_strctFrames.m_afEndTS_PLX = strctAnalogHeader.m_afStartTS+strctAnalogHeader.m_aiNumSamplesPerFrame/strctAnalogHeader.m_fSamplingFreq;
strctPlexon.m_strctFrames.m_aiStartAD_Ind = Tmp(1:end-1);
strctPlexon.m_strctFrames.m_aiEndAD_Ind = Tmp(2:end)-1;
strctPlexon.m_strctFrames.m_aiNumAD_Samples = strctAnalogHeader.m_aiNumSamplesPerFrame;
iNumPlexonFrames = length(strctPlexon.m_strctFrames.m_afStartTS_PLX);

for iFrameIter=1:iNumPlexonFrames
    fStartTS_PLX = strctPlexon.m_strctFrames.m_afStartTS_PLX(iFrameIter);
    fEndTS_PLX = strctPlexon.m_strctFrames.m_afEndTS_PLX(iFrameIter);
    
    aiPlexonStrobeWordInterval = find(strctPlexon.m_strctStrobeWord.m_afTimestamp >= fStartTS_PLX & ...
                                      strctPlexon.m_strctStrobeWord.m_afTimestamp <= fEndTS_PLX);
    strctPlexon.m_strctFrames.m_aiStartStrobe_Ind(iFrameIter) = aiPlexonStrobeWordInterval(1);
    strctPlexon.m_strctFrames.m_aiEndStrobe_Ind(iFrameIter) = aiPlexonStrobeWordInterval(end);
    strctPlexon.m_strctFrames.m_aiNumStrobeWord(iFrameIter) = length(aiPlexonStrobeWordInterval);
end


%% Kofiko 
% Load structure and find how many times the user pressed start
% recording...
strctKofiko = load(strKofikoFile);

aiKofikoStartInd = find(strctKofiko.g_strctDAQParams.LastStrobe.Buffer == strctKofiko.g_strctSystemCodes.m_iStartRecord);
aiKofikoStartRecTS = strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(aiKofikoStartInd);
aiKofikoEndInd = find(strctKofiko.g_strctDAQParams.LastStrobe.Buffer == strctKofiko.g_strctSystemCodes.m_iStopRecord);
aiKofikoEndRecTS = strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(aiKofikoEndInd);
aiNumStrobeWordsSentByKofikoToPlexon = aiKofikoEndInd-aiKofikoStartInd+1;
iNumKofikoFrames = length(aiKofikoStartInd);

%% Sanity checks
if iNumKofikoFrames ~= iNumPlexonFrames
    fprintf('Kofiko recorded when plexon was not listening...!\n');
    fprintf('Attempting to recover....\n');
    % Assume this happened only for the first or last frames....
    if length(aiNumStrobeWordsSentByKofikoToPlexon) > length(strctPlexon.m_strctFrames.m_aiNumStrobeWord)
            iMinLength = length(strctPlexon.m_strctFrames.m_aiNumStrobeWord);
            if all(aiNumStrobeWordsSentByKofikoToPlexon(1:iMinLength) == strctPlexon.m_strctFrames.m_aiNumStrobeWord)
                 % Drop last Kofiko recorded session.
                 iNumKofikoFrames = iNumKofikoFrames -1 ;
                 aiNumStrobeWordsSentByKofikoToPlexon = aiNumStrobeWordsSentByKofikoToPlexon(1:iMinLength);
                 aiKofikoStartInd = aiKofikoStartInd(1:iMinLength);
                 aiKofikoStartRecTS = aiKofikoStartRecTS(1:iMinLength);
                 aiKofikoEndInd=aiKofikoEndInd(1:iMinLength);
                 aiKofikoEndRecTS=aiKofikoEndRecTS(1:iMinLength);
            else
                assert(false);
            end
    else
        for k=1:50
            fprintf('Warning, running a dirty hack to sync things. This will probably not work on your session\n');
        end
        % Weird. Hacking to fix this....
        % Get rid of the first plexon frame?
        iSelectedPlexonFrame = 2;
        strctPlexon.m_strctFrames.m_afStartTS_PLX= strctPlexon.m_strctFrames.m_afStartTS_PLX(iSelectedPlexonFrame);
        strctPlexon.m_strctFrames.m_afEndTS_PLX= strctPlexon.m_strctFrames.m_afEndTS_PLX(iSelectedPlexonFrame);
        strctPlexon.m_strctFrames.m_aiStartAD_Ind= strctPlexon.m_strctFrames.m_aiStartAD_Ind(iSelectedPlexonFrame);
        strctPlexon.m_strctFrames.m_aiEndAD_Ind= strctPlexon.m_strctFrames.m_aiEndAD_Ind(iSelectedPlexonFrame);
        strctPlexon.m_strctFrames.m_aiNumAD_Samples= strctPlexon.m_strctFrames.m_aiNumAD_Samples(iSelectedPlexonFrame);
        strctPlexon.m_strctFrames.m_aiStartStrobe_Ind= strctPlexon.m_strctFrames.m_aiStartStrobe_Ind(iSelectedPlexonFrame);
        strctPlexon.m_strctFrames.m_aiEndStrobe_Ind= strctPlexon.m_strctFrames.m_aiEndStrobe_Ind(iSelectedPlexonFrame);
        strctPlexon.m_strctFrames.m_aiNumStrobeWord= strctPlexon.m_strctFrames.m_aiNumStrobeWord(iSelectedPlexonFrame);
        iNumPlexonFrames = 1;
    end
    
end

if ~all(strctPlexon.m_strctFrames.m_aiNumStrobeWord(:) == aiNumStrobeWordsSentByKofikoToPlexon(:))
    [strP,strF]=fileparts(strKofikoFile);
    fprintf('Critical error: number of strobe word mismatch...!\n');
    acMsg{1} = sprintf('In %s',strF);
    acMsg{2} = 'Cannot Sync: number of strobe word mismatch.';
    acMsg{3} = 'Attempt to fix?';
    Res=questdlg(acMsg,'CRITICAL ERROR IN SYNC','Yes','Abort','Yes');
    if strcmp(Res,'Yes')
        
        if ~exist([strKofikoFile,'.backup'],'file')
            copyfile(strKofikoFile,[strKofikoFile,'.backup']);
        end
        if ~exist([strStrobeFile,'.backup'],'file')
            copyfile(strStrobeFile,[strStrobeFile,'.backup']);
        end
        
        fprintf('Trying to recover by matching longest string approach...This can take somet time...');
        aiAllNewPlexonStrobeWords = [];
        afAllNewPlexonStrobeWordsTS = [];
        aiNumStrobeWordsInFrame = [];
           g_strctDAQParams = strctKofiko.g_strctDAQParams;
        
       for iFrameIter=1:iNumPlexonFrames
           aiKofikoInterval = aiKofikoStartInd(iFrameIter):aiKofikoEndInd(iFrameIter);
           aiKofikoWords = squeeze(strctKofiko.g_strctDAQParams.LastStrobe.Buffer(aiKofikoInterval));
           afKofikoTS = squeeze(strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(aiKofikoInterval));
           aiPlexonInterval = strctPlexon.m_strctFrames.m_aiStartStrobe_Ind(iFrameIter):strctPlexon.m_strctFrames.m_aiEndStrobe_Ind(iFrameIter) ;
           aiPlexonWords = squeeze(strctPlexon.m_strctStrobeWord.m_aiWords(aiPlexonInterval));
           aiPlexonWordsTS = squeeze(strctPlexon.m_strctStrobeWord.m_afTimestamp(aiPlexonInterval));
           aiKofikoToPlexonIndexMatching = fnSubStringMatching(aiKofikoWords, aiPlexonWords);
           % Assume that strobe word sent by kofiko is the most reliable
           % thing. Receiver part may have missed/added extra strobe words
           % (happen somtimes...)
           %
           % i.e., aiKofikoWords == aiPlexonWords(aiKofikoToPlexonIndexMatching)
           
           
           aiMatchedWords = find(aiKofikoToPlexonIndexMatching ~= 0);
           afMatchedTS = aiPlexonWordsTS(aiKofikoToPlexonIndexMatching(aiMatchedWords)); % strctPlexon.m_strctStrobeWord.m_afTimestamp
           
           aiUnmatchedWords = find(aiKofikoToPlexonIndexMatching == 0);
           afExtraplotedTS = interp1( aiMatchedWords, afMatchedTS, aiUnmatchedWords,'linear','extrap');
           
           afNewPlexonTS = zeros(1,length(aiKofikoWords));
           afNewPlexonTS(aiMatchedWords) = afMatchedTS;
           afNewPlexonTS(aiUnmatchedWords) = afExtraplotedTS;
           aiPlexonWords = aiKofikoWords;
           
           abInvalidEntries = find(aiKofikoWords <= 0);
           aiKofikoWords(abInvalidEntries) = [];
           afKofikoTS(abInvalidEntries) = [];
           aiPlexonWords(abInvalidEntries) = [];
           afNewPlexonTS(abInvalidEntries) = [];
           aiKofikoInterval(abInvalidEntries) = [];
           
           % aiKofikoWords,    afKofikoTS
           % aiPlexonWords, afNewPlexonTS
           
           % Replace kofiko file
           g_strctDAQParams.LastStrobe.Buffer(aiKofikoInterval) = aiKofikoWords;
           g_strctDAQParams.LastStrobe.TimeStamp(aiKofikoInterval) = afKofikoTS;
           
           % Replace strobe file...
            aiAllNewPlexonStrobeWords = [aiAllNewPlexonStrobeWords;aiPlexonWords(:)];
            afAllNewPlexonStrobeWordsTS = [afAllNewPlexonStrobeWordsTS;afNewPlexonTS(:)];
           aiNumStrobeWordsInFrame(iFrameIter) = length(aiPlexonWords);
           
       end
                 save(strKofikoFile,'g_strctDAQParams','-append');
    
           
           strctPlexon.m_strctStrobeWord.m_aiWords = aiAllNewPlexonStrobeWords;
           strctPlexon.m_strctStrobeWord.m_afTimestamp = afAllNewPlexonStrobeWordsTS;
           
           fnDumpStrobeWords(strctPlexon.m_strctStrobeWord, strStrobeFile);
           aiStarts =cumsum([1 aiNumStrobeWordsInFrame]);
            % Fix variables and continue....
           for iFrameIter=1:iNumPlexonFrames
                strctPlexon.m_strctFrames.m_aiStartStrobe_Ind(iFrameIter) = aiStarts(iFrameIter);
                strctPlexon.m_strctFrames.m_aiEndStrobe_Ind(iFrameIter) = aiStarts(iFrameIter)+aiNumStrobeWordsInFrame(iFrameIter)-1;
                strctPlexon.m_strctFrames.m_aiNumStrobeWord(iFrameIter) =aiNumStrobeWordsInFrame(iFrameIter);
           end
           
           aiKofikoStartInd = find(strctKofiko.g_strctDAQParams.LastStrobe.Buffer == strctKofiko.g_strctSystemCodes.m_iStartRecord);
           aiKofikoStartRecTS = strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(aiKofikoStartInd);
           aiKofikoEndInd = find(strctKofiko.g_strctDAQParams.LastStrobe.Buffer == strctKofiko.g_strctSystemCodes.m_iStopRecord);
           aiKofikoEndRecTS = strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(aiKofikoEndInd);
           aiNumStrobeWordsSentByKofikoToPlexon = aiKofikoEndInd-aiKofikoStartInd+1;
    end
end

% Now we can sync up things, because the number of sent items equls number
% of received items
for iFrameIter=1:iNumPlexonFrames
    aiKofikoInterval = aiKofikoStartInd(iFrameIter):aiKofikoEndInd(iFrameIter);
    aiKofikoSyncEventsInd = find(strctKofiko.g_strctDAQParams.LastStrobe.Buffer(aiKofikoInterval) == strctKofiko.g_strctSystemCodes.m_iSync);
    afKofikoTS = strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(aiKofikoInterval(aiKofikoSyncEventsInd))';

    aiPlexonInterval = strctPlexon.m_strctFrames.m_aiStartStrobe_Ind(iFrameIter):strctPlexon.m_strctFrames.m_aiEndStrobe_Ind(iFrameIter);
    aiPlexonSyncEventsInd = find(strctPlexon.m_strctStrobeWord.m_aiWords(aiPlexonInterval) == strctKofiko.g_strctSystemCodes.m_iSync);
    afPlexonTS = strctPlexon.m_strctStrobeWord.m_afTimestamp(aiPlexonInterval(aiPlexonSyncEventsInd));
    assert( length(afPlexonTS) == length(afKofikoTS))
    
    [afTmp] = robustfit(afKofikoTS(:), afPlexonTS(:) );
    strctKofikoToPlexon.m_afOffset(iFrameIter) = afTmp(1);
    strctKofikoToPlexon.m_afScale(iFrameIter) = afTmp(2);
    afKofikoMappedToPlexon = afKofikoTS*strctKofikoToPlexon.m_afScale(iFrameIter)+strctKofikoToPlexon.m_afOffset(iFrameIter);
    afJitterMS = abs((afPlexonTS(:)-afKofikoMappedToPlexon(:))*1e3);
    strctKofikoToPlexon.m_afMinJitter(iFrameIter) = min(afJitterMS);
    strctKofikoToPlexon.m_afMaxJitter(iFrameIter) = max(afJitterMS);
    strctKofikoToPlexon.m_afMeanJitter(iFrameIter) = mean(afJitterMS);
    strctKofikoToPlexon.m_afStartFrameTS_PLX(iFrameIter) = strctPlexon.m_strctFrames.m_afStartTS_PLX(iFrameIter);
    strctKofikoToPlexon.m_afEndFrameTS_PLX(iFrameIter) = strctPlexon.m_strctFrames.m_afEndTS_PLX(iFrameIter);

    strctKofikoToPlexon.m_afStartFrameTS_Kofiko(iFrameIter) = aiKofikoStartRecTS(iFrameIter);
    strctKofikoToPlexon.m_afEndFrameTS_Kofiko(iFrameIter) = aiKofikoEndRecTS(iFrameIter);
    
end

strctSync.m_strctKofikoToPlexon = strctKofikoToPlexon;

%% Sync Kofiko-Stat Server
if ~isempty(strStatServerFile)
strctRegis = load(strStatServerFile);
    if isfield(strctRegis.g_strctCycle.m_strctSync,'KofikoSyncPingPong')
        % Slightly better version...
        a2fSyncTable = squeeze(strctRegis.g_strctCycle.m_strctSync.KofikoSyncPingPong.Buffer(1,:,1:strctRegis.g_strctCycle.m_strctSync.KofikoSyncPingPong.BufferIdx))';
        %fLocalTimeSend, fKofikoTime, fJitterMS
    else
        a2fSyncTable = squeeze(strctRegis.g_strctCycle.m_strctSync.KofikoSync.Buffer(1,:,1:strctRegis.g_strctCycle.m_strctSync.KofikoSync.BufferIdx))';
    end

    afStatServerTS = a2fSyncTable(2:end,1);
    afKofikoTS = a2fSyncTable(2:end,2);

    [afTmp] = robustfit(afStatServerTS, afKofikoTS );
    strctStatServerToKofiko.m_fOffset = afTmp(1);
    strctStatServerToKofiko.m_fScale = afTmp(2);
    afStatServerMappedToKofiko = afStatServerTS*strctStatServerToKofiko.m_fScale+strctStatServerToKofiko.m_fOffset;
    afJitterMS = abs((afKofikoTS-afStatServerMappedToKofiko)*1e3);
    strctStatServerToKofiko.m_afJitter = afJitterMS;

    strctSync.m_strctStatServerToKofiko = strctStatServerToKofiko;
else
    strctSync.m_strctStatServerToKofiko = [];
end


%% Sync Stimulus Server with Kofiko
afKofikoTS = strctKofiko.g_strctDAQParams.StimulusServerSync.Buffer(:,1);
afStimulusServerTime = strctKofiko.g_strctDAQParams.StimulusServerSync.Buffer(:,2);

[afTmp] = robustfit(afStimulusServerTime, afKofikoTS );
strctStimulusServerToKofiko.m_fOffset = afTmp(1);
strctStimulusServerToKofiko.m_fScale = afTmp(2);
afStimulusServerMappedToKofiko = afStimulusServerTime*strctStimulusServerToKofiko.m_fScale+strctStimulusServerToKofiko.m_fOffset;
afJitterMS = abs((afKofikoTS-afStimulusServerMappedToKofiko)*1e3);
strctStimulusServerToKofiko.m_afJitter = afJitterMS;

strctSync.m_strctStimulusServerToKofiko = strctStimulusServerToKofiko;


return;
