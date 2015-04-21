function acUnitsStat = fnCollectForceChoiceStats_Saccades(strctKofiko, strctSync, strctConfig, strctInterval, strOutputFolder)
% Computes various statistics about the recorded units in a given recorded session
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

fStartTS_PTB_Kofiko = fnTimeZoneChange(strctInterval.m_fStartTS_Plexon,strctSync,'Plexon','Kofiko');
fEndTS_PTB_Kofiko = fnTimeZoneChange(strctInterval.m_fEndTS_Plexon,strctSync,'Plexon','Kofiko');

iParadigmIndex = fnFindParadigmIndex(strctKofiko,'Touch Force Choice');
assert(iParadigmIndex~=-1);

acUnitsStat = [];
acDesignNamesLoaded = fnCellStructToArray(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ExperimentDesigns.Buffer(2:end),'m_strDesignFileName');
afDesignsTS_Kofiko= strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ExperimentDesigns.TimeStamp(2:end);
acUniqueLists = unique(acDesignNamesLoaded);
iNumUniqueLists = length(acUniqueLists);
afTrialsStartTime = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.acTrials.TimeStamp;
afListOnsetTimes = [afDesignsTS_Kofiko,Inf];

iMinimumTrialsToAnalyze = 10;

% Iterate over all unique lists
for iListIter=1:iNumUniqueLists
    strListName = acUniqueLists{iListIter};
    
    fnWorkerLog('Collecting statistics for design %s',strListName)

    % Find all relevant trials: ones that belond to this list AND were
    % recorded during this experiment.
    aiListIndicesInArray = find(ismember(acDesignNamesLoaded,strListName));
    afListOnsetTime = afListOnsetTimes(aiListIndicesInArray);
    afListOffsetTime = afListOnsetTimes(aiListIndicesInArray+1);
    
   strctDesign = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ExperimentDesigns.Buffer{1+aiListIndicesInArray(1)};
   
    aiRelevantTrialsInd = [];
    for k=1:length(afListOnsetTime)
        aiTrialInd = find(  afTrialsStartTime >= fStartTS_PTB_Kofiko & afTrialsStartTime <= fEndTS_PTB_Kofiko & ...
            afTrialsStartTime >= afListOnsetTime(k) & afTrialsStartTime <= afListOffsetTime(k));
        aiRelevantTrialsInd = [aiRelevantTrialsInd,aiTrialInd];
    end
    if ~isempty(aiRelevantTrialsInd) && aiRelevantTrialsInd(1) == 1  && isempty(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.acTrials.Buffer{1})
        aiRelevantTrialsInd = aiRelevantTrialsInd(2:end);
    end

    
    if ~isempty(aiRelevantTrialsInd) && length(aiRelevantTrialsInd) > iMinimumTrialsToAnalyze
        fnCollectForceChoiceSpecificDesignAux(strctKofiko, strctSync, strctConfig, strctInterval, strctDesign, aiRelevantTrialsInd, iParadigmIndex,strOutputFolder);
    end
end 


function fnCollectForceChoiceSpecificDesignAux(...
            strctKofiko, strctSync, strctConfig, strctInterval, strctDesign, aiTrialInd, iParadigmIndex,strOutputFolder)

strDesignName = strctDesign.m_strDesignFileName;
% astrctTrialTypes = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ExperimentDesigns.Buffer{iDesignIndexInBuffer}{1};
% astrctChoices = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ExperimentDesigns.Buffer{iDesignIndexInBuffer}{2};
% strctSpecialDesignAnalysis = fnMatchSpecialDesignAnalysisAndDisplay(strctConfig,strDesignName);


acTrials = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.acTrials.Buffer(aiTrialInd);
afTrialEndTS = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.acTrials.TimeStamp(aiTrialInd);

iNumTrials = length(acTrials);
afCueOnsetTS_Kofiko = zeros(1,iNumTrials);
afTrialLengthSec = zeros(1,iNumTrials);
for k=1:iNumTrials
    % Append trials with the missing information.....
    if ~isfield(acTrials{k}.m_strctTrialOutcome,'m_afCueOnset_TS_Kofiko')
        % Old session. Extrapolate when this happened....
        acTrials{k}.m_strctTrialOutcome.m_afCueOnset_TS_Kofiko(1) = fnGetApproximatedCueOnsetTimeForOldTrialTypes(acTrials{k});
    end
    acTrials{k}.m_strctTrialOutcome.m_fTrialEnd_TS_Kofiko = afTrialEndTS(k);
    afTrialLengthSec(k) = afTrialEndTS(k)-afCueOnsetTS_Kofiko(k);
end;

% if strctConfig.m_strctParams.m_bAppendEyeTracesToSpecialAnalysisFunctions
%     acTrials = fnAppendEyeTrace(acTrials, strctKofiko,strctInterval,strctSync);
% end
fBeforeMS = 1000;  % Prior to cue
fAfterMS =1000; % After trial ended
fMaxTrialLengthMS = 2000; % Actual PSTH will be between -fBeforeMS to fMaxTrialLengthMS+fAfterMS
iMinimumNumSpikes = 100;

[strctUnit, strctChannelInfo] = fnReadDumpSpikeFile(strctInterval.m_strSpikeFile, 'SingleUnit',[strctInterval.m_iChannel,strctInterval.m_iUniqueID],'Interval',[strctInterval.m_fStartTS_Plexon,strctInterval.m_fEndTS_Plexon]);
iNumSpikes = length(strctUnit.m_afTimestamps);
if iNumSpikes < iMinimumNumSpikes
    return;
end;

[acTrials, aiPeriMS] = fnAppendSpikesAndLFP(acTrials,strctSync, strctUnit, strctInterval.m_strLFPFile,fBeforeMS,fAfterMS, fMaxTrialLengthMS);


fnStandardNeuralFiringRateAnalysis(acTrials, aiTrialInd, aiPeriMS,strctInterval,strctSync,strctKofiko, ...
   strDesignName,strctDesign,strctConfig,strctChannelInfo,strOutputFolder);



return;

function [acTrials,aiPeriStimMS] = fnAppendSpikesAndLFP(acTrials, strctSync, strctUnit, strLFPfile,fBeforeMS,fAfterMS, fMaxTrialLengthMS)
iNumTrials = length(acTrials);

afCueOnsetTS_Kofiko = zeros(1,iNumTrials);
afTrialEndTS_Kofiko = zeros(1,iNumTrials);
afTrialLengthSec = zeros(1,iNumTrials);
for k=1:iNumTrials
    afCueOnsetTS_Kofiko(k) = acTrials{k}.m_strctTrialOutcome.m_afCueOnset_TS_Kofiko(1);
    afTrialEndTS_Kofiko(k) = acTrials{k}.m_strctTrialOutcome.m_fTrialEnd_TS_Kofiko(1);
    afTrialLengthSec(k) = afTrialEndTS_Kofiko(k)-afCueOnsetTS_Kofiko(k);
end

if isempty(fMaxTrialLengthMS)
    fMaxTrialLengthMS = ceil(1e3*max(afTrialLengthSec));
end
% Make things easier. Just take the longest trial and build rasters....
aiPeriStimMS = -fBeforeMS:fMaxTrialLengthMS+fAfterMS;
a2fSampleTimes = zeros(iNumTrials, length(aiPeriStimMS));
for iTrialIter=1:iNumTrials
    % Collect all information starting from first cue onset.
    fSyncTime = fnTimeZoneChange(afCueOnsetTS_Kofiko(iTrialIter), strctSync,'Kofiko','Plexon');
    a2fSampleTimes(iTrialIter,:) = fSyncTime + aiPeriStimMS/1e3;
    afSpikesDuringTrial = ...
        strctUnit.m_afTimestamps(...
        strctUnit.m_afTimestamps >= (fSyncTime-fBeforeMS/1e3) & ...
        strctUnit.m_afTimestamps <= (fSyncTime+fMaxTrialLengthMS+fAfterMS/1e3) );
    
    acTrials{iTrialIter}.m_strctNeuralStat.m_afSpikes = afSpikesDuringTrial;
end

strctAnalog = fnReadDumpAnalogFile(strLFPfile,'Resample',a2fSampleTimes);
for iTrialIter=1:iNumTrials
      acTrials{iTrialIter}.m_strctNeuralStat.m_afLFP = strctAnalog.m_afData(iTrialIter,:);
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
% 


function fnStandardNeuralFiringRateAnalysis(acTrials, aiTrialInd, aiPeriMS,strctInterval,strctSync,strctKofiko, ...
   strDesignName,strctDesign,strctConfig,strctChannelInfo,strOutputFolder)
% Standard analysis for force choice....
%  Per [Trial Type X Trial Outcome]
%    1 ) Raster
%    2) PSTH
%    3) LFP


aiTrialTypes = fnCellStructToArray(acTrials,'m_iTrialType');
[aiUniqueTrialTypes, Dummy, aiTrialTypeToUniqueTrialType] = unique(aiTrialTypes);

iNumUniqueTrialTypes = length(aiUniqueTrialTypes);
aiNumTrialRep = histc(aiTrialTypeToUniqueTrialType,1:iNumUniqueTrialTypes);
fnWorkerLog('Found %d trials, which belong to %d unique trial types', length(aiTrialTypes), iNumUniqueTrialTypes);

acAllOutcomes = cell(1, length(acTrials));
for j=1:length(acTrials)
    if isempty(acTrials{j}.m_strctNewTrialOutcome) || isempty(acTrials{j}.m_strctNewTrialOutcome.m_strOutcome)
        acAllOutcomes{j}='Missing Data';
    else
        acAllOutcomes{j}=acTrials{j}.m_strctNewTrialOutcome.m_strOutcome;
    end
end
[acUniqueOutcomes,Dummy, aiOutcomeToUnique] = unique(acAllOutcomes);
iNumUniqueOutcomes = length(acUniqueOutcomes);

[~,strShortDesignName] = fileparts(strDesignName);

iSep = find(strctInterval.m_strSession == '_',1,'last');
strTimeDate = strctInterval.m_strSession(1:iSep-1);
strSubject = strctInterval.m_strSession(iSep+1:end);
strctUnit = [];
strctUnit = fnAddAttribute(strctUnit,'Type','Force Choice Neural Stat');
strctUnit = fnAddAttribute(strctUnit,'Paradigm','Touch Force Choice');
strctUnit = fnAddAttribute(strctUnit,'Design', strShortDesignName);
strctUnit = fnAddAttribute(strctUnit,'Channel', num2str(strctInterval.m_iChannel),strctInterval.m_iChannel);
strctUnit = fnAddAttribute(strctUnit,'Unit', num2str(strctInterval.m_iUniqueID),strctInterval.m_iUniqueID);
strctUnit = fnAddAttribute(strctUnit,'TimeDate',strTimeDate );
strctUnit = fnAddAttribute(strctUnit,'Subject', strSubject);
strctUnit = fnAddAttribute(strctUnit,'Depth', mean(strctInterval.m_afIntervalDepthMM));

strctUnit.m_strctChannelInfo = strctChannelInfo;
strctUnit.m_strDesignName = strDesignName;

strctUnit.m_acUniqueOutcomes = acUniqueOutcomes;
 strctUnit.m_a2cTrialStats = cell(iNumUniqueTrialTypes, iNumUniqueOutcomes);
 fnWorkerLog('%d unique trials were found',iNumUniqueTrialTypes);
for iUniqueTrialIter=1:iNumUniqueTrialTypes
    iTrialType = aiUniqueTrialTypes(iUniqueTrialIter);
    strctTrialType = strctDesign.m_acTrialTypes{iTrialType};
    strTrialName = strctTrialType.TrialParams.Name;
    strctUnit.m_acTrialNames{iUniqueTrialIter} = strTrialName;
    for iUniqueOutcomeIter=1:iNumUniqueOutcomes
        aiRelevantTrialsLocal = find(aiTrialTypeToUniqueTrialType == iUniqueTrialIter & aiOutcomeToUnique == iUniqueOutcomeIter);
        strctUnit.m_a2iNumTrials(iUniqueTrialIter, iUniqueOutcomeIter) = length(aiRelevantTrialsLocal);
        if ~isempty(aiRelevantTrialsLocal)
            aiRelevantTrialsGlobal = aiTrialInd(aiRelevantTrialsLocal);
            strctUnit.m_a2cTrialStats{iUniqueTrialIter, iUniqueOutcomeIter}.m_aiTrialInd = aiRelevantTrialsGlobal;
         % Now that we know which trials are the "same", we can create the
        % various statistics (like raster, PSTH, etc...)
        
        % 1. Create a raster aligned to cue onset.
        % 2. Create a raster aligned to trial end time (only for
        % correct/Incorrect ?)
        % 3. Create PSTH per condition.
            strctUnit.m_a2cTrialStats{iUniqueTrialIter, iUniqueOutcomeIter}.m_strctRasterCue = fnCreateRasterMatrix(acTrials(aiRelevantTrialsLocal), strctSync, aiPeriMS,true);
            strctUnit.m_a2cTrialStats{iUniqueTrialIter, iUniqueOutcomeIter}.m_strctRasterSaccade = fnCreateRasterMatrix(acTrials(aiRelevantTrialsLocal), strctSync, aiPeriMS,false);
        else
            strctUnit.m_a2cTrialStats{iUniqueTrialIter, iUniqueOutcomeIter} = [];
        end
    end
end

%% Remove this to display function!
% Find Saccade To Right Trials.

%%
strOutputFileName = [strOutputFolder, strSubject,'-',strTimeDate,'_TouchForceChoiceNeuralStat_Channel_',num2str(strctInterval.m_iChannel)','_Interval_',num2str(strctInterval.m_iUniqueID),'_',strShortDesignName,'.mat'];
strctUnit.m_strDisplayFunction = 'fnDefaultForceChoiceNeuralDisplay';
save(strOutputFileName,'strctUnit');


return;

function strctRaster = fnCreateRasterMatrix(acTrials, strctSync, aiPeriMS, bAlignToTrialStart)

iNumTrials = length(acTrials);
if iNumTrials == 0
    strctRaster = [];
    return;
end


strctRaster.m_aiRasterTimeMS = aiPeriMS;
strctRaster.m_a2bRaster = zeros(iNumTrials,length(strctRaster.m_aiRasterTimeMS),'uint8')>0;
strctRaster.m_aiTrialEndIndInPeri = zeros(1,iNumTrials);
strctRaster.m_aiChoicesOnsetInPeri = ones(1,iNumTrials)*NaN;
strctRaster.m_a2fLFP = zeros(iNumTrials, length(aiPeriMS));
for iTrialIter=1:iNumTrials
    % Normal case, Cue(1) becomes the zero point.
    
    fTrialOnsetPLX = fnTimeZoneChange(acTrials{iTrialIter}.m_strctTrialOutcome.m_afCueOnset_TS_Kofiko(1),strctSync,'Kofiko','Plexon');
    fTrialOffsetPLX = fnTimeZoneChange(acTrials{iTrialIter}.m_strctTrialOutcome.m_fTrialEnd_TS_Kofiko,strctSync,'Kofiko','Plexon');
    
    if isfield(acTrials{iTrialIter}.m_strctTrialOutcome,'m_fChoicesOnsetTS_Kofiko')
        fChoicesOnsetPLX = fnTimeZoneChange(acTrials{iTrialIter}.m_strctTrialOutcome.m_fChoicesOnsetTS_Kofiko,strctSync,'Kofiko','Plexon');
    else
        fChoicesOnsetPLX = NaN;
    end
    
    if bAlignToTrialStart
        fSyncTime_PLX = fTrialOnsetPLX;
    else
        % Align to trial end (usually, this is when eye position enters the
        % choice response region
        fSyncTime_PLX = fTrialOffsetPLX;
    end
    
    strctRaster.m_afCueOnset(iTrialIter) = fTrialOnsetPLX-fSyncTime_PLX;
    strctRaster.m_afTrialEnd(iTrialIter) = fTrialOffsetPLX-fSyncTime_PLX;
    strctRaster.m_afChoicesOnset(iTrialIter) = fChoicesOnsetPLX-fSyncTime_PLX;
    strctRaster.m_a2fLFP(iTrialIter,:) = acTrials{iTrialIter}.m_strctNeuralStat.m_afLFP;
    afSpikesDuringTrial = acTrials{iTrialIter}.m_strctNeuralStat.m_afSpikes;
    if ~isempty(afSpikesDuringTrial)
        afSpikesRelativeToSyncVar = afSpikesDuringTrial - fSyncTime_PLX;
        aiSpikeBins = 1+abs(aiPeriMS(1))+round(afSpikesRelativeToSyncVar * 1e3);
        strctRaster.m_a2bRaster(iTrialIter,aiSpikeBins(aiSpikeBins >=1  & (aiSpikeBins < size(strctRaster.m_a2bRaster,2)))) = true;
    end 
end

fBlurMS = 5;
afSmoothingKernelMS = fspecial('gaussian',[1 7*fBlurMS],fBlurMS);
strctRaster.m_a2fSmoothRaster = single(conv2(double(strctRaster.m_a2bRaster), afSmoothingKernelMS,'same') * 1e3);

% 
% if isfield(acTrials{1},'m_afLFP')
%     % Compute the average LFP for this trial
%     iNumLFPSamples = length(acTrials{1}.m_afLFP);
%     a2fAvgLFP = zeros(iNumTrials,iNumLFPSamples);
%     for iTrialIter=1:iNumTrials
%         a2fAvgLFP(iTrialIter,:) = acTrials{iTrialIter}.m_afLFP;
%     end   
%     strctRaster.m_afAvgLFP = nanmean(a2fAvgLFP,1);
%     strctRaster.m_afStdLFP = nanstd(a2fAvgLFP,1);
% end
return;


% 
% 
% function strctUnit = fnAppendWithSpecialRasters(strctUnit,acTrials,iUnitIter,strctSpecialDesignAnalysis,astrctTrialTypes,astrctChoices)
% if ~isfield(strctSpecialDesignAnalysis,'m_acRaster')
%     return;
% end;
% iNumRasters = length(strctSpecialDesignAnalysis.m_acRaster);
% iNumTrials = length(acTrials);
% for iRasterIter=1:iNumRasters
%     % Select the trials that match the creteria given in the XML
%     
%     
%     
%     abTrialsUsed = zeros(1,iNumTrials) > 0;
%     bCrashed = false;
%     for iTrialIter=1:iNumTrials
%          
%         if ~isempty(strctSpecialDesignAnalysis.m_acRaster{iRasterIter}.m_strResponse)
%             bResultHit = strcmpi(strctSpecialDesignAnalysis.m_acRaster{iRasterIter}.m_strResponse,acTrials{iTrialIter}.m_strResult);
%         else
%             bResultHit = true;
%         end
%         
%         if isfield(strctSpecialDesignAnalysis.m_acRaster{iRasterIter},'m_strNoiseSelection') && ~isempty(strctSpecialDesignAnalysis.m_acRaster{iRasterIter}.m_strNoiseSelection)
%             strString = strctSpecialDesignAnalysis.m_acRaster{iRasterIter}.m_strNoiseSelection;
%             strString(strString == 'L') = '<';
%             strString(strString == 'G') = '>';
%             strString(strString == 'E') = '=';
%             
%             strCondition = ['bNoiseHit = acTrials{iTrialIter}.m_fNoiseLevel ',strString,';'];
%             
%             try
%                 eval(strCondition);
%             catch
%                 bCrashed = true;
%                 bNoiseHit = false;
%             end
%             
%             
%         else
%             bNoiseHit = true;
%         end
%             
%         bTrialIndexHit = sum(acTrials{iTrialIter}.m_iTrialDisplayed == strctSpecialDesignAnalysis.m_acRaster{iRasterIter}.m_aiTrialSelectionIndices) > 0;
%         strTrialName = astrctTrialTypes(acTrials{iTrialIter}.m_iTrialDisplayed).m_strImageFileName;
%         aiStartInd = regexpi(strTrialName, strctSpecialDesignAnalysis.m_acRaster{iRasterIter}.m_strTrialSelectionNames);
%         bRegularExpressionHit = ~isempty(aiStartInd);
%         abTrialsUsed(iTrialIter) = (bTrialIndexHit || bRegularExpressionHit) && bResultHit && bNoiseHit;
%     end
%     if bCrashed
%         fnWorkerLog('CRITICAL ERROR: crashed while trying to evaluate the noise level argument for a special raster');
%     end
%     
%     strctUnit.m_acRasters{iRasterIter} = fnGenerateRaster(acTrials(abTrialsUsed), ...
%         iUnitIter, strctSpecialDesignAnalysis.m_acRaster{iRasterIter}.m_fSmoothingMS,...
%         strctSpecialDesignAnalysis.m_acRaster{iRasterIter}.m_strName);
%     
% end
% 
% return;
