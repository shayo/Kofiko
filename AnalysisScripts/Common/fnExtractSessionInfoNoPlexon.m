function [astrctExperiments] = fnExtractSessionInfoNoPlexon(strctKofiko)

%%
strctSystemCodes = strctKofiko.g_strctSystemCodes;

%% Find recorded sessions

aiKofikoStartInd = find(strctKofiko.g_strctDAQParams.LastStrobe.Buffer == strctSystemCodes.m_iStartRecord);
aiKofikoStartRecTS = strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(aiKofikoStartInd);
aiKofikoEndInd = find(strctKofiko.g_strctDAQParams.LastStrobe.Buffer == strctSystemCodes.m_iStopRecord);
aiKofikoEndRecTS = strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(aiKofikoEndInd);
if length(aiKofikoStartInd)  ~= length(aiKofikoEndInd)
    fnWorkerLog('Weird mismatch in start/stop strobe events...Trying To Recover...');
    if isempty(aiKofikoStartInd) && ~isempty(aiKofikoEndInd)
        fnWorkerLog('OK.');
        aiKofikoEndInd = [];
        aiKofikoEndRecTS =[];
    else
        assert(length(aiKofikoStartInd) == length(aiKofikoEndInd));
    end
end

iNumExperimentsRecorded = length(aiKofikoStartInd);
% fprintf('%d Experiments were recorded\n',iNumExperimentsRecorded);
if iNumExperimentsRecorded == 0
    fnWorkerLog('Behavioral or a scanning session...');
    astrctExperiments = [];
end

%% Find which paradigms were recorded...
% afParadigmSwitchTS = ...
%     strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(strctKofiko.g_strctDAQParams.LastStrobe.Buffer == strctSystemCodes.m_iParadigmSwitch);
%iNumSwitches = length(afParadigmSwitchTS);
% acstrParadigmSwitchNames = cell(1,iNumSwitches);
% 
% for k=1:iNumSwitches
%     iIndex = find(strctKofiko.g_strctLog.Log.TimeStamp > afParadigmSwitchTS(k),1,'first');
%     acstrParadigmSwitchNames{k} = strctKofiko.g_strctLog.Log.Buffer{iIndex}(23:end);
% end;

% Match paradigm name to the start of recording
acSessionParadigm = cell(1,iNumExperimentsRecorded);
abBlockDesignExperiments = zeros(1,iNumExperimentsRecorded);
for k=1:iNumExperimentsRecorded
    %iIndex = find(afParadigmSwitchTS < aiKofikoStartRecTS(k),1,'last');
    %acSessionParadigm{k} = acstrParadigmSwitchNames{iIndex};
    astrctExperiments(k).m_strParadigmName = acSessionParadigm{k};
    abBlockDesignExperiments(k) = strcmpi(acSessionParadigm{k},'fMRI Block Design');
    astrctExperiments(k).m_fKofikoStartTS = aiKofikoStartRecTS(k);
    astrctExperiments(k).m_fKofikoEndTS = aiKofikoEndRecTS(k);
    astrctExperiments(k).m_iNumStrobeWords = aiKofikoEndInd(k)-aiKofikoStartInd(k)+1;
    astrctExperiments(k).m_aiKofikoStrobeInterval = aiKofikoStartInd(k):aiKofikoEndInd(k);
    fnWorkerLog('Recorded experiment %d , (%.2f Min)', k,...
        (aiKofikoEndRecTS(k)-aiKofikoStartRecTS(k))/60);
end;

% %% Analyze only the fMRI Block Design Experiments....
% aiMRIExperiments = find(abBlockDesignExperiments);
% aiNonMRIExperiments = find(~abBlockDesignExperiments);
% if ~isempty(aiNonMRIExperiments)
%     fprintf('Warning. There are non fMRI experiments in this Kofiko file ?!!?!?!\n');
%     fprintf('This script can only analyze sessions recorded in the MRI, assuming no plexon is around...\n');
%     fprintf('Only fMRI Block Design experiments will be analyzed!\n');
%     astrctExperiments = astrctExperiments(aiMRIExperiments);
% end;

return;


