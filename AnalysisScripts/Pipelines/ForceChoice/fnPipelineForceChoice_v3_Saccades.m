function fnPipelineForceChoice_v3_Saccades(strctInputs)

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
strConfigFile = [strConfigFolder,'AnalysisPipelines',filesep, 'PipelineForceChoice.xml'];

strOutputFolder = [strDataRootFolder,'Processed',filesep(),'TouchForceChoiceNeuralAnalysis',filesep()];
if ~exist(strOutputFolder,'dir')
    mkdir(strOutputFolder);
end;

%% Verify everything is around.
fnCheckForFilesExistence({strKofikoFile, strAdvancerFile, strStatServerFile,...
    strStrobeFile,strAnalogFile,strSyncFile,strConfigFile});

% Load needed information to do processing
load(strSyncFile);
strctKofiko = load(strKofikoFile);
strctStatServer = load(strStatServerFile);

%%
strctConfig = fnMyXMLToStruct(strConfigFile);

afParadigmSwitchTS_Kofiko = strctKofiko.g_strctAppConfig.ParadigmSwitch.TimeStamp;
acstrParadigmNames = strctKofiko.g_strctAppConfig.ParadigmSwitch.Buffer;

if ~ismember('Touch Force Choice',acstrParadigmNames)
    fnWorkerLog('Session : %s does not contain force choice. Aborting!',strSession);
    return;
end;


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
%%
a2fTemp = textread(strAdvancerFile);
afDepthRelativeToGridTop = a2fTemp(:,2);
aiAdvancerUniqueID = a2fTemp(:,1);
afAdvancerChangeTS_StatServer = a2fTemp(:,6);
afAdvancerChangeTS_Plexon = fnTimeZoneChange(afAdvancerChangeTS_StatServer,strctSync,'StatServer','Plexon');
astrctChannelsGridInfo = fnGetChannelGridInfo(strctStatServer);

strctAdvancersInformation.m_afDepthRelativeToGridTop = afDepthRelativeToGridTop;
strctAdvancersInformation.m_aiAdvancerUniqueID = aiAdvancerUniqueID;
strctAdvancersInformation.m_afAdvancerChangeTS_Plexon = afAdvancerChangeTS_Plexon;

strctKofiko=fnReanalyzeEyeMovement(strRawFolder,strSession,strctSync,strctKofiko);

%%
for iChannelIter=1:iNumSortedChannels
    

    fnSetWaitbarGlobal(iChannelIter/length(astrctSortedChannels),2, 3);
    % Only read the intervals and find out whether there is something to analyze....
    
    strSpikeFile = [strSortedUnitsFolder,astrctSortedChannels(iChannelIter).name];
    
    [astrctAllUnits,strctChannelInfo] = fnReadDumpSpikeFile(strSpikeFile,'headeronly');
    fnWorkerLog('Analyzing channel %d (%s)',strctChannelInfo.m_iChannelID,strctChannelInfo.m_strChannelName);

    % Use stat server mapping information...
      iIndex = find(strctStatServer.g_strctNeuralServer.m_aiActiveSpikeChannels == strctChannelInfo.m_iChannelID);
      strCorrespondingLFPChannel =  strctStatServer.g_strctNeuralServer.m_acAnalogChannelNames{strctStatServer.g_strctNeuralServer.m_aiEnabledChannels(strctStatServer.g_strctNeuralServer.m_aiSpikeToAnalogMapping(iIndex))};
        strLFPFile = [strRawFolder, strSession, '-', strCorrespondingLFPChannel,'.raw'];
    
    % Skip unsorted units....
    aiSortedUnits = find(cat(1,astrctAllUnits.m_iUnitIndex) ~= 0);
    astrctUnits = astrctAllUnits(aiSortedUnits);
    
    
    
    
    [strctChannelInfo.m_iGridX, strctChannelInfo.m_iGridY] = fnGetGridHole(astrctChannelsGridInfo,strctChannelInfo.m_iChannelID);
    
    fnWorkerLog('Analyzing channel %d (%s)',strctChannelInfo.m_iChannelID,strctChannelInfo.m_strChannelName);
    iAdvancerUniqueID = strctStatServer.g_strctNeuralServer.m_a2iChannelToGridHoleAdvancer(strctChannelInfo.m_iChannelID,3);
%     iChannelIdx = find(strctStatServer.g_strctNeuralServer.m_aiActiveSpikeChannels == strctChannelInfo.m_iChannelID);
%     iTempIndex = strctStatServer.g_strctNeuralServer.m_aiSpikeToAnalogMapping(iChannelIdx);
%     iCorrespondingAnalogChannel = strctStatServer.g_strctNeuralServer.m_aiEnabledChannels(iTempIndex);
    
    
    abRelevantAdvancerEntries = strctAdvancersInformation.m_aiAdvancerUniqueID == iAdvancerUniqueID;
    strctAdvancerInformation.m_afDepth = strctAdvancersInformation.m_afDepthRelativeToGridTop(abRelevantAdvancerEntries);
    strctAdvancerInformation.m_afTS_PLX = strctAdvancersInformation.m_afAdvancerChangeTS_Plexon(abRelevantAdvancerEntries);
    
    
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
        
        if ismember('Touch Force Choice',acParadigmsRecorded)
            strctInterval.m_iChannel = strctChannelInfo.m_iChannelID;
            strctInterval.m_iUniqueID    =astrctUnits(iUnitIter).m_iUnitIndex;
            strctInterval.m_fStartTS_Plexon = astrctUnits(iUnitIter).m_afInterval(1);
            strctInterval.m_fEndTS_Plexon = astrctUnits(iUnitIter).m_afInterval(2);
            strctInterval.m_strRawFolder = strRawFolder;
            strctInterval.m_strSession    = strSession;
            strctInterval.m_strSpikeFile = strSpikeFile;
            strctInterval.m_strLFPFile = strLFPFile;
            
            
            afSampleAdvancerTimes =[strctInterval.m_fStartTS_Plexon, strctInterval.m_fEndTS_Plexon];
            strctInterval.m_afIntervalDepthMM= fnMyInterp1( strctAdvancerInformation.m_afTS_PLX, strctAdvancerInformation.m_afDepth,afSampleAdvancerTimes);
            
            
            fnCollectForceChoiceStats_Saccades(strctKofiko, strctSync, strctConfig, strctInterval,strOutputFolder);
        end
    end
end
return;

function fnCheckForFilesExistence(acFileList)
for k=1:length(acFileList)
    if ~exist(acFileList{k},'file')
        error('FileMissing', acFileList{k});
    end
end



function [iGridX,iGridY] = fnGetGridHole(astrctChannelsGridInfo,iChannel)
iGridX =[];
iGridY =[];

for k=1:length(astrctChannelsGridInfo)
    if astrctChannelsGridInfo(k).m_iChannel == iChannel
        iGridX =astrctChannelsGridInfo(k).m_fCenterOffsetX ;
        iGridY = astrctChannelsGridInfo(k).m_fCenterOffsetY;
        return;
    end
end
return


%%
function strctKofiko=fnReanalyzeEyeMovement(strRawFolder,strSession,strctSync,strctKofiko)


strSubject = strctKofiko.g_strctAppConfig.m_strctSubject.m_strName;
strTimeDate = strctKofiko.g_strctAppConfig.m_strTimeDate;
strTimeDate(strTimeDate == ':') = '-';
strTimeDate(strTimeDate == ' ') = '_';

acParadigms = fnCellStructToArray( strctKofiko.g_astrctAllParadigms,'m_strName');
iParadigmIndex = find(ismember(acParadigms,'Touch Force Choice'),1,'first');
if isempty(iParadigmIndex)
    fnWorkerLog('Session : %s does not contain force choice. Aborting!',strSession);
    return;
end;

strctParadigm = strctKofiko.g_astrctAllParadigms{iParadigmIndex};
if ~isfield(strctParadigm,'ExperimentDesigns')
    fnWorkerLog('No designs loaded. Aborting.');
    return;
end;
iNumDesigns = length(strctParadigm.ExperimentDesigns.Buffer);
acAllDesigns = {};
for iIter=1:iNumDesigns
    if ~isempty(strctParadigm.ExperimentDesigns.Buffer{iIter})
        acAllDesigns{iIter} = strctParadigm.ExperimentDesigns.Buffer{iIter}.m_strDesignFileName;
    else
        acAllDesigns{iIter} = '';
    end
end
acUniqueDesigns = unique(setdiff(acAllDesigns,{''}));
iNumUniqueDesigns = length(acUniqueDesigns);
fnWorkerLog('%d unique designs were loaded',iNumUniqueDesigns);

afDesignOnsetTimeStampsAug=  [strctParadigm.ExperimentDesigns.TimeStamp,Inf];

iNumTrials = length(strctParadigm.acTrials.TimeStamp);

iCounter = 1;
for iUniqueDesignIter=1:iNumUniqueDesigns
    strDesignName = acUniqueDesigns{iUniqueDesignIter};
    [strPath,strShortDesignName]=fileparts(strDesignName);
    fnWorkerLog('* Design: %s (%s)',strShortDesignName,strDesignName)
    
    % Find the relevant design onset and offset
    aiInd = find(ismember(acAllDesigns, strDesignName));
    strctDesign = strctParadigm.ExperimentDesigns.Buffer{aiInd(1)};
    
    abRelevantTrials = zeros(1,iNumTrials)>0;
    for iIter=1:length(aiInd)
        fOnset_TS_Kofiko = afDesignOnsetTimeStampsAug(aiInd(iIter));
        fOffset_TS_Kofiko = afDesignOnsetTimeStampsAug(aiInd(iIter)+1);
        % Find relevant trials
        abRelevantTrials(strctParadigm.acTrials.TimeStamp >=fOnset_TS_Kofiko & strctParadigm.acTrials.TimeStamp <=fOffset_TS_Kofiko) = true;
    end
    if sum(abRelevantTrials) == 0
        fnWorkerLog(' - Skipping. no trials found for this design');
        continue;
    end;
    
    % OK, now that we have collected all relevant trials, how many
    % different trial types do we have for this design?
    aiRelevantTrials = find(abRelevantTrials);
    acTrials = strctParadigm.acTrials.Buffer(abRelevantTrials);
    
    aiTrialTypes = fnCellStructToArray(strctParadigm.acTrials.Buffer(abRelevantTrials),'m_iTrialType');
    [aiUniqueTrialTypes, Dummy, aiTrialTypeToUniqueTrialType] = unique(aiTrialTypes);
   acTrials=fnReanalyzeSaccadeTrials(acTrials,strRawFolder,strSession,strctSync,strctKofiko);
   
    strctKofiko.g_astrctAllParadigms{iParadigmIndex}.acTrials.Buffer(abRelevantTrials) = acTrials;
end