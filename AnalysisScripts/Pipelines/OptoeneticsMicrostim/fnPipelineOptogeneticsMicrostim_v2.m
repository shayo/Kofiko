function fnPipelineOptogeneticsMicrostim_v2(strctInputs)
clear global g_acDesignCache

strDataRootFolder = strctInputs.m_strDataRootFolder;
strConfigFolder   = strctInputs.m_strConfigFolder;
strSession        = strctInputs.m_strSession;

if strDataRootFolder(end) ~= filesep()
    strDataRootFolder(end+1) = filesep();
end;
fnWorkerLog('Starting optogenetics microstim standard analysis pipline...');
fnWorkerLog('Session : %s',strSession);
fnWorkerLog('Data Root : %s',strDataRootFolder);

strRawFolder = [strDataRootFolder,'RAW',filesep()];
strKofikoFile = fullfile(strRawFolder,[strSession,'.mat']);
strAdvancerFile = fullfile(strRawFolder,[strSession,'-Advancers.txt']);
strStatServerFile = fullfile(strRawFolder,[strSession,'-StatServerInfo.mat']);
strStrobeFile = fullfile(strRawFolder,[strSession,'-strobe.raw']);
strAnalogFile = fullfile(strRawFolder,[strSession,'-EyeX.raw']);  % any can suffice...
strSyncFile = fullfile(strRawFolder,[strSession,'-sync.mat']);

aiInd = find(strSession=='_');
strSubject = strSession(aiInd(2)+1:end);
strTimeDate = strSession(1:aiInd(2)-1);

strTrainFile = fullfile(strRawFolder,[strSession,'-Grass_Train2.raw']);

strOutputFolder = [strDataRootFolder,'Processed',filesep(),'Optogenetic_Analysis',filesep()];
if ~exist(strOutputFolder,'dir')
    mkdir(strOutputFolder);
end;
strEyeXFile = fullfile(strRawFolder,[strSession,'-EyeX.raw']);
strEyeYFile = fullfile(strRawFolder,[strSession,'-EyeY.raw']);


%% Verify everything is around.

bAllExist = fnCheckForFilesExistence({strKofikoFile, strAdvancerFile, strStatServerFile,...
    strStrobeFile,strAnalogFile,strSyncFile});
if ~bAllExist
    fprintf('************ CRITICAL ERROR - FILE MISSING!\n');
    return;
end
% Load needed information to do processing
load(strSyncFile);
strctKofiko = load(strKofikoFile);
strctStatServer = load(strStatServerFile);

astrctChannelsGridInfo = fnGetChannelGridInfo(strctStatServer);




%%
afParadigmSwitchTS_Kofiko = strctKofiko.g_strctAppConfig.ParadigmSwitch.TimeStamp;
acstrParadigmNames = strctKofiko.g_strctAppConfig.ParadigmSwitch.Buffer;
%% Read advancer file for electrode position during the experiments...
a2fTemp = textread(strAdvancerFile);
afDepthRelativeToGridTop = a2fTemp(:,2);
aiAdvancerUniqueID = a2fTemp(:,1);
afAdvancerChangeTS_StatServer = a2fTemp(:,6);
afAdvancerChangeTS_Plexon = fnTimeZoneChange(afAdvancerChangeTS_StatServer,strctSync,'StatServer','Plexon');

strctAdvancersInformation.m_afDepthRelativeToGridTop = afDepthRelativeToGridTop;
strctAdvancersInformation.m_aiAdvancerUniqueID = aiAdvancerUniqueID;
strctAdvancersInformation.m_afAdvancerChangeTS_Plexon = afAdvancerChangeTS_Plexon;

%% Analyze sorted data only (!)
strSortedUnitsFolder = [strDataRootFolder,'Processed',filesep,'SortedUnits',filesep];
astrctSortedChannels = dir([strSortedUnitsFolder,strSession,'*spikes_ch*_sorted.raw']);

if isempty(astrctSortedChannels)
    fnWorkerLog('No sorted channels found for session %s. Aborting.',strSession);
    return;
end
fnResetWaitbarGlobal(2,3);
iNumSortedChannels = length(astrctSortedChannels);
fnWorkerLog('%d Sorted channel files found',iNumSortedChannels);



for iChannelIter=1:iNumSortedChannels
    fnSetWaitbarGlobal(iChannelIter/length(astrctSortedChannels),2, 3);
    % Only read the intervals and find out whether there is something to analyze....
    strSpikeFile = [strSortedUnitsFolder,astrctSortedChannels(iChannelIter).name];
    [astrctAllUnits,strctChannelInfo] = fnReadDumpSpikeFile(strSpikeFile);
    
    [strOpsin,iGridX,iGridY] = fnGetOpsinFromGridHole(astrctChannelsGridInfo,strSubject,strctChannelInfo.m_iChannelID);
    
    strctChannelInfo.m_iGridX = iGridX;
    strctChannelInfo.m_iGridY = iGridY;
    fnWorkerLog('Analyzing channel %d (%s)',strctChannelInfo.m_iChannelID,strctChannelInfo.m_strChannelName);
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
    
    abRelevantAdvancerEntries = strctAdvancersInformation.m_aiAdvancerUniqueID == iAdvancerUniqueID;
    strctAdvancerInformation.m_afDepth = strctAdvancersInformation.m_afDepthRelativeToGridTop(abRelevantAdvancerEntries);
    strctAdvancerInformation.m_afTS_PLX = strctAdvancersInformation.m_afAdvancerChangeTS_Plexon(abRelevantAdvancerEntries);
    
    iNumSortedUnits = length(astrctUnits);
    fnWorkerLog('%d sorted unit intervals found',iNumSortedUnits);
    fnResetWaitbarGlobal(3,3);
    for iUnitIter=1:iNumSortedUnits
        if all(astrctUnits(iUnitIter).m_afInterval < 0)
            continue;
        end;
        fnSetWaitbarGlobal(iUnitIter/iNumSortedUnits,3, 3);
        fnStandardTrainAnalysis_v2(strSubject,strTimeDate,strctChannelInfo,astrctUnits(iUnitIter), strctAdvancerInformation, strTrainFile,strAnalogChannelFile,strOutputFolder,strOpsin,...
            strEyeXFile,strEyeYFile,strctKofiko,strctSync);
    end
end

return;

function bAllExist = fnCheckForFilesExistence(acFileList)
bAllExist = true;
for k=1:length(acFileList)
    if ~exist(acFileList{k},'file')
        fprintf('File is missing : %s\n',acFileList{k});
        bAllExist = false;
        return;
    end
end




function fnAnalyzeEyeMovementsDuringMicroStimAsFunctionOfDepth(strctKofiko,strctSync,strRawFolder,strSession, iChannelID, strctAdvancersInformation,strctStatServer,strTriggerFile)
strEyeXFile = fullfile(strRawFolder,[strSession,'-EyeX.raw']);
strEyeYFile = fullfile(strRawFolder,[strSession,'-EyeY.raw']);

% Compute eye movement triggered by some channel
[strctTrigger, afTriggerTime] = fnReadDumpAnalogFile(strTriggerFile);
[Dummy,astrctPulseIntervals] = fnIdentifyStimulationTrains(strctTrigger,afTriggerTime, false);

afTrainOnsets_TS_PLX = afTriggerTime( cat(1,astrctPulseIntervals.m_iStart));
% Merge very similar trains
iAdvancerUniqueID = strctStatServer.g_strctNeuralServer.m_a2iChannelToGridHoleAdvancer(iChannelID,3);
fMergeDistanceMM = 0.2;
afSampleAdvancerTimes = afTrainOnsets_TS_PLX;
afIntervalDepthMM= fnMyInterp1(strctAdvancersInformation.m_afAdvancerChangeTS_Plexon(strctAdvancersInformation.m_aiAdvancerUniqueID == iAdvancerUniqueID),...
    strctAdvancersInformation.m_afDepthRelativeToGridTop(strctAdvancersInformation.m_aiAdvancerUniqueID == iAdvancerUniqueID),afSampleAdvancerTimes);
[afUniqueDepthMM, aiMappingToUnique, aiCount] = fnMyUnique(afIntervalDepthMM, fMergeDistanceMM);
fprintf('Found %d unique recording depths for which stimulation was applied\n', length(afUniqueDepthMM));
% For each one of these locations, aggregate all stimulation trains (even
% though they can be different....)
for iDepthIter=1:length(afUniqueDepthMM)
    fprintf('%d Stimulation trains were applied at depth %.2f\n',aiCount(iDepthIter), afUniqueDepthMM(iDepthIter));
    aiTrainIndices = find(aiMappingToUnique == iDepthIter);
    afStartTS = afTrainOnsets_TS_PLX(aiTrainIndices);
    iNumTrials = length(afStartTS);
    % Sample eye movements every 1 MS (way too much..)
    % show PSTH for -500 to +500
    afRangeMS = 0:200;
    iZeroIndex = find(afRangeMS == 0);
    iNumSamplesPerTrial = length(afRangeMS);
    % Sample eye position!
    a2fResampleTimes = zeros(iNumTrials, iNumSamplesPerTrial);
    for k=1:iNumTrials
        a2fResampleTimes(k,:) = afStartTS(k) + afRangeMS/1e3;
    end
    % Sample X & Y
    strctX = fnReadDumpAnalogFile(strEyeXFile,'Resample',a2fResampleTimes);
    strctY= fnReadDumpAnalogFile(strEyeYFile,'Resample',a2fResampleTimes);
    % Align to time zero
    a2fX = strctX.m_afData;%-repmat(strctX.m_afData(:,iZeroIndex),1,iNumSamplesPerTrial);
    a2fY = strctY.m_afData;%-;repmat(strctY.m_afData(:,iZeroIndex),1,iNumSamplesPerTrial);
    a2fGainX = reshape(fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.GainX, 'Kofiko','Plexon',a2fResampleTimes(:), strctSync),size(a2fX));
    a2fGainY = reshape(fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.GainY, 'Kofiko','Plexon',a2fResampleTimes(:), strctSync),size(a2fY));
    a2fOffsetX= reshape(fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.CenterX , 'Kofiko','Plexon',a2fResampleTimes(:), strctSync),size(a2fX));
    a2fOffsetY = reshape(fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.CenterY, 'Kofiko','Plexon',a2fResampleTimes(:), strctSync),size(a2fY));
    a2fXpix = (a2fX+2048 - a2fOffsetX).*a2fGainX + strctKofiko.g_strctStimulusServer.m_aiScreenSize(3)/2;
    a2fYpix = (a2fY+2048 - a2fOffsetY).*a2fGainY + strctKofiko.g_strctStimulusServer.m_aiScreenSize(4)/2;
    
    a2fXpix = a2fXpix-repmat(a2fXpix(:,iZeroIndex),1,iNumSamplesPerTrial);
    a2fYpix= a2fYpix-repmat(a2fYpix(:,iZeroIndex),1,iNumSamplesPerTrial);
    
    figure(12);
    clf;
    subplot(2,1,1);
    hold on;
    for k=1:iNumTrials
        plot(a2fXpix(k,:),a2fYpix(k,:),'r');
        plot(a2fXpix(k,1),a2fYpix(k,1),'b+');
        plot(a2fXpix(k,end),a2fYpix(k,end),'bo');
    end
    axis ij
    box on
    axis equal
    xlabel('pixels');
    ylabel('pixels');
    title(sprintf('Depth %.2f', afUniqueDepthMM(iDepthIter)));
    %     legend({'Eye trace','t=0','t=+200ms'},'Location','NorthEastOutside')
    subplot(2,1,2);
    plot(sqrt(a2fXpix'.^2+a2fYpix'.^2));
    xlabel('Time from stimulation (onset at t=0)');
    ylabel('Distance from t=0');
    %   print( 12, '-dpdf', fn )
end
%%

function fnAnalyzeEyeMovementsDuringMicroStim()
%% Micro stim stimulation that is not linked to a unit interval
% search for unique trains and segment them according to recording
% depth....
% We will average eye movements....
if 0
    [strctTrain, afTrainTime] = fnReadDumpAnalogFile(strTrainFile);
    astrctUniqueTrains = fnIdentifyStimulationTrains(strctTrain,afTrainTime,false);
    afTrainOnsets_TS_PLX = cat(1,astrctUniqueTrains.m_afTrainOffsetTS_Plexon);
    % Merge very similar trains
    
    iChannelID = 1;
    iAdvancerUniqueID = strctStatServer.g_strctNeuralServer.m_a2iChannelToGridHoleAdvancer(iChannelID,3);
    fMergeDistanceMM = 0.2;
    afSampleAdvancerTimes = afTrainOnsets_TS_PLX;
    afIntervalDepthMM= fnMyInterp1(afAdvancerChangeTS_Plexon(aiAdvancerUniqueID == iAdvancerUniqueID), afDepthRelativeToGridTop(aiAdvancerUniqueID == iAdvancerUniqueID),afSampleAdvancerTimes);
    [afUniqueDepthMM, aiMappingToUnique, aiCount] = fnMyUnique(afIntervalDepthMM, fMergeDistanceMM);
    fprintf('Found %d unique recording depths for which stimulation was applied\n', length(afUniqueDepthMM));
    % For each one of these locations, aggregate all stimulation trains (even
    % though they can be different....)
    for iDepthIter=1:length(afUniqueDepthMM)
        fprintf('%d Stimulation trains were applied at depth %.2f\n',aiCount(iDepthIter), afUniqueDepthMM(iDepthIter));
        aiTrainIndices = find(aiMappingToUnique == iDepthIter);
        afStartTS = cat(1,astrctUniqueTrains(aiTrainIndices).m_afTrainOnsetTS_Plexon);
        iNumTrials = length(afStartTS);
        % Sample eye movements every 1 MS (way too much..)
        % show PSTH for -500 to +500
        afRangeMS = 0:200;
        iZeroIndex = find(afRangeMS == 0);
        iNumSamplesPerTrial = length(afRangeMS);
        % Sample eye position!
        a2fResampleTimes = zeros(iNumTrials, iNumSamplesPerTrial);
        for k=1:iNumTrials
            a2fResampleTimes(k,:) = afStartTS(k) + afRangeMS/1e3;
        end
        % Sample X & Y
        strctX = fnReadDumpAnalogFile(strEyeXFile,'Resample',a2fResampleTimes);
        strctY= fnReadDumpAnalogFile(strEyeYFile,'Resample',a2fResampleTimes);
        % Align to time zero
        a2fX = strctX.m_afData;%-repmat(strctX.m_afData(:,iZeroIndex),1,iNumSamplesPerTrial);
        a2fY = strctY.m_afData;%-;repmat(strctY.m_afData(:,iZeroIndex),1,iNumSamplesPerTrial);
        a2fGainX = reshape(fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.GainX, 'Kofiko','Plexon',a2fResampleTimes(:), strctSync),size(a2fX));
        a2fGainY = reshape(fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.GainY, 'Kofiko','Plexon',a2fResampleTimes(:), strctSync),size(a2fY));
        a2fOffsetX= reshape(fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.CenterX , 'Kofiko','Plexon',a2fResampleTimes(:), strctSync),size(a2fX));
        a2fOffsetY = reshape(fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.CenterY, 'Kofiko','Plexon',a2fResampleTimes(:), strctSync),size(a2fY));
        a2fXpix = (a2fX+2048 - a2fOffsetX).*a2fGainX + strctKofiko.g_strctStimulusServer.m_aiScreenSize(3)/2;
        a2fYpix = (a2fY+2048 - a2fOffsetY).*a2fGainY + strctKofiko.g_strctStimulusServer.m_aiScreenSize(4)/2;
        
        a2fXpix = a2fXpix-repmat(a2fXpix(:,iZeroIndex),1,iNumSamplesPerTrial);
        a2fYpix= a2fYpix-repmat(a2fYpix(:,iZeroIndex),1,iNumSamplesPerTrial);
        
        figure(12);
        clf;hold on;
        for k=1:iNumTrials
            plot(a2fXpix(k,:),a2fYpix(k,:),'r');
            plot(a2fXpix(k,1),a2fYpix(k,1),'b+');
            plot(a2fXpix(k,end),a2fYpix(k,end),'bo');
        end
        axis ij
        box on
        axis equal
        xlabel('pixels');
        ylabel('pixels');
        legend({'Eye trace','t=0','t=+200ms'},'Location','NorthEastOutside')
        figure(13);
        subplot(2,1,1);
        plot(a2fXpix');
        xlabel('Time from stimulation (onset at t=0)');
        ylabel('X coordinate');
        subplot(2,1,2);
        plot(a2fYpix');
        xlabel('Time from stimulation (onset at t=0)');
        ylabel('Y coordinate');
    end
end
%%


function [strOpsin, iGridX,iGridY] = fnGetOpsinFromGridHole(astrctChannelsGridInfo,strSubject,iChannel)
strOpsin = 'Unknown';
for k=1:length(astrctChannelsGridInfo)
    if astrctChannelsGridInfo(k).m_iChannel == iChannel
        iGridX =astrctChannelsGridInfo(k).m_fCenterOffsetX ;
        iGridY = astrctChannelsGridInfo(k).m_fCenterOffsetY;
        switch strSubject
            case 'Benjamin'
                strOpsin = 'ChR2';
                break;
            case 'Anakin'
              if (astrctChannelsGridInfo(k).m_fCenterOffsetX == 3) && (astrctChannelsGridInfo(k).m_fCenterOffsetY == 4)  || ...
                 (astrctChannelsGridInfo(k).m_fCenterOffsetX == 3) && (astrctChannelsGridInfo(k).m_fCenterOffsetY == 3)
                        strOpsin  = 'hSyn_hChR2(E123A)';
              elseif (astrctChannelsGridInfo(k).m_fCenterOffsetX == 3) && (astrctChannelsGridInfo(k).m_fCenterOffsetY == 5) || ...
                      (astrctChannelsGridInfo(k).m_fCenterOffsetX == 3) && (astrctChannelsGridInfo(k).m_fCenterOffsetY == 6)
                  strOpsin  = 'CamKII_hChR2(E123A)';
              else
                 strOpsin  = 'hSyn_hChR2(E123A)';
              end
              break;
            case 'Julien'
                if (astrctChannelsGridInfo(k).m_fCenterOffsetX == 0) && (astrctChannelsGridInfo(k).m_fCenterOffsetY == 6) 
                        strOpsin  = 'eNpHR3.0';
                elseif (astrctChannelsGridInfo(k).m_fCenterOffsetX == 3) && (astrctChannelsGridInfo(k).m_fCenterOffsetY == 5) || ...
                        (astrctChannelsGridInfo(k).m_fCenterOffsetX == 2) && (astrctChannelsGridInfo(k).m_fCenterOffsetY == 5) || ...
                        (astrctChannelsGridInfo(k).m_fCenterOffsetX == 2) && (astrctChannelsGridInfo(k).m_fCenterOffsetY == 4)  || ...
                         (astrctChannelsGridInfo(k).m_fCenterOffsetX == 1) && (astrctChannelsGridInfo(k).m_fCenterOffsetY == 5) 
                    strOpsin  = 'ChR2';
                elseif (astrctChannelsGridInfo(k).m_fCenterOffsetX == -1) && (astrctChannelsGridInfo(k).m_fCenterOffsetY == 6) || ...
                        (astrctChannelsGridInfo(k).m_fCenterOffsetX == 0) && (astrctChannelsGridInfo(k).m_fCenterOffsetY == 5) || ...
                        (astrctChannelsGridInfo(k).m_fCenterOffsetX == -1) && (astrctChannelsGridInfo(k).m_fCenterOffsetY == 5)
                    strOpsin  = 'Arch';
                    
                else
                    assert(false);
                end
                break;
            case 'Bert'
                if (astrctChannelsGridInfo(k).m_fCenterOffsetX == -2) && (astrctChannelsGridInfo(k).m_fCenterOffsetY == 1) || ...
                        (astrctChannelsGridInfo(k).m_fCenterOffsetX == -3) && (astrctChannelsGridInfo(k).m_fCenterOffsetY == -3) || ...
                    (astrctChannelsGridInfo(k).m_fCenterOffsetX == -4) && (astrctChannelsGridInfo(k).m_fCenterOffsetY == -3)
                    strOpsin  = 'ChR2';
                elseif (astrctChannelsGridInfo(k).m_fCenterOffsetX ==0) && (astrctChannelsGridInfo(k).m_fCenterOffsetY == -2)
                    strOpsin  = 'eNpHR3.0';
                elseif (astrctChannelsGridInfo(k).m_fCenterOffsetX ==-1) && (astrctChannelsGridInfo(k).m_fCenterOffsetY == -5) ||  ...
                        (astrctChannelsGridInfo(k).m_fCenterOffsetX == -1) && (astrctChannelsGridInfo(k).m_fCenterOffsetY == 6) ||  ...
                        (astrctChannelsGridInfo(k).m_fCenterOffsetX == -1) && (astrctChannelsGridInfo(k).m_fCenterOffsetY == -3) ||  ...
                        (astrctChannelsGridInfo(k).m_fCenterOffsetX == -1) && (astrctChannelsGridInfo(k).m_fCenterOffsetY == -4)  ||  ...
                    (astrctChannelsGridInfo(k).m_fCenterOffsetX == 0) && (astrctChannelsGridInfo(k).m_fCenterOffsetY == -3) 
                    strOpsin  = 'Arch';
                else
                    assert(false);
                    
                end
                break;
        end
        fprintf('-------------------------------------------------------------- X= %d, Y = %d : %s ----------------------------------\n',...
            astrctChannelsGridInfo(k).m_fCenterOffsetX ,astrctChannelsGridInfo(k).m_fCenterOffsetY, strOpsin);
        dbg = 1;
        
    end
end
return
