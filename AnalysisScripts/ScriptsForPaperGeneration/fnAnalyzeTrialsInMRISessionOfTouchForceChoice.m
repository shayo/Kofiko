strKofikoLog = 'D:\Data\Doris\Behavior\LogsFromMRI\120327_152123_Bert.mat';
[strPath,strSessionName]=fileparts(strKofikoLog);
strctKofiko  = load(strKofikoLog);

iParadigmIndex = -1;
for k=1:length(strctKofiko.g_astrctAllParadigms)
    if strcmp(strctKofiko.g_astrctAllParadigms{k}.m_strName,'Touch Force Choice')
        iParadigmIndex = k;
        break;
    end
end
if iParadigmIndex == -1
    % Nothing to do...
    return;
end;

% Find out how many recorded sessions are there....

aiStartRecordEvents = find(strctKofiko.g_strctDAQParams.LastStrobe.Buffer == strctKofiko.g_strctSystemCodes.m_iStartRecord);
aiEndRecordEvents = find(strctKofiko.g_strctDAQParams.LastStrobe.Buffer == strctKofiko.g_strctSystemCodes.m_iStopRecord);

iNumRecordedSessions = length(aiStartRecordEvents) ;
if length(aiStartRecordEvents) ~= length(aiEndRecordEvents )
    fprintf('Critical error. Number of start and stop recording sessions mismatch. Aborting!\n');
end
fprintf('Number of Recorded session : %d\n',iNumRecordedSessions);

afStartRecordEvents_TS = strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(aiStartRecordEvents);
afEndRecordEvents_TS = strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(aiEndRecordEvents);

aiTriggerEvents = strctKofiko.g_strctDAQParams.m_astrctExternalTriggers.Trigger.Buffer; % First value is always 0!
afTriggerEventsTS = strctKofiko.g_strctDAQParams.m_astrctExternalTriggers.Trigger.TimeStamp;
afDetectedTR_TS = afTriggerEventsTS(aiTriggerEvents(2:end) == 1 & aiTriggerEvents(1:end-1) == 0); % Triger Rise events!

strctParadigm = strctKofiko.g_astrctAllParadigms{iParadigmIndex};

% Generate information using Cue onset?
strEvent = 'Cue';
strEventLength = 'Fixed';
fDurationLength_Sec = 0.7;
aiTrialTypeToCondition = 1:iNumTrialTypes;
iNumConditions = iNumTrialTypes;
acConditionNames = cell(1,iNumConditions);

for iIter=1:iNumRecordedSessions
    % Find out which Trs were detected in this session....
    
    afDetectedTRs_InSession_TS = afDetectedTR_TS (afDetectedTR_TS >= afStartRecordEvents_TS(iIter)-1  & afDetectedTR_TS<= afEndRecordEvents_TS(iIter)+1);
    % Find out whether touch force choice was active during this time, and
    % if so, which trials were played...
    aiTrialInd = find(strctParadigm.acTrials.TimeStamp >= afStartRecordEvents_TS(iIter) & strctParadigm.acTrials.TimeStamp  < afEndRecordEvents_TS(iIter));
    
    strFileName = sprintf('%s_run%d',strSessionName,iIter);
    hFileID = fopen(strFileName,'w+');
    
    acTrialsInSession = strctParadigm.acTrials.Buffer(aiTrialInd);
    for iIter=1:length(acTrialsInSession)
        
        if isfield( acTrialsInSession{iIter}.m_strctTrialOutcome,'m_afCueOnset_TS_Kofiko')
            % Compute Cue onset in terms of first detected TR...
            fEventOnset = acTrialsInSession{iIter}.m_strctTrialOutcome.m_afCueOnset_TS_Kofiko - afDetectedTRs_InSession_TS(1);  % In seconds
            
            if strcmp(strEventLength,'Fixed')
                fDuration = fDurationLength_Sec;
            end
            
            fprintf(hFileID,'%10.2f %10.2f %10.2f %s\n',fEventOnset , aiTrialTypeToCondition(acTrialsInSession{iIter}.m_iTrialType),...
                       fDuration, acConditionNames);
    
        else
            % Trial without cue ? 
        end
        
    end
    fclose(hFileID);
    
    % Align to first detected TR... make sense....
    
end

return