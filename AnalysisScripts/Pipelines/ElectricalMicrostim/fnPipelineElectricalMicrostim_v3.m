function fnPipelineElectricalMicrostim_v3(strctInputs)
clear global g_acDesignCache

strDataRootFolder = strctInputs.m_strDataRootFolder;
strConfigFolder   = strctInputs.m_strConfigFolder;
strSession        = strctInputs.m_strSession;

if strDataRootFolder(end) ~= filesep()
    strDataRootFolder(end+1) = filesep();
end;
fnWorkerLog('Starting microstim analysis pipline (Assuming channel 1 is electrical and channel 2 is optical)...');
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

strTriggerFile = fullfile(strRawFolder,[strSession,'-Stimulation_Trig.raw']);
strTriggerFile2 = fullfile(strRawFolder,[strSession,'-Stimulation_Trig2.raw']);
strTrainFile = fullfile(strRawFolder,[strSession,'-Grass_Train.raw']);
strTrainFile2 = fullfile(strRawFolder,[strSession,'-Grass_Train2.raw']);

strOutputFolder = [strDataRootFolder,'Processed',filesep(),'Optogenetic_Analysis',filesep()];
if ~exist(strOutputFolder,'dir')
    mkdir(strOutputFolder);
end;

%% Verify everything is around.
fnCheckForFilesExistence({strKofikoFile, strAdvancerFile, strStatServerFile,...
    strStrobeFile,strAnalogFile,strSyncFile,strTriggerFile,strTriggerFile2});

% Load needed information to do processing
load(strSyncFile);
strctKofiko = load(strKofikoFile);
strctStatServer = load(strStatServerFile);

%%
%% Read advancer file for electrode position during the experiments...
a2fTemp = textread(strAdvancerFile);
afDepthRelativeToGridTop = a2fTemp(:,2);
aiAdvancerUniqueID = a2fTemp(:,1);
afAdvancerChangeTS_StatServer = a2fTemp(:,6);
afAdvancerChangeTS_Plexon = fnTimeZoneChange(afAdvancerChangeTS_StatServer,strctSync,'StatServer','Plexon');

strctAdvancersInformation.m_afDepthRelativeToGridTop = afDepthRelativeToGridTop;
strctAdvancersInformation.m_aiAdvancerUniqueID = aiAdvancerUniqueID;
strctAdvancersInformation.m_afAdvancerChangeTS_Plexon = afAdvancerChangeTS_Plexon;

strStatFolder = [strDataRootFolder,filesep,'Processed',filesep,'ElectricalMicrostim',filesep()];
if ~exist(strStatFolder,'dir')
    mkdir(strStatFolder);
end;

% Find triggers on Grass 1. 
% Notice. Due to various issues, it is always safe to record both the
% trigger signal and the actual train. 
% Sometimes triger is sent, but no train is outputed (either because grass
% was off, or because it missed the trigger)

afGrass1Onset_PLX = fnIdentifyStimulationTrainsSafe(strTriggerFile, strTrainFile);
afGrass2Onset_PLX = fnIdentifyStimulationTrainsSafe(strTriggerFile2, strTrainFile2);

aiActiveRecordingChannels = strctStatServer.g_strctNeuralServer.m_aiActiveSpikeChannels;
for k=1:length(aiActiveRecordingChannels)
    iChannelID=aiActiveRecordingChannels(k);
    fnAnalyzeEyeMovementsDuringMicroStimAsFunctionOfDepth(strctKofiko,strctSync,strRawFolder,...
        strSession,iChannelID, strctAdvancersInformation,strctStatServer,afGrass1Onset_PLX, afGrass2Onset_PLX,strStatFolder);
end

return;

function fnCheckForFilesExistence(acFileList)
for k=1:length(acFileList)
    if ~exist(acFileList{k},'file')
        fprintf('File is missing : %s\n',acFileList{k});
        error('FileMissing');
    end
end




function fnAnalyzeEyeMovementsDuringMicroStimAsFunctionOfDepth(strctKofiko,strctSync,strRawFolder,strSession, iChannelID, strctAdvancersInformation,strctStatServer,afGrass1Onset_PLX, afGrass2Onset_PLX, strOutputFolder)

iNumTrainsGrass1 = length(afGrass1Onset_PLX);
iNumTrainsGrass2 = length(afGrass2Onset_PLX);
afAmplitudeGrass1 = zeros(1,iNumTrainsGrass1);
afAmplitudeGrass2 = zeros(1,iNumTrainsGrass2);

afTriggerTS_PLX=fnTimeZoneChange(strctKofiko.g_strctDAQParams.MicroStimTriggers.TimeStamp,strctSync,'Kofiko','Plexon');
iNumKofikoTrains = length(afTriggerTS_PLX);
aiChannel = zeros(1,iNumKofikoTrains);
for j=2:iNumKofikoTrains
    aiChannel(j) = strctKofiko.g_strctDAQParams.MicroStimTriggers.Buffer{j}.m_iChannel;
end


for i=1:iNumTrainsGrass1
    aiRelevantPulses = find(aiChannel == 1);
    [fDummy, iIndex]=min(abs(afGrass1Onset_PLX(i)-afTriggerTS_PLX(aiRelevantPulses)));
    afAmplitudeGrass1(i) = strctKofiko.g_strctDAQParams.MicroStimTriggers.Buffer{aiRelevantPulses(iIndex)}.m_fAmplitude;
end
for i=1:iNumTrainsGrass2
    aiRelevantPulses = find(aiChannel == 2);
    [fDummy, iIndex]=min(abs(afGrass2Onset_PLX(i)-afTriggerTS_PLX(aiRelevantPulses)));
    afAmplitudeGrass2(i) = strctKofiko.g_strctDAQParams.MicroStimTriggers.Buffer{aiRelevantPulses(iIndex)}.m_fAmplitude;
end

% Assume simulatenous trains were delivered within 2ms of each other. 
% Most of the time, it will either be close to 0 or 1.25 ms

afMinTimeSec = zeros(1,iNumTrainsGrass1);
aiMinIndex = zeros(1,iNumTrainsGrass1);
for i=1:iNumTrainsGrass1
        [afMinTimeSec(i), aiMinIndex(i)]=min(abs(afGrass1Onset_PLX(i)-afGrass2Onset_PLX));
end
abSimulatenousTrains1 = afMinTimeSec < 2*1e-3;

afMinTimeSec = zeros(1,iNumTrainsGrass2);
aiMinIndex = zeros(1,iNumTrainsGrass2);
for i=1:iNumTrainsGrass2
        [afMinTimeSec(i), aiMinIndex(i)]=min(abs(afGrass2Onset_PLX(i)-afGrass1Onset_PLX));
end
abSimulatenousTrains2 = afMinTimeSec < 2*1e-3;

%
%

[afAllTrainOnsetsTS_Sorted, aiTmp] = sort([afGrass1Onset_PLX, afGrass2Onset_PLX]);
afAllAmplitudes = [afAmplitudeGrass1,afAmplitudeGrass2];
afAllAmplitudesSorted = afAllAmplitudes(aiTmp);

abSimulatenous = [abSimulatenousTrains1,abSimulatenousTrains2];
abSimulatenousSorted = abSimulatenous(aiTmp);
aiAllTrainsToIndividalChannel = [ones(1,iNumTrainsGrass1),  2*ones(1,iNumTrainsGrass2)];
aiAllTrainBackToChannelID = aiAllTrainsToIndividalChannel(aiTmp);

% Analyze by depth. Don't care about intervals (?)
iAdvancerUniqueID = strctStatServer.g_strctNeuralServer.m_a2iChannelToGridHoleAdvancer(iChannelID,3);
fMergeDistanceMM = 0.05;
afSampleAdvancerTimes = afAllTrainOnsetsTS_Sorted;
afIntervalDepthMM= fnMyInterp1(...
    strctAdvancersInformation.m_afAdvancerChangeTS_Plexon(strctAdvancersInformation.m_aiAdvancerUniqueID == iAdvancerUniqueID),...
    strctAdvancersInformation.m_afDepthRelativeToGridTop(strctAdvancersInformation.m_aiAdvancerUniqueID == iAdvancerUniqueID),...
    afSampleAdvancerTimes);

[afUniqueDepthMM, aiMappingToUnique, aiCount] = fnMyUnique(afIntervalDepthMM, fMergeDistanceMM);
fnWorkerLog('Found %d unique recording depths for which stimulation was applied', length(afUniqueDepthMM));
% For each one of these locations, aggregate all stimulation trains (even
% though they can be different....)

% For each one of these depths, generate analysis for
% 1. Grass 1
% 2. Grass 2
% 3. Grass 1 And Grass 2


[acUniqueParadigms, Dummy, aiMappingParadigmsToUnique] = unique(strctKofiko.g_strctAppConfig.ParadigmSwitch.Buffer);
afParadigmSwitch_TS_PLX= fnTimeZoneChange(strctKofiko.g_strctAppConfig.ParadigmSwitch.TimeStamp,strctSync,'Kofiko','Plexon');
aiActiveParadigmDuringStimulation = fnMyInterp1(afParadigmSwitch_TS_PLX,aiMappingParadigmsToUnique, afAllTrainOnsetsTS_Sorted);
aiRelevantParadigmIndices = aiMappingParadigmsToUnique(ismember(acUniqueParadigms,{'Five Dot Eye Calibration','Passive Fixation New'}));
abRelevantStimulationPulses = ismember(aiActiveParadigmDuringStimulation, aiRelevantParadigmIndices);

% Figure out whether the fixation spot was on the screen or not ?
% Bit tricky. 
%abFixationOnScreen = fnDetermineWhetherFixationSpotWasOnScreen(strctKofiko,strctSync,afAllTrainOnsetsTS_Sorted);
dbg = 1;


for iDepthIter=1:length(afUniqueDepthMM)
    
    aiTrainIndices = find(aiMappingToUnique == iDepthIter & abRelevantStimulationPulses);

    afTrainsTS = afAllTrainOnsetsTS_Sorted(aiTrainIndices);
    abTrainsCh1 = aiAllTrainBackToChannelID(aiTrainIndices) == 1;
    abTrainsCh2 = aiAllTrainBackToChannelID(aiTrainIndices) == 2;
    afAmplitudes = afAllAmplitudesSorted(aiTrainIndices);
    abAtSameTime = abSimulatenousSorted(aiTrainIndices);
    
    afTrainsGrass1TS = afTrainsTS(abTrainsCh1 &~abAtSameTime);
    afTrainsGrass2TS = afTrainsTS(abTrainsCh2 &~abAtSameTime);
    afTrainsBothGrass = afTrainsTS(abTrainsCh1&abAtSameTime);
    afAmplitude1 = afAmplitudes(abTrainsCh1&~abAtSameTime);
    afAmplitude2 = afAmplitudes(abTrainsCh2&~abAtSameTime);
    
    afAmplitudeBoth = afAmplitudes(abTrainsCh1&abAtSameTime); % Take amplitude from grass 1
    
%     if bCropToLastSim
%         iLastSim = find(abAtSameTime,1,'last');
%         fLastTS = afAllTrainOnsetsTS_Sorted(iLastSim);
%         if ~isempty(fLastTS)
%         afTrainsGrass1TS=afTrainsGrass1TS(afTrainsGrass1TS<=fLastTS);
%         afTrainsGrass2TS=afTrainsGrass2TS(afTrainsGrass2TS<=fLastTS);
%         afTrainsBothGrass=afTrainsBothGrass(afTrainsBothGrass<=fLastTS);
%         afAmplitude1 = afAmplitude1(afTrainsGrass1TS<=fLastTS);
%         afAmplitude2 = afAmplitude2(afTrainsGrass2TS<=fLastTS);
%         afAmplitudeBoth = afAmplitudeBoth(afTrainsBothGrass<=fLastTS);
%         end
%     end
    
    fnWorkerLog('Depth %.2f ',afUniqueDepthMM(iDepthIter));
    fnWorkerLog('%d Trains from grass 1', length(afTrainsGrass1TS));
    fnWorkerLog('%d Trains from grass 2', length(afTrainsGrass2TS));
    fnWorkerLog('%d Trains from grass 1 & 2', length(afTrainsBothGrass));
    
    if length(afTrainsGrass1TS) > 0
        fnAnalyzeEyeMovementsDuringMicroStimAsFunctionOfDepthAux(strctKofiko,strctSync,strRawFolder,strSession, iChannelID, strctAdvancersInformation,strctStatServer,afTrainsGrass1TS, afAmplitude1,strOutputFolder,'Grass1',afUniqueDepthMM(iDepthIter));
    end
    if length(afTrainsGrass2TS) > 0
        fnAnalyzeEyeMovementsDuringMicroStimAsFunctionOfDepthAux(strctKofiko,strctSync,strRawFolder,strSession, iChannelID, strctAdvancersInformation,strctStatServer,afTrainsGrass2TS, afAmplitude2,strOutputFolder,'Grass2',afUniqueDepthMM(iDepthIter));
    end
    if length(afTrainsBothGrass)
        fnAnalyzeEyeMovementsDuringMicroStimAsFunctionOfDepthAux(strctKofiko,strctSync,strRawFolder,strSession, iChannelID, strctAdvancersInformation,strctStatServer,afTrainsBothGrass, afAmplitudeBoth, strOutputFolder,'Grass1and2',afUniqueDepthMM(iDepthIter));
    end
end


return;

function fnAnalyzeEyeMovementsDuringMicroStimAsFunctionOfDepthAux(strctKofiko,strctSync,strRawFolder,strSession, iChannelID, strctAdvancersInformation,strctStatServer,afTrainOnset_PLX, afAmplitude, strOutputFolder, strTriggerChannel, fDepthMM)
strEyeXFile = fullfile(strRawFolder,[strSession,'-EyeX.raw']);  
strEyeYFile = fullfile(strRawFolder,[strSession,'-EyeY.raw']);  
strPupilFile = fullfile(strRawFolder,[strSession,'-Eye Pupil.raw']);

strSubject = strctKofiko.g_strctAppConfig.m_strctSubject.m_strName;
strTimeDate = strctKofiko.g_strctAppConfig.m_strTimeDate;
strTimeDate(strTimeDate == ':') = '-';
strTimeDate(strTimeDate == ' ') = '_';

afRangeMS = -200:1000;

% Sort by amplitude
if sum(isnan(afAmplitude)) > 0
    afUniqueAmplitudes = [NaN,unique(afAmplitude(~isnan(afAmplitude)))];
else
    afUniqueAmplitudes = unique(afAmplitude);
end

for iAmpIter=1:length(afUniqueAmplitudes)
    if isnan(afUniqueAmplitudes(iAmpIter))
        abRelevantTrains = isnan(afAmplitude);
    else
        abRelevantTrains = afAmplitude == afUniqueAmplitudes(iAmpIter);
    end
    fnWorkerLog('%d Stimulation trains were applied at depth %.2f at amplitude %.2f',...
        sum(abRelevantTrains), fDepthMM, afUniqueAmplitudes(iAmpIter));
    
    afStartTS = afTrainOnset_PLX(abRelevantTrains);
    
    abFixationOnScreen = fnDetermineWhetherFixationSpotWasOnScreen(strctKofiko,strctSync,afStartTS);

    iNumTrials = length(afStartTS);
    % Sample eye movements every 1 MS (way too much..)
    % show PSTH for -500 to +500
    iZeroIndex = find(afRangeMS == 0);
    iNumSamplesPerTrial = length(afRangeMS);
    % Sample eye position!
    a2fResampleTimes = zeros(iNumTrials, iNumSamplesPerTrial);
    for k=1:iNumTrials
        a2fResampleTimes(k,:) = afStartTS(k) + afRangeMS/1e3;
    end
    % Sample X & Y
    strctP = fnReadDumpAnalogFile(strPupilFile,'Resample',a2fResampleTimes);
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

    a2fXpix_nozero = a2fXpix;
    a2fYpix_nozero = a2fYpix;
    a2fXpix = a2fXpix-repmat(a2fXpix(:,iZeroIndex),1,iNumSamplesPerTrial);
    a2fYpix= a2fYpix-repmat(a2fYpix(:,iZeroIndex),1,iNumSamplesPerTrial);
    a2fPupil = strctP.m_afData - repmat(strctP.m_afData(:,iZeroIndex),1,iNumSamplesPerTrial);
    
    strctStat.m_afTrainOnset = afStartTS;
    strctStat.m_a2fXpix = a2fXpix;
    strctStat.m_a2fYpix = a2fYpix;
    strctStat.m_a2fPupil = a2fPupil;
    
    strctStat.m_a2fXpix_nozero = a2fXpix_nozero;
    strctStat.m_a2fYpix_nozero = a2fYpix_nozero;
    strctStat.m_a2fPupil_nozero = strctP.m_afData;
    
    strctStat.m_fDepth = fDepthMM;
    strctStat.m_fAmplitude = afUniqueAmplitudes(iAmpIter);
    strctStimStat.m_astrctStimulation(iAmpIter) = strctStat;

end
strDepth = sprintf('%.2f',fDepthMM);
strDepth(strDepth=='.')='-';

strctStimStat.m_afRangeMS= afRangeMS;
strctStimStat.m_strDisplayFunction = 'fnDefaultElectricalStimDisplayFunc';
strctStimStat = fnAddAttribute(strctStimStat,'Subject', strSubject);
strctStimStat = fnAddAttribute(strctStimStat,'TimeDate', strctKofiko.g_strctAppConfig.m_strTimeDate);
strctStimStat = fnAddAttribute(strctStimStat,'Type','Microstim Saccade');
strctStimStat = fnAddAttribute(strctStimStat,'Channel', num2str(iChannelID));
strctStimStat = fnAddAttribute(strctStimStat,'Trigger', strTriggerChannel);
strctStimStat = fnAddAttribute(strctStimStat,'Depth', sprintf('%.2f',fDepthMM));

strStatFile = [strOutputFolder, filesep, strSubject,'-',strTimeDate,'_Microstim_Channel_',num2str(iChannelID),'_Depth_',strDepth,'_Trig_',strTriggerChannel,'.mat'];
fnWorkerLog('Saving things to %s',strStatFile);
save(strStatFile,'strctStimStat');
return;

function abFixationOnScreen = fnDetermineWhetherFixationSpotWasOnScreen(strctKofiko,strctSync,afAllTrainOnsetsTS_Sorted)
% This is a bit tricky.
% If this was during five dot, then fixation spot can be determined from
% the fixation spot variable.
%However, when this was ran with passive fixation, either fixation spot was
%on,  of it was off all the time, and the stimulus itself contained the
%fixation spot....
%
% This will be invalid for all other paradigms...
iNumStimulation = length(afAllTrainOnsetsTS_Sorted);
abFixationOnScreen = ones(1,iNumStimulation)>0; % Assume is on...
[acUniqueParadigms, Dummy, aiMappingParadigmsToUnique] = unique(strctKofiko.g_strctAppConfig.ParadigmSwitch.Buffer);
afParadigmSwitch_TS_PLX= fnTimeZoneChange(strctKofiko.g_strctAppConfig.ParadigmSwitch.TimeStamp,strctSync,'Kofiko','Plexon');
aiActiveParadigmDuringStimulation = fnMyInterp1(afParadigmSwitch_TS_PLX,aiMappingParadigmsToUnique, afAllTrainOnsetsTS_Sorted);
iPassiveFixationIndex= aiMappingParadigmsToUnique(ismember(acUniqueParadigms,{'Passive Fixation New'}));
iFiveDotIndex = aiMappingParadigmsToUnique(ismember(acUniqueParadigms,{'Five Dot Eye Calibration'}));
aiStimulationDuringFiveDot = find(aiActiveParadigmDuringStimulation == iFiveDotIndex);

if ~isempty(aiStimulationDuringFiveDot) 
    iParadigmIndex = fnFindParadigmIndex(strctKofiko,'Five Dot Eye Calibration');
    afFixationSpotChangeTS_PLX = fnTimeZoneChange(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.FixationSizePix.TimeStamp, strctSync,'Kofiko','Plexon');
    afFixationSpotSizePix = fnMyInterp1(afFixationSpotChangeTS_PLX,  strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.FixationSizePix.Buffer,  afAllTrainOnsetsTS_Sorted(aiStimulationDuringFiveDot));
    abFixationOnScreen(aiStimulationDuringFiveDot) = afFixationSpotSizePix > 0;
end

aiStimulationDuringPassiveFixation = find(aiActiveParadigmDuringStimulation == iPassiveFixationIndex);
if ~isempty(aiStimulationDuringPassiveFixation)
    % Tricky bit..
      iParadigmIndex = fnFindParadigmIndex(strctKofiko,'Passive Fixation New');
      strctParadigm = strctKofiko.g_astrctAllParadigms{iParadigmIndex};
      % First, the easy part:
      afFixationSpotChangeTS_PLX = fnTimeZoneChange(strctParadigm.FixationSizePix.TimeStamp, strctSync,'Kofiko','Plexon');
      afFixationSpotSizePix = fnMyInterp1(afFixationSpotChangeTS_PLX,  strctParadigm.FixationSizePix.Buffer,  afAllTrainOnsetsTS_Sorted(aiStimulationDuringPassiveFixation));
       % now, identify which stimulus was on....

       afStimulation_TS_Kofiko = fnTimeZoneChange(afAllTrainOnsetsTS_Sorted(aiStimulationDuringPassiveFixation),strctSync,'Plexon','Kofiko');
       [aiImageIndex, aiDesignIndex, acDesignNames] = fnIdentifyWhichImageWasOnScreenDuringPassiveFixation(strctParadigm, strctSync, afStimulation_TS_Kofiko);
      
end
return;



function [aiImageIndex, aiDesignIndex, acDesignNames] = fnIdentifyWhichImageWasOnScreenDuringPassiveFixation(strctParadigm, strctSync, afSampleTS_Kofiko)
% This function will identify what which image presented a given time during
% passive fixation. If no image was on screen (i.e., OFF period), the image
% index will be 0. 
% Inputs:
% 1. strctParadigm, corresponding to the passive fixation
% 2. Sync
% 3. Sample times in Kofiko time zone
%
% outputs:
% 1. aiImageIndex - the index to the corresponding image name, given by acImageName
% or, zero, if the time was during an OFF period
% 2. aiDesignIndex - the index to which the corresponding image belonged
% to, given by acDesignNames. or 0 if it was during an off period.
 
% first, find all image onset times and build a large array....

% Trial info holds:
% [Image Index, Flip ON (Stim Server), Flip OFF (Stim Server),...]

aiStimulusIndex = strctParadigm.Trials.Buffer(1,:);
iNumStimuliPresented = length(aiStimulusIndex);
afFlipON_TS_StimServ= strctParadigm.Trials.Buffer(2,:);
afFlipON_TS_Kofiko = fnTimeZoneChange(afFlipON_TS_StimServ,strctSync,'StimulusServer','Kofiko');
% Sample the "ON" Duration 
afStimON_Time_MS = fnMyInterp1(strctParadigm.StimulusON_MS.TimeStamp, strctParadigm.StimulusON_MS.Buffer,afFlipON_TS_Kofiko);
afStimOFF_Time_MS = fnMyInterp1(strctParadigm.StimulusOFF_MS.TimeStamp, strctParadigm.StimulusOFF_MS.Buffer,afFlipON_TS_Kofiko);

[acUniqueImageLists, Dummy, aiMappingToUniqueList] = unique(strctParadigm.ImageList.Buffer);
aiActiveDesign = fnMyInterp1(strctParadigm.ImageList.TimeStamp,aiMappingToUniqueList, afFlipON_TS_Kofiko);

% Now, augument the stimulus with OFF periods....
afAugTS = [];
aiAugStimulusIndex = [];
aiAugDesignIndex = [];
for iStimIter=1:iNumStimuliPresented
    afAugTS = [afAugTS, afFlipON_TS_Kofiko(iStimIter)];
    aiAugStimulusIndex = [aiAugStimulusIndex, aiStimulusIndex(iStimIter)];
    aiAugDesignIndex = [aiAugDesignIndex, aiActiveDesign(iStimIter)];
    if afStimOFF_Time_MS(iStimIter) > 0
        afAugTS = [afAugTS,   afFlipON_TS_Kofiko(iStimIter)+afStimON_Time_MS(iStimIter)/1e3];
        aiAugStimulusIndex = [aiAugStimulusIndex,0];
        aiAugDesignIndex = [aiAugDesignIndex,0];
    end
end
    
aiImageIndex = fnMyInterp1(afAugTS, aiAugStimulusIndex, afSampleTS_Kofiko);
aiDesignIndex = fnMyInterp1(afAugTS, aiAugDesignIndex, afSampleTS_Kofiko);
acDesignNames = acUniqueImageLists;
