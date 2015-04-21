function fnPipelineForceChoice_v2(strctInputs)

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
strTriggerFile = fullfile(strRawFolder,[strSession,'-Stimulation_Trig.raw']);
strTriggerFile2 = fullfile(strRawFolder,[strSession,'-Stimulation_Trig.raw']);
strRawFolder = [strDataRootFolder,'RAW',filesep()];

strTrainFile1 = fullfile(strRawFolder,[strSession,'-Grass_Train.raw']);
strTrainFile2 = fullfile(strRawFolder,[strSession,'-Grass_Train2.raw']);

if ~exist(strTrainFile1,'file')
    strTrainFile1 = [];
end
if ~exist(strTrainFile2,'file')
    strTrainFile2 = [];
end


a2fTargetCenter = [400 0;
    -400 0;
    0 -400;
    0 400;
    280 -280;
    280 280;
    -280 -280;
    -280 280]/2;
if strctKofiko.g_strctStimulusServer.m_aiScreenSize(3) == 1920
    fFixationRadius=90*2;
    fChoiceRadius = 80*2;
else
    fFixationRadius=90;
    fChoiceRadius = 80;
end


iParadigmIndex = find(ismember(acstrParadigmNames,'Touch Force Choice'));
iNumDesigns = length(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ExperimentDesigns.TimeStamp);

afDesignsOnset = [strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ExperimentDesigns.TimeStamp,Inf];
for k=1:iNumDesigns
    if ~isempty(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ExperimentDesigns.Buffer{k})
        strctDesign = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ExperimentDesigns.Buffer{k};
        
        abTrialTypesWithStimulation= zeros(1,length(strctDesign.m_acTrialTypes))>0;
        for j=1:length(strctDesign.m_acTrialTypes)
            abTrialTypesWithStimulation(j) = isfield(strctDesign.m_acTrialTypes{j},'Cue') && ...
                isfield(strctDesign.m_acTrialTypes{j}.Cue,'Stimulation') && strctDesign.m_acTrialTypes{j}.Cue.Stimulation>0;
        end
        
        aiRelevantTrials = find(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.acTrials.TimeStamp >= afDesignsOnset(k) & ...
                                strctKofiko.g_astrctAllParadigms{iParadigmIndex}.acTrials.TimeStamp <= afDesignsOnset(k+1));
        if ~isempty(aiRelevantTrials)
            acTrials = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.acTrials.Buffer(aiRelevantTrials);
            acTrials=fnReanalyzeSaccadeTrials(acTrials,strRawFolder,strSession,strctSync,strctKofiko,a2fTargetCenter,fFixationRadius,fChoiceRadius,abTrialTypesWithStimulation);
            strctKofiko.g_astrctAllParadigms{iParadigmIndex}.acTrials.Buffer(aiRelevantTrials) = acTrials;
        end
    end
end











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
            
            fnCollectForceChoiceStats(strRawFolder,strSession,strctKofiko, strctSync, strctConfig, strctInterval,strOutputFolder,strTrainFile1,strTrainFile2);
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
