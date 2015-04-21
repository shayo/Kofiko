function  acUnitsStat = fnCollectPassiveFixationUnitStatsAux(strctKofiko, strctPlexon, strctSession,iExperimentIndex, strctConfig,iParadigmIndex)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

[a2bStimulusCategory,acCatNames,strImageListUsed,strImageListDescrip] = fnLoadCategoryFile(strctSession,strctKofiko, iParadigmIndex);
fnWorkerLog('Passive fixation experiment. List: %s',strImageListDescrip);
[strSpecialAnalysisFunc, strDisplayFunction,strctSpecialAnalysis] = fnFindSpecialAnalysis(strctConfig,  strImageListUsed);
if ~isfield(strctConfig.m_strctParams,'m_strSyncMethod')
    strctConfig.m_strctParams.m_strSyncMethod = 'FlipTime';
end

switch lower(strctConfig.m_strctParams.m_strSyncMethod)
    case 'fliptime'
        bFailed = false;
        if ~isfield(strctKofiko.g_astrctAllParadigms{iParadigmIndex},'SyncTime')
            bFailed = true;
        else
            [aiStimulusIndex,afModifiedStimulusON_TS_Plexon,afModifiedStimulusOFF_TS_Plexon,bFailed] = ...
                fnGetAccurateStimulusTSusingFlipTime(strctKofiko, strctSession,iParadigmIndex);
            if bFailed
                fnWorkerLog('Detected the one session with the bug in flip time code...');
            end
        end
        
        if bFailed
            fnWorkerLog('WARNING! Cannot use flip time information. This is an old session without the needed information. \n');
            fnWorkerLog('Using photodiode instead and moving timestamps one frame backwards\n');
            
            [aiStimulusIndex,afModifiedStimulusON_TS_Plexon,afModifiedStimulusOFF_TS_Plexon] = ...
                fnGetAccurateStimulusTSusingPhotodiode(strctKofiko, strctPlexon, strctSession,iParadigmIndex);
            fShiftSec = strctKofiko.g_strctStimulusServer.m_fRefreshRateMS/1e3;
            afModifiedStimulusON_TS_Plexon = afModifiedStimulusON_TS_Plexon-fShiftSec;
            afModifiedStimulusOFF_TS_Plexon = afModifiedStimulusOFF_TS_Plexon-fShiftSec;
        end
    case 'photodiode'
        % Find accurate stimulus onset using photodiode data
        [aiStimulusIndex,afModifiedStimulusON_TS_Plexon,afModifiedStimulusOFF_TS_Plexon] = ...
            fnGetAccurateStimulusTSusingPhotodiode(strctKofiko, strctPlexon, strctSession,iParadigmIndex);
    otherwise
        fnWorkerLog('I am not familiar with a %s synchronization method',strctConfig.m_strctParams.m_strSyncMethod);
        assert(false);
end

if isempty(aiStimulusIndex)
    acUnitsStat = [];
    return;
end;

% Find valid trials, in which monkey fixated at the fixation point
strctValidTrials = fnFindValidTrials(strctKofiko, strctPlexon, strctSession,iParadigmIndex,...
    strctConfig.m_strctParams.m_fFixationPercThreshold,...
    aiStimulusIndex,afModifiedStimulusON_TS_Plexon,afModifiedStimulusOFF_TS_Plexon,strctSpecialAnalysis);

abValidTrials = strctValidTrials.m_abValidTrials;

if isfield(strctKofiko.g_astrctAllParadigms{iParadigmIndex},'m_strctStimulusParams')
    [strctStimulusParams,afValidStimuliOnEventTimeStamps] = ...
        fnGetStimulusParametersForValidTrialsOldStyle(strctKofiko, strctSession,iParadigmIndex,abValidTrials);
else
    [strctStimulusParams,afValidStimuliOnEventTimeStamps] = ...
        fnGetStimulusParametersForValidTrialsNewStyle(strctKofiko, strctSession,iParadigmIndex,abValidTrials,afModifiedStimulusON_TS_Plexon);
end

% Find which image list was used and get the categories
aiStimulusIndexValid = aiStimulusIndex(abValidTrials);

%%

iNumStimuli = size(a2bStimulusCategory,1);


% Construct Peristimulus intervals
aiPeriStimulusRangeMS = strctConfig.m_strctParams.m_iBeforeMS:strctConfig.m_strctParams.m_iAfterMS;
iStartAvg = find(aiPeriStimulusRangeMS>=strctConfig.m_strctParams.m_iStartAvgMS,1,'first');
iEndAvg = find(aiPeriStimulusRangeMS>=strctConfig.m_strctParams.m_iEndAvgMS,1,'first');
iStartBaselineAvg = find(aiPeriStimulusRangeMS>=strctConfig.m_strctParams.m_iStartBaselineAvgMS,1,'first');
iEndBaselineAvg = find(aiPeriStimulusRangeMS>=strctConfig.m_strctParams.m_iEndBaselineAvgMS,1,'first');

iNumUnits = length(strctPlexon.m_astrctUnits);
abValidUnits = zeros(1,iNumUnits) > 0;

if ~isfield(strctPlexon,'m_astrctUnits') 
    acUnitsStat = [];
    return;
end;

acUnitsStat = cell(1,iNumUnits);

for iUnitIter=1:iNumUnits
   fnWorkerLog('Unit %d out of %d...',iUnitIter,iNumUnits);
   clear strctUnit
   if isfield(strctKofiko.g_strctAppConfig,'m_strTimeDate')
        strctUnit.m_strRecordedTimeDate = strctKofiko.g_strctAppConfig.m_strTimeDate;
   else
        strctUnit.m_strRecordedTimeDate = 'Unknown';
   end;
   
    strctUnit.m_iRecordedSession = iExperimentIndex;
    strctUnit.m_iChannel = strctPlexon.m_astrctUnits(iUnitIter).m_iChannel;
    strctUnit.m_iUnitID = strctPlexon.m_astrctUnits(iUnitIter).m_iUnit;
    strctUnit.m_fDurationMin = (strctSession.m_fKofikoEndTS-strctSession.m_fKofikoStartTS)/60;
    strctUnit.m_strParadigm = 'Passive Fixation';
    strctUnit.m_strImageListUsed = strImageListUsed;
    strctUnit.m_strSubject = strctKofiko.g_strctAppConfig.m_strctSubject.m_strName;
    strctUnit.m_strParadigmDesc = strImageListDescrip;
    strctUnit.m_strImageListDescrip = strImageListDescrip;
    
    strctUnit.m_afSpikeTimes = strctPlexon.m_astrctUnits(iUnitIter).m_afTimestamps(...
        strctPlexon.m_astrctUnits(iUnitIter).m_afTimestamps >= strctSession.m_fPlexonStartTS & ...
        strctPlexon.m_astrctUnits(iUnitIter).m_afTimestamps <= strctSession.m_fPlexonEndTS );

    if length(strctUnit.m_afSpikeTimes) < strctConfig.m_strctParams.m_iDiscardUnitMinimumSpikes 
        acUnitsStat{iUnitIter} = strctUnit;
        
       fnWorkerLog('Skipping. Not enough spikes');
        continue;
    end;

    abValidUnits(iUnitIter) = true;

    if strctConfig.m_strctParams.m_bFourierAnalysis
        strctUnit.m_afFreqCent = afFreqCent;
        strctUnit.m_afFreqPower = afFreqPower;
    end;
    
    strctUnit.m_strctStatParams = strctConfig.m_strctParams;
    strctUnit.m_aiPeriStimulusRangeMS = aiPeriStimulusRangeMS;    
    strctUnit.m_strctStimulusParams = strctStimulusParams;
    strctUnit.m_strctValidTrials = strctValidTrials;
    strctUnit.m_afISICenter = 0:50;
    strctUnit.m_afISIDistribution = hist(diff(strctUnit.m_afSpikeTimes)*1e3,strctUnit.m_afISICenter);

    [a2bRaster,Tmp,a2fAvgSpikeForm] = fnRaster(strctPlexon.m_astrctUnits(iUnitIter), ...
        afModifiedStimulusON_TS_Plexon, strctConfig.m_strctParams.m_iBeforeMS,...
        strctConfig.m_strctParams.m_iAfterMS);

    strctUnit.m_a2bRaster_Valid = a2bRaster(abValidTrials,:) > 0;
    strctUnit.m_afStimulusONTime = afModifiedStimulusON_TS_Plexon(abValidTrials);
    strctUnit.m_afStimulusONTimeAll = afModifiedStimulusON_TS_Plexon;
    
    strctUnit.m_aiStimulusIndexValid = aiStimulusIndexValid;
    strctUnit.m_aiStimulusIndex = aiStimulusIndex;
    
    if ~isfield( strctConfig.m_strctParams,'m_bGaussianSmoothing')
         strctConfig.m_strctParams.m_bGaussianSmoothing = true;
    end;

    strctUnit.m_a2fAvgFirintRate_Stimulus  = 1e3 * fnAverageBy(strctUnit.m_a2bRaster_Valid, ...
        aiStimulusIndexValid, diag(1:iNumStimuli)>0,strctConfig.m_strctParams.m_iTimeSmoothingMS,...
        strctConfig.m_strctParams.m_bGaussianSmoothing);
    strctUnit.m_a2fAvgFirintRate_Category = 1e3 *  fnAverageBy(strctUnit.m_a2bRaster_Valid, ...
        aiStimulusIndexValid, a2bStimulusCategory,strctConfig.m_strctParams.m_iTimeSmoothingMS,...
        strctConfig.m_strctParams.m_bGaussianSmoothing);
    strctUnit.m_afAvgFirintRate_Stimulus = mean(strctUnit.m_a2fAvgFirintRate_Stimulus(:, iStartAvg:iEndAvg),2);
    strctUnit.m_afBaseline = mean(strctUnit.m_a2fAvgFirintRate_Stimulus (:, iStartBaselineAvg:iEndBaselineAvg),2);
    strctUnit.m_fAvgBaseline = mean(strctUnit.m_afBaseline);
    strctUnit.m_iNumStimuli = size(a2bStimulusCategory,1);
    strctUnit.m_iNumCategories = size(a2bStimulusCategory,2);
    
    strctUnit.m_acCatNames = acCatNames;
    strctUnit.m_a2bStimulusCategory = a2bStimulusCategory;
    
    
    if isfield(strctConfig.m_strctParams,'m_bSubtractBaseline') && strctConfig.m_strctParams.m_bSubtractBaseline
        afSmoothingKernelMS = fspecial('gaussian',[1 7*strctConfig.m_strctParams.m_iTimeSmoothingMS],strctConfig.m_strctParams.m_iTimeSmoothingMS);
        a2fSmoothRaster = conv2(double(strctUnit.m_a2bRaster_Valid),afSmoothingKernelMS ,'same');
        afResponse = mean(a2fSmoothRaster(:,iStartAvg:iEndAvg),2);
        strctUnit.m_afBaselineRes = mean(a2fSmoothRaster(:,iStartBaselineAvg:iEndBaselineAvg),2);
        strctUnit.m_afStimulusResponseMinusBaseline = afResponse-strctUnit.m_afBaselineRes;
        % Now average according to stimulus !
        strctUnit.m_afAvgStimulusResponseMinusBaseline = NaN*ones(1,iNumStimuli);
        for iStimulusIter=1:iNumStimuli
            aiIndex = find(strctUnit.m_aiStimulusIndexValid == iStimulusIter);
            if ~isempty(aiIndex)
                strctUnit.m_afAvgStimulusResponseMinusBaseline(iStimulusIter) = mean(strctUnit.m_afStimulusResponseMinusBaseline(aiIndex));
            end;
        end
        strctUnit.m_afAvgFiringRateCategory = ones(1,strctUnit.m_iNumCategories)*NaN;
        for iCatIter=1:strctUnit.m_iNumCategories
            abSamplesCat = ismember(strctUnit.m_aiStimulusIndexValid, find(a2bStimulusCategory(:, iCatIter)));
            if sum(abSamplesCat) > 0
                strctUnit.m_afAvgFiringRateCategory(iCatIter) = fnMyMean(strctUnit.m_afStimulusResponseMinusBaseline(abSamplesCat));
            end
        end
        
        
    end
    if isfield(strctConfig.m_strctParams,'m_bSubtractBaseline') && strctConfig.m_strctParams.m_bSubtractBaseline
       strctUnit.m_a2fPValueCat = NaN*ones(strctUnit.m_iNumCategories +1,strctUnit.m_iNumCategories +1); % Last one is baseline
       
       
        for iCat1=1:strctUnit.m_iNumCategories
            
            abSamplesCat1 = ismember(strctUnit.m_aiStimulusIndexValid, find(a2bStimulusCategory(:, iCat1)));
            afSamplesCat1 = strctUnit.m_afStimulusResponseMinusBaseline(abSamplesCat1);
            if sum(abSamplesCat1) > 0
                
                for iCat2=iCat1+1:strctUnit.m_iNumCategories
                    abSamplesCat2 = ismember(strctUnit.m_aiStimulusIndexValid, find(a2bStimulusCategory(:, iCat2)));
                    if sum(abSamplesCat2) > 0
                        afSamplesCat2 = strctUnit.m_afStimulusResponseMinusBaseline(abSamplesCat2);
                        p = ranksum(afSamplesCat1,afSamplesCat2);
                        strctUnit.m_a2fPValueCat(iCat1,iCat2) = p;
                        strctUnit.m_a2fPValueCat(iCat2,iCat1) = p;
                    end
                end
            end
            [h,p] = ttest(afSamplesCat1);
            strctUnit.m_a2fPValueCat(iCat1,end) = p;
            strctUnit.m_a2fPValueCat(end,iCat1) = p;
        end
        
        
        
   else    
   [strctUnit.m_a2fPValueCat] = ...
        fnStatisticalTestBy(strctUnit.m_a2bRaster_Valid, aiStimulusIndexValid, a2bStimulusCategory,...
        iStartAvg,iEndAvg,iStartBaselineAvg,iEndBaselineAvg);
   end
   
    strctUnit.m_afRecordingRange = fnGeDepthRecordingRange(strctKofiko,afValidStimuliOnEventTimeStamps,...
             strctPlexon.m_astrctUnits(iUnitIter).m_iChannel);

         if strctConfig.m_strctParams.m_bIncludeLFP_PerGroup || strctConfig.m_strctParams.m_bIncludeLFP_PerTrial
             % Sample LFPs
             iNumTrials = length(abValidTrials);
             a2fSampleTimes = zeros(iNumTrials, length(aiPeriStimulusRangeMS));
             for iTrialIter = 1:iNumTrials
                 a2fSampleTimes(iTrialIter,:) = afModifiedStimulusON_TS_Plexon(iTrialIter)+ aiPeriStimulusRangeMS/1e3;
             end;
             
             
             iSelectedFrame = find(strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iUnitIter).m_iChannel).m_afTimeStamp0 < strctSession.m_fPlexonStartTS,1,'last');
             fSamplingFreq = strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iUnitIter).m_iChannel).m_fFreq;
             afPlexonTime = single(strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iUnitIter).m_iChannel).m_afTimeStamp0(iSelectedFrame):...
                 1/fSamplingFreq:strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iUnitIter).m_iChannel).m_afTimeStamp0(iSelectedFrame)+...
                 (strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iUnitIter).m_iChannel).m_aiNumSamplesInFragment(iSelectedFrame)-1)*1/fSamplingFreq);
             
             a2fLFPs = single(reshape(interp1(afPlexonTime, strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iUnitIter).m_iChannel).m_afData(...
                 strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iUnitIter).m_iChannel).m_aiStart(iSelectedFrame):...
                 strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iUnitIter).m_iChannel).m_aiEnd(iSelectedFrame)),...
                 a2fSampleTimes(:)),size(a2fSampleTimes)));
             
             if strctConfig.m_strctParams.m_bIncludeLFP_PerTrial
                 strctUnit.m_a2fLFP = a2fLFPs;
             end
             strctUnit.m_a2fAvgLFPCategory = fnAverageBy(a2fLFPs(abValidTrials,:), aiStimulusIndexValid, a2bStimulusCategory,0);
         else
             strctUnit.m_a2fLFP = [];
             strctUnit.m_a2fAvgLFPCategory = [];
         end
         
    strctUnit.m_iUnitID = strctPlexon.m_astrctUnits(iUnitIter).m_iUnit;
    
    %      Wave form
    warning off
    strctUnit.m_afAvgWaveForm = mean(a2fAvgSpikeForm(abValidTrials,:), 1);
    strctUnit.m_afStdWaveForm = std(a2fAvgSpikeForm(abValidTrials,:), [], 1);
    strctUnit.m_iNumValidTrials = sum(abValidTrials);
    warning on
    
    if ~isempty(strSpecialAnalysisFunc)
        strctUnit = feval(strSpecialAnalysisFunc, strctUnit, strctKofiko, strctPlexon, strctSession,iExperimentIndex, strctConfig,iParadigmIndex);
    end
    strctUnit.m_strDisplayFunction = strDisplayFunction;
    
    % Comments
    if isfield(strctKofiko.g_strctAppConfig,'Comments')
        aiIndicesOfCommentsDuringTheExperiment = find(strctKofiko.g_strctAppConfig.Comments.TimeStamp >= strctSession.m_fKofikoStartTS & ...
             strctKofiko.g_strctAppConfig.Comments.TimeStamp <= strctSession.m_fKofikoEndTS);
         strctUnit.m_acComments = strctKofiko.g_strctAppConfig.Comments.Buffer(aiIndicesOfCommentsDuringTheExperiment);
    else
        strctUnit.m_acComments = [];
    end
    
    
	acUnitsStat{iUnitIter} = strctUnit;
    fnWorkerLog('Done!');

end;
acUnitsStat = acUnitsStat(abValidUnits);
return;

function afRecordingRange = fnGeDepthRecordingRange(strctKofiko,afTimeStamps,iPlexonChannel)

% Add recording depth (if this electrode was hooked up to an advancer
% read out device)
afRecordingRange = [NaN, NaN]; % Initialize to unknown

if isfield(strctKofiko.g_strctAppConfig,'m_strctElectrophysiology')
    if isfield(strctKofiko.g_strctAppConfig.m_strctElectrophysiology,'m_astrctElectrodes')
        % Old style  - only one channel was available....
        afRecordingRange = fnMyInterp1(strctKofiko.g_strctAppConfig.m_strctElectrophysiology.m_astrctElectrodes.Depth.TimeStamp, ...
            strctKofiko.g_strctAppConfig.m_strctElectrophysiology.m_astrctElectrodes.Depth.Buffer, afTimeStamps);
    else
        % New version - multiple chambers and multiple electrodes....
        
        % Go over all the electrodes that were hooked up to advacner read out
        % and check whether one of them was connected to this channel....
        iNumChambers = length(strctKofiko.g_strctAppConfig.m_strctElectrophysiology);
        for iChamberIter=1:iNumChambers
            aiHotElectrodes = find(strctKofiko.g_strctAppConfig.m_strctElectrophysiology(iChamberIter).m_astrctGrids(1).m_abSelected);
            for iElectrodeIter=1:length(aiHotElectrodes)
                if ~isfield(strctKofiko.g_strctAppConfig.m_strctElectrophysiology(iChamberIter).m_astrctGrids(1),'m_acChannels')
                    % Another old version that only had one electrode....
                    % Assume plexon channel 1
                    afDepth = fnMyInterp1(strctKofiko.g_strctAppConfig.m_strctElectrophysiology(iChamberIter).m_astrctGrids(1).m_astrctDepth(iElectrodeIter).TimeStamp, ...
                        strctKofiko.g_strctAppConfig.m_strctElectrophysiology(iChamberIter).m_astrctGrids(1).m_astrctDepth(iElectrodeIter).Buffer, afTimeStamps);
                    afRecordingRange = [min(afDepth), max(afDepth)];
                else
                    aiChannelsForThisElectrode = strctKofiko.g_strctAppConfig.m_strctElectrophysiology(iChamberIter).m_astrctGrids(1).m_acChannels{aiHotElectrodes(iElectrodeIter)};
                    if sum(aiChannelsForThisElectrode == iPlexonChannel) > 0
                        % Found the corresponding chamber and grid hole that
                        % iPlexonChannel was hooked up to
                        %
                        if length(strctKofiko.g_strctAppConfig.m_strctElectrophysiology(iChamberIter).m_astrctGrids(1).m_astrctDepth(iElectrodeIter).Buffer) > 1
                            % Someone potentially entered a depth or it was read
                            % out by an external advacner read out device.
                            afDepth = fnMyInterp1(strctKofiko.g_strctAppConfig.m_strctElectrophysiology(iChamberIter).m_astrctGrids(1).m_astrctDepth(iElectrodeIter).TimeStamp, ...
                                strctKofiko.g_strctAppConfig.m_strctElectrophysiology(iChamberIter).m_astrctGrids(1).m_astrctDepth(iElectrodeIter).Buffer, afTimeStamps);
                            afRecordingRange = [min(afDepth), max(afDepth)];
                        end
                    end
                end
            end
        end
    end
end
return;



function [strctStimulusParams, afTimeStamps] = fnGetStimulusParametersForValidTrialsOldStyle(strctKofiko, strctSession,iParadigmIndex, abValidTrials)
S = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.CurrStimulusIndex;
iStart = find(S.TimeStamp >= strctSession.m_fKofikoStartTS,1,'first');
iEnd = find(S.TimeStamp <= strctSession.m_fKofikoEndTS,1,'last');

% These two variables hold the list of stimuli displayed and their Kofiko timestamp
aiStimuli = squeeze(S.Buffer(iStart:iEnd));
afStimuli_TS_Kofiko = S.TimeStamp(iStart:iEnd);

aiStimuliOnEvent = find(aiStimuli > 0);
afTimeStamps = afStimuli_TS_Kofiko(aiStimuliOnEvent(abValidTrials));
afTimeStampsALL = afStimuli_TS_Kofiko(aiStimuliOnEvent);
strctStimulusParams.m_afStimulusON_MS = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.StimulusON_MS.TimeStamp, ...
           strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.StimulusON_MS.Buffer, afTimeStamps);

strctStimulusParams.m_afStimulusOFF_MS = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.StimulusOFF_MS.TimeStamp, ...
           strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.StimulusOFF_MS.Buffer, afTimeStamps);

       
strctStimulusParams.m_afStimulusON_ALL_MS = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.StimulusON_MS.TimeStamp, ...
           strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.StimulusON_MS.Buffer, afTimeStampsALL);

strctStimulusParams.m_afStimulusOFF_ALL_MS = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.StimulusOFF_MS.TimeStamp, ...
           strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.StimulusOFF_MS.Buffer, afTimeStampsALL);


       
strctStimulusParams.m_afStimulusSizePix = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.StimulusSizePix.TimeStamp, ...
           strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.StimulusSizePix.Buffer, afTimeStamps);

if isfield(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams,'RotationAngle')
    strctStimulusParams.m_afRotationAngle = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.RotationAngle.TimeStamp, ...
               strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.RotationAngle.Buffer, afTimeStamps);
else
    strctStimulusParams.m_afRotationAngle = zeros(1,length(afTimeStamps));
end


return;



function [strctStimulusParams, afTimeStamps] = fnGetStimulusParametersForValidTrialsNewStyle(strctKofiko, strctSession,iParadigmIndex, abValidTrials,afModifiedStimulusON_TS_Plexon)
afTimeStampsALL = fnPlexonTimeToKofikoTime(strctSession,afModifiedStimulusON_TS_Plexon);
afTimeStamps = afTimeStampsALL(abValidTrials);

strctStimulusParams.m_afStimulusON_MS = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusON_MS.TimeStamp, ...
           strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusON_MS.Buffer, afTimeStamps);

strctStimulusParams.m_afStimulusOFF_MS = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusOFF_MS.TimeStamp, ...
           strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusOFF_MS.Buffer, afTimeStamps);

       
strctStimulusParams.m_afStimulusON_ALL_MS = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusON_MS.TimeStamp, ...
           strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusON_MS.Buffer, afTimeStampsALL);

strctStimulusParams.m_afStimulusOFF_ALL_MS = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusOFF_MS.TimeStamp, ...
           strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusOFF_MS.Buffer, afTimeStampsALL);


       
strctStimulusParams.m_afStimulusSizePix = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusSizePix.TimeStamp, ...
           strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusSizePix.Buffer, afTimeStamps);

strctStimulusParams.m_afRotationAngle = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.RotationAngle.TimeStamp, ...
           strctKofiko.g_astrctAllParadigms{iParadigmIndex}.RotationAngle.Buffer, afTimeStamps);

if all(size(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusPos.Buffer) == [2,1])
    strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusPos.Buffer = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusPos.Buffer';
end
       
afStimulusPosX = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusPos.TimeStamp, ...
           strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusPos.Buffer(:,1), afTimeStamps);
       
afStimulusPosY = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusPos.TimeStamp, ...
           strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusPos.Buffer(:,2), afTimeStamps);

if all(size(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.FixationSpotPix.Buffer) == [2,1])
    strctKofiko.g_astrctAllParadigms{iParadigmIndex}.FixationSpotPix.Buffer = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.FixationSpotPix.Buffer';
end
       
afFixationPosX = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.FixationSpotPix.TimeStamp, ...
           strctKofiko.g_astrctAllParadigms{iParadigmIndex}.FixationSpotPix.Buffer(:,1), afTimeStamps);
       
afFixationPosY = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.FixationSpotPix.TimeStamp, ...
           strctKofiko.g_astrctAllParadigms{iParadigmIndex}.FixationSpotPix.Buffer(:,2), afTimeStamps);
       
strctStimulusParams.m_afPosXRelativeToFixationSpot= afStimulusPosX-afFixationPosX;
strctStimulusParams.m_afPosYRelativeToFixationSpot= afStimulusPosY-afFixationPosY;
return;




function [a2bStimulusCategory,acCatNames,strImageListUsed,strImageListDescrip] = fnLoadCategoryFile(strctSession,strctKofiko, iParadigmIndex)
if isfield(strctKofiko.g_astrctAllParadigms{iParadigmIndex},'m_strctStimulusParams')
    strctImageList = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.ImageList;
else
    strctImageList = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ImageList;
end

afImageTS = strctImageList.TimeStamp;
iImageListIndex = find(afImageTS <= strctSession.m_fKofikoStartTS(1),1,'last');

% This part is backward comptability with a bug that was in kofiko cycle.
iLoadedAfter = find(afImageTS >= strctSession.m_fKofikoStartTS(1) & afImageTS <=strctSession.m_fKofikoEndTS(1));
if ~isempty(iLoadedAfter)
    fnWorkerLog('CRITICAL WARNING!!!!!');
    fnWorkerLog('**********************************************');
    fnWorkerLog('Two image lists were detected for this experiment?!?!? This is a bug that was fixed in Kofiko S1005');
    fnWorkerLog('Taking the one that was loaded after experiment started...');
    iImageListIndex = iLoadedAfter;
end


strImageListUsed = strctImageList.Buffer{iImageListIndex};

%%
if isunix
    strTmp = strImageListUsed;
    strTmp(strTmp=='\') = '/';
    [strPath,strFile] = fileparts(strTmp);
else
    [strPath,strFile] = fileparts(strImageListUsed);
end



while (1)
    if isdeployed
        strCatFile = fullfile('.', 'Worker_mcr','AnalysisScripts', 'PassiveFixation', 'ImageListCat', [strFile, '_Cat.mat']);
    
    else
        strCatFile = fullfile('.', 'AnalysisScripts', 'PassiveFixation', 'ImageListCat', [strFile, '_Cat.mat']);
    end
    
    if exist(strCatFile,'file')
        strctTmp = load(strCatFile);
        a2bStimulusCategory = strctTmp.a2bStimulusCategory;
        acCatNames = strctTmp.acCatNames;
        if isfield(strctTmp,'strImageListDescrip')
            strImageListDescrip = strctTmp.strImageListDescrip;
        else
            strImageListDescrip = strFile;
        end
        break;
    end
    if isdeployed
        iNumStimuli = length(unique(aiStimulusIndex));
        a2bStimulusCategory = eye(iNumStimuli);
        acCatNames = cell(1,iNumStimuli);
        for k=1:iNumStimuli
            acCatNames{k} = sprintf('Stimulus %d',k);
        end
        strImageListDescrip = strFile;
        break;
    else
        strAnswer = questdlg(sprintf('Category file is missing (%s)',strCatFile),'Error','Try Again','Treat each stimulus as a single category','Skip','Try Again');
        switch strAnswer
            case 'Treat each stimulus as a single category'
                iNumStimuli = length(unique(aiStimulusIndex));
                a2bStimulusCategory = eye(iNumStimuli);
                acCatNames = cell(1,iNumStimuli);
                for k=1:iNumStimuli
                    acCatNames{k} = sprintf('Stimulus %d',k);
                end
                strImageListDescrip = strFile;
            case 'Skip'
                assert(false);
        end
    end
end
return;




function [strSpecialAnalysisFunc, strDisplayFunction, strctSpecialAnalysis] = fnFindSpecialAnalysis(strctConfig,  strImageListUsed)
strctSpecialAnalysis = [];
strSpecialAnalysisFunc = '';
strDisplayFunction = strctConfig.m_strctGeneral.m_strDisplayFunction;
if ~isfield(strctConfig,'m_acSpecificAnalysis')
    iNumSpecificAnalysisAvail = 0;
else
    iNumSpecificAnalysisAvail = length(strctConfig.m_acSpecificAnalysis);    
end
for iSpecialIter=1:iNumSpecificAnalysisAvail
    acFieldNames = fieldnames(strctConfig.m_acSpecificAnalysis{iSpecialIter});
    iNumSubFields = length(acFieldNames);
    for k=1:iNumSubFields
        if strncmpi(acFieldNames{k},'m_strDesignName',length('m_strDesignName'))
            strDesignName = getfield(strctConfig.m_acSpecificAnalysis{iSpecialIter},acFieldNames{k});
            if strcmpi(strImageListUsed, strDesignName)
                strctSpecialAnalysis = strctConfig.m_acSpecificAnalysis{iSpecialIter};
                strSpecialAnalysisFunc = strctConfig.m_acSpecificAnalysis{iSpecialIter}.m_strAnalysisScript;
                strDisplayFunction = strctConfig.m_acSpecificAnalysis{iSpecialIter}.m_strDisplayScript;
                return;
            end
        end
    end
end
return; 
