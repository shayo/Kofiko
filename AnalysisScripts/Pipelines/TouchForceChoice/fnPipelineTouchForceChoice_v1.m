function fnPipelineTouchForceChoice_v1(strctInputs)

strDataRootFolder = strctInputs.m_strDataRootFolder;
strConfigFolder   = strctInputs.m_strConfigFolder;
strSession        = strctInputs.m_strSession;

if strDataRootFolder(end) ~= filesep()
    strDataRootFolder(end+1) = filesep();
end;
fnWorkerLog('Starting force choice standard analysis pipline...');
fnWorkerLog('Session : %s',strSession);
fnWorkerLog('Data Root : %s',strDataRootFolder);

strRawFolder = [strDataRootFolder,'RAW',filesep()];
strKofikoFile = fullfile(strRawFolder,[strSession,'.mat']);
strAdvancerFile = fullfile(strRawFolder,[strSession,'-Advancers.txt']);
strStatServerFile = fullfile(strRawFolder,[strSession,'-StatServerInfo.mat']);
strStrobeFile = fullfile(strRawFolder,[strSession,'-strobe.raw']);
strAnalogFile = fullfile(strRawFolder,[strSession,'-EyeX.raw']);  % any can suffice...
strSyncFile = fullfile(strRawFolder,[strSession,'-sync.mat']);
strConfigFile = [strConfigFolder,'AnalysisPipelines',filesep, 'PipelineTouchForceChoice.xml'];

strOutputFolder = [strDataRootFolder,'Processed',filesep(),'SingleUnitDataEntries',filesep()];
if ~exist(strOutputFolder,'dir')
    mkdir(strOutputFolder);
end;

%% Verify everything is around.
fnCheckForFilesExistence({strKofikoFile,...
    strStrobeFile,strAnalogFile,strSyncFile,strConfigFile});

% Load needed information to do processing
fnWorkerLog('Loading Sync file...');
load(strSyncFile);
fnWorkerLog('Loading Kofiko file...');
strctKofiko = load(strKofikoFile);

%%
strctConfig = fnMyXMLToStruct(strConfigFile);

afParadigmSwitchTS_Kofiko = strctKofiko.g_strctAppConfig.ParadigmSwitch.TimeStamp;
acstrParadigmNames = strctKofiko.g_strctAppConfig.ParadigmSwitch.Buffer;

acParadigms = fnCellStructToArray( strctKofiko.g_astrctAllParadigms,'m_strName');

iParadigmIndex = find(ismember(acParadigms,'Touch Force Choice'),1,'first');
if isempty(iParadigmIndex)
    fnWorkerLog('Session : %s does not contain force choice. Aborting!',strSession);
    return;
end;


strBehaviorStatFolder = [strDataRootFolder,filesep,'Processed',filesep,'BehaviorStats',filesep()];
if ~exist(strBehaviorStatFolder,'dir')
    mkdir(strBehaviorStatFolder);
end;
%fnTouchForceChoiceBehaviorAnalysis(strctKofiko,strRawFolder,strSession,strctSync,strBehaviorStatFolder);
fnSaccadeMemoryTaskAnalysis(strctKofiko,strRawFolder,strSession,strctSync,strBehaviorStatFolder);
return;
% 
% %% Analyze sorted data only (!)
% strSortedUnitsFolder = [strDataRootFolder,'Processed',filesep,'SortedUnits',filesep];
% astrctSortedChannels = dir([strSortedUnitsFolder,'*spikes_ch*_sorted.raw']);
% 
% if isempty(astrctSortedChannels)
%     fnWorkerLog('No sorted channels found for session %s. Aborting.',strSession);
%     return;
% end
% %acNewDataEntries = {[]};
% fnResetWaitbarGlobal(2,3);
% iNumSortedChannels = length(astrctSortedChannels);
% fnWorkerLog('%d Sorted channel files found',iNumSortedChannels);
% 
% for iChannelIter=1:iNumSortedChannels
%     
% 
%     fnSetWaitbarGlobal(iChannelIter/length(astrctSortedChannels),2, 3);
%     % Only read the intervals and find out whether there is something to analyze....
%     
%     strSpikeFile = [strSortedUnitsFolder,astrctSortedChannels(iChannelIter).name];
%     [astrctAllUnits,strctChannelInfo] = fnReadDumpSpikeFile(strSpikeFile,'headeronly');
%     fnWorkerLog('Analyzing channel %d (%s)',strctChannelInfo.m_iChannelID,strctChannelInfo.m_strChannelName);
%     
%     % Skip unsorted units....
%     aiSortedUnits = find(cat(1,astrctAllUnits.m_iUnitIndex) ~= 0);
%     astrctUnits = astrctAllUnits(aiSortedUnits);
%     
%     %% Do the simple train evoked average
%         iNumSortedUnits = length(astrctUnits);
%     fnWorkerLog('%d sorted unit intervals found',iNumSortedUnits);
%     fnResetWaitbarGlobal(3,3);
%     for iUnitIter=1:iNumSortedUnits
%         fnSetWaitbarGlobal(iUnitIter/iNumSortedUnits,3, 3);
% 
%         fStartTS_PTB_Kofiko = fnTimeZoneChange(astrctUnits(iUnitIter).m_afInterval(1) ,strctSync,'Plexon','Kofiko');
%         fEndTS_PTB_Kofiko = fnTimeZoneChange(astrctUnits(iUnitIter).m_afInterval(2),strctSync,'Plexon','Kofiko');
% 
%         
%     end
%     
%     
%     
%     iNumSortedUnits = length(astrctUnits);
%     fnWorkerLog('%d sorted unit intervals found',iNumSortedUnits);
%     fnResetWaitbarGlobal(3,3);
%     for iUnitIter=1:iNumSortedUnits
%         fnSetWaitbarGlobal(iUnitIter/iNumSortedUnits,3, 3);
% 
%         fStartTS_PTB_Kofiko = fnTimeZoneChange(astrctUnits(iUnitIter).m_afInterval(1) ,strctSync,'Plexon','Kofiko');
%         fEndTS_PTB_Kofiko = fnTimeZoneChange(astrctUnits(iUnitIter).m_afInterval(2),strctSync,'Plexon','Kofiko');
%         
%         % Find out which paradigms were run while this unit was alive...
%         iStartIndex = find(afParadigmSwitchTS_Kofiko <= fStartTS_PTB_Kofiko,1,'last');
%         iEndIndex = find(afParadigmSwitchTS_Kofiko <= fEndTS_PTB_Kofiko,1,'last');
%         acParadigmsRecorded = unique(acstrParadigmNames(iStartIndex:iEndIndex));
%         
%         if ismember('Force Choice',acParadigmsRecorded)
%             strctInterval.m_iChannel = strctChannelInfo.m_iChannelID;
%             strctInterval.m_iUniqueID    =astrctUnits(iUnitIter).m_iUnitIndex;
%             strctInterval.m_fStartTS_Plexon = astrctUnits(iUnitIter).m_afInterval(1);
%             strctInterval.m_fEndTS_Plexon = astrctUnits(iUnitIter).m_afInterval(2);
%             strctInterval.m_strRawFolder = strRawFolder;
%             strctInterval.m_strSession    = strSession;
%             strctInterval.m_iPlexonFrame  = NaN;
%             strctInterval.m_strSpikeFile = strSpikeFile;
%             acUnitsStat = fnCollectForceChoiceStats(strctKofiko, strctSync, strctConfig, strctInterval);
%             if ~isempty(acUnitsStat)
%                 % Save the statistics to disk
%                 iNumDataEntries = length(acUnitsStat);
%                 for iEntryIter=1:iNumDataEntries
%                     strctUnit = acUnitsStat{iEntryIter};
%                     
%                     strTimeDate = datestr(datenum(strctUnit.m_strRecordedTimeDate),31);
%                     strTimeDate(strTimeDate == ':') = '-';
%                     strTimeDate(strTimeDate == ' ') = '_';
%                     
%                     strParadigm = strctUnit.m_strParadigm;
%                     strParadigm(strParadigm == ' ') = '_';
%                     strDesr = strctUnit.m_strParadigmDesc;
%                     strDesr(strDesr == ' ') = '_';
%                     strUnitName = sprintf('%s_%s_Exp_%02d_Ch_%03d_Unit_%03d_%s_%s',...
%                         strctUnit.m_strSubject, strTimeDate,strctUnit.m_iRecordedSession,...
%                         strctUnit.m_iChannel(1),strctUnit.m_iUnitID(1), strParadigm, strDesr);
%                     
%                     strOutputFilename = fullfile(strOutputFolder, [strUnitName,'.mat']);
%                     %acNewDataEntries = [acNewDataEntries,strOutputFilename];
%                     save(strOutputFilename,  'strctUnit');
%                 end
%             end
%         end
%     end
% end
% return;

function fnCheckForFilesExistence(acFileList)
for k=1:length(acFileList)
    if ~exist(acFileList{k},'file')
        fprintf('The following file is missing: %s\n',acFileList{k});
        error('FileMissing');
    end
end

