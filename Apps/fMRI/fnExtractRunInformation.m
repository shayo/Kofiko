function astrctRuns = fnExtractRunInformation(acInputKofikoFolders)
% Reads all kofiko files found in the given folders. 
% It then parse them and extracts the relevant information for each of the
% recorded runs (i.e., all the parameters that were used to display the
% images, etc).
% 
%
% Information contains:
%     m_strKofikoFile   - Which kofiko file information came from 
%     m_iRunCounter     - which recorded experiment it was
%     m_fRunTimeSec     - how long the recorded session was
%     m_fRunStartTS     - When it started (relative to something...)
%     m_fRunEndTS       - When it was ended 
%     m_strImageList    - which image list was used
%     m_acBlockOrder    - the actual blocks that were displayed
%     m_fTR_MS          - TR (in ms) that was entered in Kofiko
%     m_iNumTRsPerBlock - Number of TRs per block
%     m_iNumBlocks      - Number of blocks
%     m_iTotalNumberOfTRs
%     m_iNumberOfCountedTRs
%     m_iActualNumberOfImagesDisplayed
%     m_iNumberOfImagesShouldHaveDisplayed
%     m_afDrawAttentionEventsRelativeSec
%     m_strKofikoStartupTime  - String describing the date & time kofiko
%     was started
%     m_afAverageFixationDist - median value of distance to fixation spot
%     during a TR
%     m_fStimulusSizePix    - half size of the image
%     m_fRewardRegionPix    - half size of the reward region
%     m_strUserDescription  - description given to the experiment
%     (typically "Experiment X" or "Aborted X"

if ~iscell(acInputKofikoFolders) && ischar(acInputKofikoFolders)
    acInputKofikoFolders = {acInputKofikoFolders};
end

% Constants
strBlockDesignParadigmName = 'fMRI Block Design';
strBlockDesignParadigmNameNew = 'fMRI Block Design New';
%%
for iFolderIter=1:length(acInputKofikoFolders)
    strKofikoInputFolder = acInputKofikoFolders{iFolderIter};
    astrctFiles = dir([strKofikoInputFolder,'/*.mat']);
    acKofiko = cell(0);
    acKofikoFileNames = cell(0);
    iCounter = 1;
    for iFileIter=1:length(astrctFiles)
        % load and verify it is a kofiko file
        fprintf('Reading %s...',fullfile(strKofikoInputFolder,astrctFiles(iFileIter).name));
        strctKofiko = load(fullfile(strKofikoInputFolder,astrctFiles(iFileIter).name));
        fprintf('Done!\n');
        if isfield(strctKofiko,'g_astrctAllParadigms') % Valid kofiko file
            fprintf('* Detected file %s as a valid Kofiko log \n',fullfile(strKofikoInputFolder,astrctFiles(iFileIter).name));
            acKofiko{iCounter} = strctKofiko;
            acKofikoFileNames{iCounter} = astrctFiles(iFileIter).name;
            iCounter = iCounter + 1;
        end
    end
end

% Iterate files and extract run information
iNumKofikoLogs = length(acKofiko);
iGlobalRunCounter = 1;
astrctRuns = [];
for iLogIter=1:iNumKofikoLogs
    fprintf('------------------------------------\n');
    strctKofiko = acKofiko{iLogIter};
    iParadigmIndexOld = fnFindParadigmIndex(strctKofiko, strBlockDesignParadigmName);
    iParadigmIndexNew = fnFindParadigmIndex(strctKofiko, strBlockDesignParadigmNameNew);
    
    if isempty(iParadigmIndexOld) && isempty(iParadigmIndexNew)
        fprintf('Block design paradigm was not found in Kofiko log\n');
        continue;
    end
    
    if iParadigmIndexOld
        astrctRuns = [astrctRuns, fnExtractInformationOld(strctKofiko,iParadigmIndexOld, acKofikoFileNames{iLogIter})];
    else
        astrctRuns = [astrctRuns, fnExtractInformationNew(strctKofiko,iParadigmIndexNew, acKofikoFileNames{iLogIter})];
    end
    
  
end

return;


%%
function astrctRuns = fnExtractInformationNew(strctKofiko,iParadigmIndex, strLogFile)
aiKofikoStartInd = find(strctKofiko.g_strctDAQParams.LastStrobe.Buffer == strctKofiko.g_strctSystemCodes.m_iStartRecord);
aiKofikoEndInd = find(strctKofiko.g_strctDAQParams.LastStrobe.Buffer == strctKofiko.g_strctSystemCodes.m_iStopRecord);

aiKofikoStartRecTS = strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(aiKofikoStartInd);
aiKofikoEndRecTS = strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(aiKofikoEndInd);

if length(aiKofikoStartInd) ~= length(aiKofikoEndInd)
    % Weird....
    fprintf('CRITICAL ERROR * * * mismatch in the number of start record and end record events!\n');
    fprintf('Attempting to recover...\n');
    if  length(aiKofikoStartInd) == length(aiKofikoEndInd) + 1
        
        
    % A crash occurred ?
    % Try dumping the first entry
    
        if std(aiKofikoEndRecTS-aiKofikoStartRecTS(2:end)) < std(aiKofikoEndRecTS-aiKofikoStartRecTS(1:end-1))
           aiKofikoStartInd = aiKofikoStartInd(2:end);
           aiKofikoStartRecTS = aiKofikoStartRecTS(2:end);
        else
            aiKofikoStartInd = aiKofikoStartInd(1:end-1);
            aiKofikoStartRecTS = aiKofikoStartRecTS(1:end-1);
        end
        
    else
        assert(false);
    end;
end



strctParadigm = strctKofiko.g_astrctAllParadigms{iParadigmIndex};

iNumRuns = length(aiKofikoEndRecTS);

acRecordedRuns = strctParadigm.RecordedRun.Buffer(2:end);

fprintf('%d Recorded experiments detected in %s.\n', iNumRuns,strLogFile);

% For each run, identify which image list was used, which blocks, and
% what was their order....
iGlobalRunCounter = 1;
astrctRuns = [];

for iRunIter=1:iNumRuns
    clear strctRun
    %      fprintf('Run %d out of %d\n',iRunIter,iNumRuns);
    strctRun.m_strKofikoFile = strLogFile;
    strctRun.m_strKofikoStartupTime = strctKofiko.g_strctAppConfig.m_strTimeDate;
    strctRun.m_iRunCounter = iRunIter;
    strctRun.m_strUserDescription = strctParadigm.m_acExperimentDescription{iRunIter};
    
    strctRun.m_fRunTimeSec = round(aiKofikoEndRecTS(iRunIter)-aiKofikoStartRecTS(iRunIter));
    fprintf('Run %d : %d sec (%d min and %d sec)\n', iRunIter,strctRun.m_fRunTimeSec,floor(strctRun.m_fRunTimeSec/60),strctRun.m_fRunTimeSec-floor(strctRun.m_fRunTimeSec/60)*60 );
    strctRun.m_fRunStartTS = aiKofikoStartRecTS(iRunIter);
    strctRun.m_fRunEndTS = aiKofikoEndRecTS(iRunIter);
    
    % look at the recorded run structure.
    strctRun.m_strctDesign = fnMyInterp1String(strctParadigm.Designs, strctRun.m_fRunStartTS);
    strctRun.m_strctRunInformation = acRecordedRuns{iRunIter};
    strctRun.m_strDesignName = strctRun.m_strctDesign.m_strDesignFileName;
    strctRun.m_acBlockOrder = fnReplaceSpace(acRecordedRuns{iRunIter}.m_acBlockNamesWithMicroStim);
    strctRun.m_fTR_MS = acRecordedRuns{iRunIter}.m_fTR_MS;
    
    strctRun.m_aiNumTRsPerBlock = strctRun.m_strctRunInformation.m_aiNumTRperBlock;
    strctRun.m_iNumBlocks = length(strctRun.m_acBlockOrder);
    strctRun.m_iTotalNumberOfTRs = sum(strctRun.m_aiNumTRsPerBlock);
    
    aiInd = find(strctKofiko.g_strctDAQParams.m_astrctExternalTriggers(1).Trigger.TimeStamp >= strctRun.m_fRunStartTS-1 & ...
        strctKofiko.g_strctDAQParams.m_astrctExternalTriggers(1).Trigger.TimeStamp <= strctRun.m_fRunEndTS+1);
    if isempty(aiInd)
        strctRun.m_iNumberOfCountedTRs = 0;
    else
        strctRun.m_iNumberOfCountedTRs = sum(strctKofiko.g_strctDAQParams.m_astrctExternalTriggers(1).Trigger.Buffer(aiInd) == 1);
    end
    
    afSampleTime = strctRun.m_fRunStartTS:0.01:strctRun.m_fRunEndTS; % 10 ms intervals
    [afDistToFixationSpotPix,abInsideStimRect,abInsideGazeRect,afStimulusSizePix,afGazeBoxPix,afEyeXpix,afEyeYpix] = fnGetEyeTrackingInformationFromRun(strctKofiko, afSampleTime,iParadigmIndex);
    strctRun.m_afEyeSampleTime = afSampleTime- strctRun.m_fRunStartTS;
    strctRun.m_afEyeXpix = afEyeXpix;
    strctRun.m_afEyeYpix = afEyeYpix;
    
    strctRun.m_fStimulusSizePix = afStimulusSizePix(1);
    strctRun.m_fRewardRegionPix = afGazeBoxPix(1);
    
    % Determine whether the monkey was fixating in a given TR
    strctRun.m_afAverageFixationDist = zeros(1,strctRun.m_iNumberOfCountedTRs);
    for iTRIter=1:strctRun.m_iTotalNumberOfTRs
        fTRStartTimeTS = (iTRIter-1)*strctRun.m_fTR_MS/1e3 + strctRun.m_fRunStartTS;
        fTREndTimeTS = (iTRIter)*strctRun.m_fTR_MS/1e3 + strctRun.m_fRunStartTS;
        aiIndices = find(afSampleTime >=fTRStartTimeTS &  afSampleTime < fTREndTimeTS);
        if ~isempty(aiIndices)
            strctRun.m_afAverageFixationDist(iTRIter) = median(afDistToFixationSpotPix(aiIndices));
            strctRun.m_a2fEyeData = [afSampleTime(aiIndices);afDistToFixationSpotPix(aiIndices);];
        else
            strctRun.m_afAverageFixationDist(iTRIter) = NaN;
        end
    end
    
    aiFlipInd =find(strctParadigm.FlipTime.TimeStamp >= strctRun.m_fRunStartTS & strctParadigm.FlipTime.TimeStamp <= strctRun.m_fRunEndTS);
    strctRun.m_iActualNumberOfImagesDisplayed = length(aiFlipInd)-1;
    strctRun.m_iNumberOfImagesShouldHaveDisplayed = length(strctRun.m_strctRunInformation.m_aiMediaList);
    
    if isfield(strctParadigm,'DrawAttentionEvents')
        aiDrawAttentionEventsInd = find(strctParadigm.DrawAttentionEvents.TimeStamp >= strctRun.m_fRunStartTS & strctParadigm.DrawAttentionEvents.TimeStamp <= strctRun.m_fRunEndTS);
        if isempty(aiDrawAttentionEventsInd )
            strctRun.m_afDrawAttentionEventsRelativeSec = [];
        else
            strctRun.m_afDrawAttentionEventsRelativeSec = strctParadigm.DrawAttentionEvents.TimeStamp(aiDrawAttentionEventsInd)-strctRun.m_fRunStartTS;
            fprintf('- %d Draw Attention Events detected\n',length(aiDrawAttentionEventsInd));
        end
    else
        strctRun.m_afDrawAttentionEventsRelativeSec = [];
    end
    
    
    if strctRun.m_iNumberOfImagesShouldHaveDisplayed == strctRun.m_iActualNumberOfImagesDisplayed
        %  fprintf('All %d images were displayed correctly \n',strctRun.m_iNumberOfImagesShouldHaveDisplayed);
    else
        fprintf('Only %d images, out of %d were displayed\n', strctRun.m_iActualNumberOfImagesDisplayed,strctRun.m_iNumberOfImagesShouldHaveDisplayed );
    end
    
    if strctRun.m_iNumberOfCountedTRs == strctRun.m_iTotalNumberOfTRs
        % fprintf('All %d TRs were detected correctly by Kofiko\n',strctRun.m_iTotalNumberOfTRs)
    else
         fprintf('Only %d out of %d TRs were detected correctly by Kofiko\n',strctRun.m_iNumberOfCountedTRs,strctRun.m_iTotalNumberOfTRs)
    end
    
    if iGlobalRunCounter == 1
        astrctRuns = strctRun;
    else
        astrctRuns(iGlobalRunCounter) = strctRun;
    end
    iGlobalRunCounter = iGlobalRunCounter + 1;
    
end



%% Used for Kofiko files prior to v2.0 (Rev 81)
% This kofiko version did not support multiple orders / different TR for
% different blocks / ....
function astrctRuns = fnExtractInformationOld(strctKofiko,iParadigmIndex,strLogFile)
aiKofikoStartInd = find(strctKofiko.g_strctDAQParams.LastStrobe.Buffer == strctKofiko.g_strctSystemCodes.m_iStartRecord);
aiKofikoStartRecTS = strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(aiKofikoStartInd);
aiKofikoEndInd = find(strctKofiko.g_strctDAQParams.LastStrobe.Buffer == strctKofiko.g_strctSystemCodes.m_iStopRecord);
aiKofikoEndRecTS = strctKofiko.g_strctDAQParams.LastStrobe.TimeStamp(aiKofikoEndInd);

iNumRuns = length(aiKofikoEndRecTS);
fprintf('%d Recorded experiments detected in %s.\n', iNumRuns,strLogFile);

% For each run, identify which image list was used, which blocks, and
% what was their order....
strctParadigm = strctKofiko.g_astrctAllParadigms{iParadigmIndex};
iGlobalRunCounter = 1;
astrctRuns = [];

for iRunIter=1:iNumRuns
    %      fprintf('Run %d out of %d\n',iRunIter,iNumRuns);
    strctRun.m_strKofikoFile = strLogFile;
    strctRun.m_strKofikoStartupTime = strctKofiko.g_strctAppConfig.m_strTimeDate;
    strctRun.m_iRunCounter = iRunIter;
    strctRun.m_strUserDescription = strctParadigm.m_acExperimentDescription{iRunIter};
    
    strctRun.m_fRunTimeSec = round(aiKofikoEndRecTS(iRunIter)-aiKofikoStartRecTS(iRunIter));
    fprintf('Run %d : %d sec (%d min and %d sec)\n', iRunIter,strctRun.m_fRunTimeSec,floor(strctRun.m_fRunTimeSec/60),strctRun.m_fRunTimeSec-floor(strctRun.m_fRunTimeSec/60)*60 );
    strctRun.m_fRunStartTS = aiKofikoStartRecTS(iRunIter);
    strctRun.m_fRunEndTS = aiKofikoEndRecTS(iRunIter);
    
    
    strctRun.m_strImageList = fnMyInterp1String(strctParadigm.ImageList, strctRun.m_fRunStartTS);
    strctRun.m_acBlockOrder = fnReplaceSpace(fnMyInterp1String(strctParadigm.BlockRunOrder, strctRun.m_fRunStartTS));
    strctRun.m_fTR_MS = fnMyInterp1(strctParadigm.TR.TimeStamp,strctParadigm.TR.Buffer, strctRun.m_fRunStartTS);
    strctRun.m_iNumBlocks = length(strctRun.m_acBlockOrder);
    strctRun.m_aiNumTRsPerBlock = ones(1,strctRun.m_iNumBlocks ) *  fnMyInterp1(strctParadigm.NumTRsPerBlock.TimeStamp,strctParadigm.NumTRsPerBlock.Buffer, strctRun.m_fRunStartTS);
    strctRun.m_iTotalNumberOfTRs = strctRun.m_iNumTRsPerBlock * strctRun.m_iNumBlocks;
    
    aiInd = find(strctKofiko.g_strctDAQParams.m_astrctExternalTriggers(1).Trigger.TimeStamp >= strctRun.m_fRunStartTS & ...
        strctKofiko.g_strctDAQParams.m_astrctExternalTriggers(1).Trigger.TimeStamp <= strctRun.m_fRunEndTS);
    if isempty(aiInd)
        strctRun.m_iNumberOfCountedTRs = 0;
    else
        strctRun.m_iNumberOfCountedTRs = 1+sum(strctKofiko.g_strctDAQParams.m_astrctExternalTriggers(1).Trigger.Buffer(aiInd) == 1);
    end
    
    afSampleTime = strctRun.m_fRunStartTS:0.01:strctRun.m_fRunEndTS; % 10 ms intervals
    [afDistToFixationSpotPix,abInsideStimRect,abInsideGazeRect,afStimulusSizePix,afGazeBoxPix] = fnGetEyeTrackingInformationFromRun(strctKofiko, afSampleTime,iParadigmIndex);
    strctRun.m_fStimulusSizePix = afStimulusSizePix(1);
    strctRun.m_fRewardRegionPix = afGazeBoxPix(1);
    
    % Determine whether the monkey was fixating in a given TR
    strctRun.m_afAverageFixationDist = zeros(1,strctRun.m_iNumberOfCountedTRs);
    for iTRIter=1:strctRun.m_iTotalNumberOfTRs
        fTRStartTimeTS = (iTRIter-1)*strctRun.m_fTR_MS/1e3 + strctRun.m_fRunStartTS;
        fTREndTimeTS = (iTRIter)*strctRun.m_fTR_MS/1e3 + strctRun.m_fRunStartTS;
        aiIndices = find(afSampleTime >=fTRStartTimeTS &  afSampleTime < fTREndTimeTS);
        if ~isempty(aiIndices)
            strctRun.m_afAverageFixationDist(iTRIter) = median(afDistToFixationSpotPix(aiIndices));
            strctRun.m_a2fEyeData = [afSampleTime(aiIndices);afDistToFixationSpotPix(aiIndices);];
        else
            strctRun.m_afAverageFixationDist(iTRIter) = NaN;
        end
    end
    
    aiFlipInd =find(strctParadigm.FlipTime.TimeStamp >= strctRun.m_fRunStartTS & strctParadigm.FlipTime.TimeStamp <= strctRun.m_fRunEndTS);
    strctRun.m_iActualNumberOfImagesDisplayed = length(aiFlipInd)-1;
    strctRun.m_iNumberOfImagesShouldHaveDisplayed = length(strctParadigm.RecordedRun.Buffer{iRunIter+1}{1});
    
    if isfield(strctParadigm,'DrawAttentionEvents')
        aiDrawAttentionEventsInd = find(strctParadigm.DrawAttentionEvents.TimeStamp >= strctRun.m_fRunStartTS & strctParadigm.DrawAttentionEvents.TimeStamp <= strctRun.m_fRunEndTS);
        if isempty(aiDrawAttentionEventsInd )
            strctRun.m_afDrawAttentionEventsRelativeSec = [];
        else
            strctRun.m_afDrawAttentionEventsRelativeSec = strctParadigm.DrawAttentionEvents.TimeStamp(aiDrawAttentionEventsInd)-strctRun.m_fRunStartTS;
            fprintf('- %d Draw Attention Events detected\n',length(aiDrawAttentionEventsInd));
        end
    else
        strctRun.m_afDrawAttentionEventsRelativeSec = [];
    end
    
    
    if strctRun.m_iNumberOfImagesShouldHaveDisplayed == strctRun.m_iActualNumberOfImagesDisplayed
        %  fprintf('All %d images were displayed correctly \n',strctRun.m_iNumberOfImagesShouldHaveDisplayed);
    else
        fprintf('Only %d images, out of %d were displayed\n', strctRun.m_iActualNumberOfImagesDisplayed,strctRun.m_iNumberOfImagesShouldHaveDisplayed );
    end
    
    if strctRun.m_iNumberOfCountedTRs == strctRun.m_iTotalNumberOfTRs
        % fprintf('All %d TRs were detected correctly by Kofiko\n',strctRun.m_iTotalNumberOfTRs)
    else
        if strctRun.m_iNumberOfCountedTRs > 0
            strctRun.m_iNumberOfCountedTRs =  strctRun.m_iNumberOfCountedTRs - 1;
        end
        fprintf('Only %d out of %d TRs were detected correctly by Kofiko\n',strctRun.m_iNumberOfCountedTRs+1,strctRun.m_iTotalNumberOfTRs)
    end
    if iGlobalRunCounter == 1
        astrctRuns = strctRun;
    else
        astrctRuns(iGlobalRunCounter) = strctRun;
    end
    iGlobalRunCounter = iGlobalRunCounter + 1;
    
end

function acNoSpace = fnReplaceSpace(acWithSpace)
for k=1:length(acWithSpace)
    acNoSpace{k} = acWithSpace{k};
    acNoSpace{k}(acNoSpace{k} == ' ') = '_';
end
return;

    