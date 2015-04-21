function acUnitsStat = fnAnalyzeForceChoiceParadigmNewFormat(strctKofiko, strctSync, strctConfig, strctInterval)

if isfield(strctConfig,'m_acSpecificAnalysis') && ~iscell(strctConfig.m_acSpecificAnalysis)
    strctConfig.m_acSpecificAnalysis = {strctConfig.m_acSpecificAnalysis};
end

fStartTS_PTB_Kofiko = fnTimeZoneChange(strctInterval.m_fStartTS_Plexon,strctSync,'Plexon','Kofiko');
fEndTS_PTB_Kofiko = fnTimeZoneChange(strctInterval.m_fEndTS_Plexon,strctSync,'Plexon','Kofiko');


iParadigmIndex = fnFindParadigmIndex(strctKofiko, 'Force Choice');

if ~isfield(strctKofiko.g_astrctAllParadigms{iParadigmIndex},'acTrials')
    % No trials found.
    acUnitsStat = [];
    return;
end

% Find which designs were used during the interval of interest....

acUniqueLists = setdiff(unique(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.DesignFileName.Buffer),{''});
iNumUniqueLists = length(acUniqueLists);
afTrialsStartTime = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.acTrials.TimeStamp;
afListOnsetTimes = [strctKofiko.g_astrctAllParadigms{iParadigmIndex}.DesignFileName.TimeStamp,Inf];

% Iterate over all unique lists
fnWorkerLog('Force Choice : Channel %d, Unit %d...',strctInterval.m_iChannel,strctInterval.m_iUnit)
for iListIter=1:iNumUniqueLists
    strListName = acUniqueLists{iListIter};
    
    
    % Find all relevant trials: ones that belond to this list AND were
    % recorded during this experiment.
    aiListIndicesInArray = find(ismember(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.DesignFileName.Buffer,strListName));
    afListOnsetTime = afListOnsetTimes(aiListIndicesInArray);
    afListOffsetTime = afListOnsetTimes(aiListIndicesInArray+1);
    
   
    aiRelevantTrialsInd = [];
    for k=1:length(afListOnsetTime)
        aiTrialInd = find(  afTrialsStartTime >= fStartTS_PTB_Kofiko & afTrialsStartTime <= fEndTS_PTB_Kofiko & ...
            afTrialsStartTime >= afListOnsetTime(k) & afTrialsStartTime <= afListOffsetTime(k));
        aiRelevantTrialsInd = [aiRelevantTrialsInd,aiTrialInd];
    end
    if ~isempty(aiRelevantTrialsInd) && aiRelevantTrialsInd(1) == 1  && isempty(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.acTrials.Buffer{1})
        aiRelevantTrialsInd = aiRelevantTrialsInd(2:end);
    end

    
    if ~isempty(aiRelevantTrialsInd)
        
        for iTmpIter=1:length(aiListIndicesInArray)
            iDesignIndex = aiListIndicesInArray(iTmpIter); 
            if ~isempty(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ExperimentDesigns.Buffer{iDesignIndex})
                break;
            end
        end
        
        strctUnit = fnCollectForceChoiceSpecificDesignAux(...
            strctKofiko, strctSync, strctConfig, strctInterval, iDesignIndex, aiRelevantTrialsInd, iParadigmIndex);
        acUnitsStat = {strctUnit};
    end
end 


%%

function strctUnit = fnCollectForceChoiceSpecificDesignAux(...
            strctKofiko, strctSync, strctConfig, strctInterval, iDesignIndexInBuffer, aiTrialInd, iParadigmIndex)

strDesignName = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.DesignFileName.Buffer{iDesignIndexInBuffer};
astrctTrialTypes = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ExperimentDesigns.Buffer{iDesignIndexInBuffer}{1};
astrctChoices = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ExperimentDesigns.Buffer{iDesignIndexInBuffer}{2};

fnWorkerLog('Force Choice Experiment. Design : %s',strDesignName);

strctSpecialDesignAnalysis = fnMatchSpecialDesignAnalysisAndDisplay(strctConfig,strDesignName);


acTrials = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.acTrials.Buffer(aiTrialInd);
acTrials = fnAppendTrialsWithChangableParams(acTrials,strctKofiko.g_astrctAllParadigms{iParadigmIndex},strctInterval,strctSync);
if strctConfig.m_strctParams.m_bAppendEyeTracesToSpecialAnalysisFunctions
    acTrials = fnAppendEyeTrace(acTrials, strctKofiko,strctInterval,strctSync);
end
[acTrials,afAvgWaveForm] = fnAppendSpikes(acTrials, strctInterval,strctSync);

strctUnit = fnStandardNeuralFiringRateAnalysis(acTrials, strctInterval,strctSync,strctKofiko, ...
   strDesignName,astrctTrialTypes,astrctChoices,strctConfig,afAvgWaveForm);

if ~isempty(strctUnit)
    if ~isempty(strctSpecialDesignAnalysis)
        strctUnit.m_strDisplayFunction = strctSpecialDesignAnalysis.m_strctParams.m_strSpecialDisplayScript;
        strctUnit = fnAppendWithSpecialRasters(strctUnit,acTrials,iUnitIter,strctSpecialDesignAnalysis,astrctTrialTypes,astrctChoices);
        if ~isempty(strctSpecialDesignAnalysis.m_strctParams.m_strSpecialAnalysisScript)
%             strctUnit = feval(strctSpecialDesignAnalysis.m_strctParams.m_strSpecialAnalysisScript,...
%                 strctUnit, acTrials, strctPlexon,...
%                 strctKofiko, iUnitIter, strctSession,iSessionIter,strDesignName,astrctTrialTypes,astrctChoices,...
%                 strctConfig);
        end
    end
    
end


return;

function [acTrials,afAvgWaveForm] = fnAppendSpikes(acTrials, strctInterval,strctSync)
% Append only to correct or incorrect!
iNumTrials = length(acTrials);
iBeforeMS = max(fnCellStructToArray(acTrials, 'm_fHoldFixationToStartTrialMS'));
iMaxTimeoutMS = max(fnCellStructToArray(acTrials, 'm_fTimeoutMS'));
afTrialLength = fnCellStructToArray(acTrials, 'm_fMonkeySaccade_PlexonTS') - fnCellStructToArray(acTrials, 'm_fCenterImageON_PlexonTS');

iAfterMS = ceil(max(afTrialLength(afTrialLength < iMaxTimeoutMS/1e3)*1e3)) + max(fnCellStructToArray(acTrials, 'm_fShowObjectsAfterSaccadeMS'));
if isempty(iAfterMS)
    iAfterMS = 2000;
end;

strSpikesFile = sprintf('%s-spikes_ch%d.raw',[strctInterval.m_strRawFolder,filesep,strctInterval.m_strSession],strctInterval.m_iChannel);
if ~exist(strSpikesFile,'file')
    fprintf('Failed to find the corresponding spike file!\n');
    assert(false);
end;
strctUnit = fnReadDumpSpikeFile(strSpikesFile, 'SingleUnit',[strctInterval.m_iChannel,strctInterval.m_iUnit],'Interval',[strctInterval.m_fStartTS_Plexon,strctInterval.m_fEndTS_Plexon]);
afAvgWaveForm = mean(strctUnit.m_a2fWaveforms,1);

for iTrialIter=1:iNumTrials
    fSyncTime = acTrials{iTrialIter}.m_fCenterImageON_PlexonTS;
    acTrials{iTrialIter}.m_iBeforeMS = iBeforeMS;
    acTrials{iTrialIter}.m_iAfterMS = iAfterMS;
    
    afSpikesDuringTrial = ...
        strctUnit.m_afTimestamps(...
        strctUnit.m_afTimestamps >= (fSyncTime-iBeforeMS/1e3) & ...
        strctUnit.m_afTimestamps <= (fSyncTime+iAfterMS/1e3) );
    
    acTrials{iTrialIter}.m_afSpikes = afSpikesDuringTrial;
end
return;


function acTrials = fnAppendEyeTrace(acTrials, strctKofiko,strctInterval,strctSync)
iNumTrials = length(acTrials);

strEyeXfile = [strctInterval.m_strRawFolder,filesep,strctInterval.m_strSession,'-EyeX.raw'];
strEyeYfile = [strctInterval.m_strRawFolder,filesep,strctInterval.m_strSession,'-EyeY.raw'];
if ~exist(strEyeXfile,'file') || ~exist(strEyeYfile,'file') 
    fprintf('Cannot find eye tracking file (%s). Aborting!\n',strEyeXfile);
    assert(false);
end;


for iTrialIter=1:iNumTrials
    % Add this information only to correct or incorrect trials...
    % Remove the "shorthold" and "timeout" trials.
    
    if strcmpi(acTrials{iTrialIter}.m_strResult,'Correct') ||  strcmpi(acTrials{iTrialIter}.m_strResult,'Incorrect') 
 
        fFixationPeriodBeforeSec = acTrials{iTrialIter}.m_fHoldFixationToStartTrialMS/1e3;
        fAfterDecisionPeriodSec =  acTrials{iTrialIter}.m_fShowObjectsAfterSaccadeMS/1e3;
        
        fStartSamplingTS_PLX = acTrials{iTrialIter}.m_fCenterImageON_PlexonTS-fFixationPeriodBeforeSec;
        fEndSamplingTS_PLX = acTrials{iTrialIter}.m_fMonkeySaccade_PlexonTS+fAfterDecisionPeriodSec;
        
        [strctEyeX, afPlexonTime] = fnReadDumpAnalogFile(strEyeXfile,'Interval',[fStartSamplingTS_PLX,fEndSamplingTS_PLX]);
        strctEyeY = fnReadDumpAnalogFile(strEyeYfile,'Interval',[fStartSamplingTS_PLX,fEndSamplingTS_PLX]);
        
        afOffsetX = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.CenterX, 'Kofiko','Plexon',afPlexonTime, strctSync);
        afOffsetY = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.CenterY, 'Kofiko','Plexon',afPlexonTime, strctSync);
        afGainX = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.GainX, 'Kofiko','Plexon',afPlexonTime, strctSync);
        afGainY = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.GainY, 'Kofiko','Plexon',afPlexonTime, strctSync);
     
        
        % The way to convert Raw Eye signal from plexon to screen coordinates is:
        acTrials{iTrialIter}.m_afEyeXpix = (strctEyeX.m_afData+2048 - afOffsetX).*afGainX + strctKofiko.g_strctStimulusServer.m_aiScreenSize(3)/2;
        acTrials{iTrialIter}.m_afEyeYpix = (strctEyeY.m_afData+2048 - afOffsetY).*afGainY + strctKofiko.g_strctStimulusServer.m_aiScreenSize(4)/2;
        acTrials{iTrialIter}.m_afEyeTimingPlexonTS = afTrialTimePlexon;

    end
end

return


function acTrials = fnAppendTrialsWithChangableParams(acTrials,strctParadigm,strctInterval,strctSync)
iNumTrials = length(acTrials);
for iTrialIter=1:iNumTrials
    % This 1x3 holds: Flip1,Flip2,Flip3
    % Flip1: Time when center image appeared on the screen
    % Flip2: Time when center image disappeared and a fixation appeared
    %        (delay period...)
    % Flip3: Time when targets appeared on screen
    
    afPlexonTS = fnTimeZoneChange(acTrials{iTrialIter}.m_fTrialOnset_TS_StimulusServer,strctSync,'StimulusServer','Plexon');
    
    acTrials{iTrialIter}.m_fCenterImageON_PlexonTS = afPlexonTS(1);
    if length(afPlexonTS) > 1
        acTrials{iTrialIter}.m_fCenterImageOFF_PlexonTS = afPlexonTS(2);
        
        if length(afPlexonTS) > 2
            acTrials{iTrialIter}.m_fDecisionsImageON_PlexonTS = afPlexonTS(3);
        else
            acTrials{iTrialIter}.m_fDecisionsImageON_PlexonTS = afPlexonTS(2);
        end
    end
        
    acTrials{iTrialIter}.m_fMonkeySaccade_PlexonTS = fnTimeZoneChange(acTrials{iTrialIter}.m_fTrialEndTimeLocal,strctSync,'Kofiko','Plexon');
    
    acTrials{iTrialIter}.m_fHoldFixationToStartTrialMS = fnMyInterp1(strctParadigm.HoldFixationToStartTrialMS.TimeStamp, ...
        strctParadigm.HoldFixationToStartTrialMS.Buffer, acTrials{iTrialIter}.m_fTrialStartTimeLocal);
    
    acTrials{iTrialIter}.m_fDelayBeforeChoicesMS = fnMyInterp1(strctParadigm.DelayBeforeChoicesMS.TimeStamp, ...
        strctParadigm.DelayBeforeChoicesMS.Buffer, acTrials{iTrialIter}.m_fTrialStartTimeLocal);
    
    acTrials{iTrialIter}.m_fMemoryIntervalMS = fnMyInterp1(strctParadigm.MemoryIntervalMS.TimeStamp, ...
        strctParadigm.MemoryIntervalMS.Buffer, acTrials{iTrialIter}.m_fTrialStartTimeLocal);
    
    acTrials{iTrialIter}.m_fTimeoutMS = fnMyInterp1(strctParadigm.TimeoutMS.TimeStamp, ...
        strctParadigm.TimeoutMS.Buffer, acTrials{iTrialIter}.m_fTrialStartTimeLocal);
    
    acTrials{iTrialIter}.m_fShowObjectsAfterSaccadeMS = fnMyInterp1(strctParadigm.ShowObjectsAfterSaccadeMS.TimeStamp, ...
        strctParadigm.ShowObjectsAfterSaccadeMS.Buffer, acTrials{iTrialIter}.m_fTrialStartTimeLocal);
    
    acTrials{iTrialIter}.m_fImageHalfSizePix = fnMyInterp1(strctParadigm.ImageHalfSizePix.TimeStamp, ...
        strctParadigm.ImageHalfSizePix.Buffer, acTrials{iTrialIter}.m_fTrialStartTimeLocal);
    
    acTrials{iTrialIter}.m_fChoicesHalfSizePix = fnMyInterp1(strctParadigm.ChoicesHalfSizePix.TimeStamp, ...
        strctParadigm.ChoicesHalfSizePix.Buffer, acTrials{iTrialIter}.m_fTrialStartTimeLocal);
    
    acTrials{iTrialIter}.m_fChoicesHalfSizePix = fnMyInterp1(strctParadigm.ChoicesHalfSizePix.TimeStamp, ...
        strctParadigm.ChoicesHalfSizePix.Buffer, acTrials{iTrialIter}.m_fTrialStartTimeLocal);
    
    acTrials{iTrialIter}.m_fChoicesHalfSizePix = fnMyInterp1(strctParadigm.ChoicesHalfSizePix.TimeStamp, ...
        strctParadigm.ChoicesHalfSizePix.Buffer, acTrials{iTrialIter}.m_fTrialStartTimeLocal);
end

return;

function strctUnit = fnStandardNeuralFiringRateAnalysis(acTrials, strctInterval,strctSync,strctKofiko, ...
   strDesignName,astrctTrialTypes,astrctChoices,strctConfig,afAvgWaveForm)
% Compute avg firing rate for "Correct" and "Incorrect" responses.
% Generate Raster ?
fStartTS_PTB_Kofiko = fnTimeZoneChange(strctInterval.m_fStartTS_Plexon,strctSync,'Plexon','Kofiko');
fEndTS_PTB_Kofiko = fnTimeZoneChange(strctInterval.m_fEndTS_Plexon,strctSync,'Plexon','Kofiko');

strctUnit.m_strRecordedTimeDate = strctKofiko.g_strctAppConfig.m_strTimeDate;
strctUnit.m_iRecordedSession = strctInterval.m_iUniqueID;
strctUnit.m_iChannel = strctInterval.m_iChannel;
strctUnit.m_iUnitID = strctInterval.m_iUnit;
strctUnit.m_fDurationMin = (fEndTS_PTB_Kofiko- fStartTS_PTB_Kofiko)/60;
strctUnit.m_strParadigm = 'Force Choice';
strctUnit.m_strDesignName = strDesignName;
[strPath,strFile]=fileparts(strDesignName);
strctUnit.m_strParadigmDesc = strFile;
strctUnit.m_strSubject = strctKofiko.g_strctAppConfig.m_strctSubject.m_strName;
strctUnit.m_afAvgWaveForm = afAvgWaveForm;
strctUnit.m_strDisplayFunction = strctConfig.m_strctGeneral.m_strDisplayFunction;

% Align everything to image onset

iNumTrials = length(acTrials);    
%aiTrialTypes = zeros(1,iNumTrials);
abCorrect = zeros(1,iNumTrials)>0;
abIncorrect = zeros(1,iNumTrials)>0;

iNumChoices = length(astrctChoices);
a2bTargetSelection = zeros(iNumChoices,iNumTrials) > 0;

a2bImage = zeros(2,iNumTrials) > 0;

aiTrialType = zeros(1,iNumTrials);
for k=1:iNumTrials
    aiTrialType(k) = acTrials{k}.m_iTrialDisplayed;
    abCorrect(k) = strcmpi(acTrials{k}.m_strResult,'Correct') ;
    abIncorrect(k) = strcmpi(acTrials{k}.m_strResult,'Incorrect') ;
    if abCorrect(k) || abIncorrect(k)
        a2bImage(1,k) = aiTrialType(k) <= 16;
        a2bImage(2,k) = aiTrialType(k) > 16;
        iActualChoice = astrctTrialTypes(acTrials{k}.m_iTrialDisplayed).m_aiChoices(acTrials{k}.m_iMonkeySaccadeToTargetIndex);
        a2bTargetSelection(iActualChoice, k) = true;
    end
end

[strPath,strFile]=fileparts(strDesignName);
strctUnit.m_fSmoothnessKernelMS = 10;
[strctUnit.m_strctRasterCorrect] = fnGenerateRasterSingleUnit(acTrials(abCorrect),strctUnit.m_fSmoothnessKernelMS,[strFile,': Correct (All Trials)']);
[strctUnit.m_strctRasterIncorrect] = fnGenerateRasterSingleUnit(acTrials(abIncorrect),strctUnit.m_fSmoothnessKernelMS,[strFile,': Incorrect (All Trials)']);
strctUnit.m_acRasters = {strctUnit.m_strctRasterCorrect,strctUnit.m_strctRasterIncorrect};
for k=1:iNumChoices
    strctUnit.m_acRasters{k+2} = fnGenerateRasterSingleUnit(acTrials(a2bTargetSelection(k,:)),strctUnit.m_fSmoothnessKernelMS,sprintf([strFile,': Choice %d'],k));
end
for k=1:2
    strctUnit.m_acRasters{k+4} = fnGenerateRasterSingleUnit(acTrials(a2bImage(k,:)),strctUnit.m_fSmoothnessKernelMS,sprintf([strFile,': Image %d'],k));
end



% 
% for iTrialIter=1:length(aiValidTrials)
%     iTrialIndex = aiValidTrials(iTrialIter);
%     
%    fStartPlexonTS = acTrials{iTrialIndex}.m_fCenterImageON_PlexonTS-acTrials{iTrialIndex}.m_fHoldFixationToStartTrialMS/1e3;
%    fEndPlexonTS = acTrials{iTrialIndex}.m_fMonkeySaccade_PlexonTS +acTrials{iTrialIndex}.m_fShowObjectsAfterSaccadeMS/1e3;
%    
%    acTrials{iTrialIndex}.m_afSpikesDuringTrial = ...
%        strctPlexon.m_astrctUnits(iUnitIter).m_afTimestamps(...
%        strctPlexon.m_astrctUnits(iUnitIter).m_afTimestamps >= fStartPlexonTS & ...
%        strctPlexon.m_astrctUnits(iUnitIter).m_afTimestamps <= fEndPlexonTS);
%    
%    if 0
%        afEyeVelocity = [0;sqrt(diff(acTrials{iTrialIndex}.m_afEyeXpix).^2+diff(acTrials{iTrialIndex}.m_afEyeYpix).^2)];
%        afEyeVelocity = afEyeVelocity / max(afEyeVelocity);
%        
%        % Display Trial Information
%        figure(11);
%        clf;hold on;
%        h0=plot(acTrials{iTrialIndex}.m_afEyeTimingPlexonTS,2+afEyeVelocity,'k');
%        for k=1:length(acTrials{iTrialIndex}.m_afSpikesDuringTrial)
%            plot(acTrials{iTrialIndex}.m_afSpikesDuringTrial(k) * ones(1,2),[0 1],'b');
%        end
%        h1=plot(acTrials{iTrialIndex}.m_fCenterImageON_PlexonTS * ones(1,2),[0 5],'r');
%        h2=plot(acTrials{iTrialIndex}.m_fCenterImageOFF_PlexonTS * ones(1,2),[0 5],'g');
%        h3=plot(acTrials{iTrialIndex}.m_fDecisionsImageON_PlexonTS* ones(1,2),[0 5],'c');
%        h4=plot(acTrials{iTrialIndex}.m_fMonkeySaccade_PlexonTS* ones(1,2),[0 5],'m');
%        legend([h0,h1,h2,h3,h4],{'Eye Velocity','Center Image ON','Center Image OFF','Decisions ON','Saccade'});
%        
%        strCenterImage = astrctTrialTypes(acTrials{iTrialIndex}.m_iTrialDisplayed).m_strImageFileName;
%        text(acTrials{iTrialIndex}.m_fCenterImageON_PlexonTS,1.5,strCenterImage, 'BackgroundColor',[0 0 0],'color',[1 1 1]);
%        text(acTrials{iTrialIndex}.m_fMonkeySaccade_PlexonTS,1.5,acTrials{iTrialIter}.m_strResult, 'BackgroundColor',[0 0 0],'color',[1 1 1]);
%    end
%    
% end
% 
% 
return;




function strctUnit = fnAppendWithSpecialRasters(strctUnit,acTrials,iUnitIter,strctSpecialDesignAnalysis,astrctTrialTypes,astrctChoices)
if ~isfield(strctSpecialDesignAnalysis,'m_acRaster')
    return;
end;
iNumRasters = length(strctSpecialDesignAnalysis.m_acRaster);
iNumTrials = length(acTrials);
for iRasterIter=1:iNumRasters
    % Select the trials that match the creteria given in the XML
    
    
    
    abTrialsUsed = zeros(1,iNumTrials) > 0;
    bCrashed = false;
    for iTrialIter=1:iNumTrials
         
        if ~isempty(strctSpecialDesignAnalysis.m_acRaster{iRasterIter}.m_strResponse)
            bResultHit = strcmpi(strctSpecialDesignAnalysis.m_acRaster{iRasterIter}.m_strResponse,acTrials{iTrialIter}.m_strResult);
        else
            bResultHit = true;
        end
        
        if isfield(strctSpecialDesignAnalysis.m_acRaster{iRasterIter},'m_strNoiseSelection') && ~isempty(strctSpecialDesignAnalysis.m_acRaster{iRasterIter}.m_strNoiseSelection)
            strString = strctSpecialDesignAnalysis.m_acRaster{iRasterIter}.m_strNoiseSelection;
            strString(strString == 'L') = '<';
            strString(strString == 'G') = '>';
            strString(strString == 'E') = '=';
            
            strCondition = ['bNoiseHit = acTrials{iTrialIter}.m_fNoiseLevel ',strString,';'];
            
            try
                eval(strCondition);
            catch
                bCrashed = true;
                bNoiseHit = false;
            end
            
            
        else
            bNoiseHit = true;
        end
            
        bTrialIndexHit = sum(acTrials{iTrialIter}.m_iTrialDisplayed == strctSpecialDesignAnalysis.m_acRaster{iRasterIter}.m_aiTrialSelectionIndices) > 0;
        strTrialName = astrctTrialTypes(acTrials{iTrialIter}.m_iTrialDisplayed).m_strImageFileName;
        aiStartInd = regexpi(strTrialName, strctSpecialDesignAnalysis.m_acRaster{iRasterIter}.m_strTrialSelectionNames);
        bRegularExpressionHit = ~isempty(aiStartInd);
        abTrialsUsed(iTrialIter) = (bTrialIndexHit || bRegularExpressionHit) && bResultHit && bNoiseHit;
    end
    if bCrashed
        fnWorkerLog('CRITICAL ERROR: crashed while trying to evaluate the noise level argument for a special raster');
    end
    
    strctUnit.m_acRasters{iRasterIter} = fnGenerateRaster(acTrials(abTrialsUsed), ...
        iUnitIter, strctSpecialDesignAnalysis.m_acRaster{iRasterIter}.m_fSmoothingMS,...
        strctSpecialDesignAnalysis.m_acRaster{iRasterIter}.m_strName);
    
end

return;
