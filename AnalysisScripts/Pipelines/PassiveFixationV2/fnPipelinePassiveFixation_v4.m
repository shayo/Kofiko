function fnPipelinePassiveFixation_v3(strctInputs)
clear global g_acDesignCache

strDataRootFolder = strctInputs.m_strDataRootFolder;
strConfigFolder   = strctInputs.m_strConfigFolder;
strSession        = strctInputs.m_strSession;

if strDataRootFolder(end) ~= filesep()
    strDataRootFolder(end+1) = filesep();
end;
fnWorkerLog('Starting passive fixation standard analysis pipline...');
fnWorkerLog('Session : %s',strSession);
fnWorkerLog('Data Root : %s',strDataRootFolder);

strRawFolder = [strDataRootFolder,'RAW',filesep()];
strKofikoFile = fullfile(strRawFolder,[strSession,'.mat']);
strAdvancerFile = fullfile(strRawFolder,[strSession,'-Advancers.txt']);
strStatServerFile = fullfile(strRawFolder,[strSession,'-StatServerInfo.mat']);
strStrobeFile = fullfile(strRawFolder,[strSession,'-strobe.raw']);
strAnalogFile = fullfile(strRawFolder,[strSession,'-EyeX.raw']);  % any can suffice...
strSyncFile = fullfile(strRawFolder,[strSession,'-sync.mat']);
strConfigFile = [strConfigFolder,'AnalysisPipelines',filesep, 'PipelineNewPassiveFixation.xml'];
strPhotoDiodeFile = fullfile(strRawFolder,[strSession,'-Photodiode.raw']);

strOutputFolder = [strDataRootFolder,'Processed',filesep(),'SingleUnitDataEntries',filesep()];
if ~exist(strOutputFolder,'dir')
    mkdir(strOutputFolder);
end;

%% Verify everything is around.
fnCheckForFilesExistence({strKofikoFile, strAdvancerFile, strStatServerFile,...
    strStrobeFile,strAnalogFile,strSyncFile,strConfigFile,strPhotoDiodeFile});

% Load needed information to do processing
load(strSyncFile);
strctKofiko = load(strKofikoFile);
strctStatServer = load(strStatServerFile);
%% Detect photodiode events
fnWorkerLog('Detecting photodiode crossing...');

[strctPhotodiode, afTime]= fnReadDumpAnalogFile(strPhotoDiodeFile);
fPhotodiodeThreshold = (max(strctPhotodiode.m_afData)-min(strctPhotodiode.m_afData))/2;

astrctPhotodiodeEventsWithJitter = fnGetIntervals(strctPhotodiode.m_afData > fPhotodiodeThreshold);
% Photodiode amplifier sometimes jitters the signal and goes low when it shouldn't.
% So we merge nearby intervals that are shroter than refresh rate (or
% two..., since we usually don't display things that fast).
iDistanceBetweenSamplesMS = 1e3*(afTime(2)-afTime(1));
iMergeInterval = ceil(2*strctKofiko.g_strctStimulusServer.m_fRefreshRateMS / iDistanceBetweenSamplesMS);
astrctPhotodiodeEvents = fnMergeIntervals(astrctPhotodiodeEventsWithJitter,iMergeInterval);

% M = length(strctPhotodiode.m_afData);
% 
% abNotFixed = fnIntervalsToBinary(astrctPhotodiodeEventsWithJitter,M);
% abFixed = fnIntervalsToBinary(astrctPhotodiodeEvents,M);

% figure(11);
% clf;
% plot(abFixed*1,'r');
% hold on;
% plot(0.2+abNotFixed*0.6,'b');
% set(gca,'xlim',[-5000 5000]+189955*ones(1,2));
% set(gca,'ylim',[-0.2 1.3]);
afActualFlipTime_PLX = sort(afTime([cat(1,astrctPhotodiodeEvents.m_iStart);cat(1,astrctPhotodiodeEvents.m_iEnd)]));

fnWorkerLog('Detected %d photodiode switching events', length(afActualFlipTime_PLX));


%%
strctConfig = fnMyXMLToStruct(strConfigFile);

afParadigmSwitchTS_Kofiko = strctKofiko.g_strctAppConfig.ParadigmSwitch.TimeStamp;
acstrParadigmNames = strctKofiko.g_strctAppConfig.ParadigmSwitch.Buffer;

if ~ismember('Passive Fixation New',acstrParadigmNames)
    fnWorkerLog('Session : %s does not contain force choice. Aborting!',strSession);
    return;
end;

%% Read advancer file for electrode position during the experiments...
a2fTemp = textread(strAdvancerFile);
afDepthRelativeToGridTop = a2fTemp(:,2);
aiAdvancerUniqueID = a2fTemp(:,1);
afAdvancerChangeTS_StatServer = a2fTemp(:,6);
afAdvancerChangeTS_Plexon = fnTimeZoneChange(afAdvancerChangeTS_StatServer,strctSync,'StatServer','Plexon');


%% Analyze sorted data only (!)
strSortedUnitsFolder = [strDataRootFolder,'Processed',filesep,'SortedUnits',filesep];
astrctSortedChannels = dir([strSortedUnitsFolder,'*spikes_ch*_sorted.raw']);

if isempty(astrctSortedChannels)
    fnWorkerLog('No sorted channels found for session %s. Aborting.',strSession);
    return;
end
%acNewDataEntries = {[]};
fnResetWaitbarGlobal(2,3);
iNumSortedChannels = length(astrctSortedChannels);
fnWorkerLog('%d Sorted channel files found',iNumSortedChannels);



for iChannelIter=1:iNumSortedChannels
    fnSetWaitbarGlobal(iChannelIter/length(astrctSortedChannels),2, 3);
    % Only read the intervals and find out whether there is something to analyze....
    
    strSpikeFile = [strSortedUnitsFolder,astrctSortedChannels(iChannelIter).name];
    [astrctAllUnits,strctChannelInfo] = fnReadDumpSpikeFile(strSpikeFile);
    astrctAllUnits = fnComputeUnitSNR(astrctAllUnits);
    fnWorkerLog('Analyzing channel %d (%s)',strctChannelInfo.m_iChannelID,strctChannelInfo.m_strChannelName);
    
    %    Do we have an LFP channel for this spike channel ?
    
    iAdvancerUniqueID = strctStatServer.g_strctNeuralServer.m_a2iChannelToGridHoleAdvancer(strctChannelInfo.m_iChannelID,3);

    
    iChannelIdx = find(strctStatServer.g_strctNeuralServer.m_aiActiveSpikeChannels == strctChannelInfo.m_iChannelID);
    iTempIndex = strctStatServer.g_strctNeuralServer.m_aiSpikeToAnalogMapping(iChannelIdx);
    iCorrespondingAnalogChannel = strctStatServer.g_strctNeuralServer.m_aiEnabledChannels(iTempIndex);
    strAnalogChannelFile = [strRawFolder,strSession,'-',strctStatServer.g_strctNeuralServer.m_acAnalogChannelNames{iCorrespondingAnalogChannel},'.raw'];
    
    % Skip unsorted units....
    aiSortedUnits = find(cat(1,astrctAllUnits.m_iUnitIndex) ~= 0);
    astrctUnits = astrctAllUnits(aiSortedUnits);
    
    
    
    % For each sorted unit, find out whether passive fixation paradgm was
    % active during that time...
    
    iNumSortedUnits = length(astrctUnits);
    fnWorkerLog('%d sorted unit intervals found',iNumSortedUnits);
    fnResetWaitbarGlobal(3,3);
    for iUnitIter=1:iNumSortedUnits
        fnSetWaitbarGlobal(iUnitIter/iNumSortedUnits,3, 3);

        fStartTS_PTB_Kofiko = fnTimeZoneChange(astrctUnits(iUnitIter).m_afInterval(1) ,strctSync,'Plexon','Kofiko');
        fEndTS_PTB_Kofiko = fnTimeZoneChange(astrctUnits(iUnitIter).m_afInterval(2),strctSync,'Plexon','Kofiko');
        
        % Find out which paradigms were run while this unit was alive...
        iStartIndex = find(afParadigmSwitchTS_Kofiko <= fStartTS_PTB_Kofiko,1,'last');
        iEndIndex = find(afParadigmSwitchTS_Kofiko <= fEndTS_PTB_Kofiko,1,'last');
        acParadigmsRecorded = unique(acstrParadigmNames(iStartIndex:iEndIndex));
        
        % Find depths this unit was recorded at (relative to grid top)
        % Store this in a2fAdvancerPositionTS_Plexon
        % a2fAdvancerPositionTS_Plexon(1,:) is Plexon TS when advancer was
        % modified
        % a2fAdvancerPositionTS_Plexon(2,:) are the depth values.
        afSampleAdvancerTimes = [astrctUnits(iUnitIter).m_afInterval(1):1:astrctUnits(iUnitIter).m_afInterval(2)]; % every second...
        afIntervalDepthMM= fnMyInterp1(afAdvancerChangeTS_Plexon(aiAdvancerUniqueID == iAdvancerUniqueID), afDepthRelativeToGridTop(aiAdvancerUniqueID == iAdvancerUniqueID),afSampleAdvancerTimes);
        a2fAdvancerPositionTS_Plexon = [       afSampleAdvancerTimes;afIntervalDepthMM];
        
        if ismember('Passive Fixation New',acParadigmsRecorded)
            strctInterval.m_iChannel = strctChannelInfo.m_iChannelID;
            strctInterval.m_iUniqueID    =astrctUnits(iUnitIter).m_iUnitIndex;
            strctInterval.m_fStartTS_Plexon = astrctUnits(iUnitIter).m_afInterval(1);
            strctInterval.m_fEndTS_Plexon = astrctUnits(iUnitIter).m_afInterval(2);
            strctInterval.m_strRawFolder = strRawFolder;
            strctInterval.m_strSession    = strSession;
            strctInterval.m_iPlexonFrame  = NaN;
            strctInterval.m_strSpikeFile = strSpikeFile;
            strctInterval.m_strAnalogChannelFile = strAnalogChannelFile;
            strctInterval.m_a2fAdvancerPositionTS_Plexon = a2fAdvancerPositionTS_Plexon;
            acUnitsStat = fnCollectPassiveFixationNewUnitStats2(strctKofiko, strctSync, strctConfig, strctInterval,afActualFlipTime_PLX);
            if ~isempty(acUnitsStat)
                % Save the statistics to disk
                iNumDataEntries = length(acUnitsStat);
                for iEntryIter=1:iNumDataEntries
                    strctUnit = acUnitsStat{iEntryIter};
                    
                    strTimeDate = datestr(datenum(strctUnit.m_strRecordedTimeDate),31);
                    strTimeDate(strTimeDate == ':') = '-';
                    strTimeDate(strTimeDate == ' ') = '_';
                    
                    strParadigm = strctUnit.m_strParadigm;
                    strParadigm(strParadigm == ' ') = '_';
                    strDesr = strctUnit.m_strParadigmDesc;
                    strDesr(strDesr == ' ') = '_';
                    strUnitName = sprintf('%s_%s_Exp_%02d_Ch_%03d_Unit_%03d_%s_%s',...
                        strctUnit.m_strSubject, strTimeDate,strctUnit.m_iRecordedSession,...
                        strctUnit.m_iChannel(1),strctUnit.m_iUnitID(1), strParadigm, strDesr);
                    
                    strOutputFilename = fullfile(strOutputFolder, [strUnitName,'.mat']);
                    %acNewDataEntries = [acNewDataEntries,strOutputFilename];
                    save(strOutputFilename,  'strctUnit');
                end
            end
        end
    end
end
return;

function fnCheckForFilesExistence(acFileList)
for k=1:length(acFileList)
    if ~exist(acFileList{k},'file')
        fprintf('File is missing : %s\n',acFileList{k});
        error('FileMissing');
    end
end

