function  acUnitsStat = fnCollectPassiveFixationUnitStatsAuxMultList(strctKofiko, strctPlexon, strctSession,iExperimentIndex, strctConfig,iParadigmIndex)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

acUnitsStat = [];
iNumAvailableUnits = length(strctPlexon.m_astrctUnits);
if isempty(iNumAvailableUnits)
    % No neural data ? exit
    return;
end;

strctKofiko = fnConvertOldKofikoFormatToNewVersion(strctKofiko, strctPlexon, strctSession,iParadigmIndex,strctConfig);

    
% First, find which lists were loaded during the entire Kofiko recording file
acUniqueLists = setdiff(unique(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ImageList.Buffer),{''});
iNumUniqueLists = length(acUniqueLists);
afTrialsStartTime = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials.TimeStamp;
afListOnsetTimes = [strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ImageList.TimeStamp,Inf];

% Iterate over all Plexon units
for iUnitIter=1:iNumAvailableUnits
    % Iterate over all unique lists
    fnWorkerLog('Unit %d out of %d...',iUnitIter,iNumAvailableUnits);
    for iListIter=1:iNumUniqueLists
        strListName = acUniqueLists{iListIter};
        
        bActiveAnalysis = fnSearchForSpecialAnalysis(strctConfig,strListName);
        if bActiveAnalysis || ~strctConfig.m_strctParams.m_bSkipInactiveDesigns
            
            % Find all relevant trials: ones that belond to this list AND were
            % recorded during this experiment.
            aiListIndicesInArray = find(ismember(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ImageList.Buffer,strListName));
            afListOnsetTime = afListOnsetTimes(aiListIndicesInArray);
            afListOffsetTime = afListOnsetTimes(aiListIndicesInArray+1);
            
            aiRelevantTrialsInd = [];
            for k=1:length(afListOnsetTime)
                aiTrialInd = find(  afTrialsStartTime >= strctSession.m_fKofikoStartTS & afTrialsStartTime <= strctSession.m_fKofikoEndTS & ...
                    afTrialsStartTime >= afListOnsetTime(k) & afTrialsStartTime <= afListOffsetTime(k));
                aiRelevantTrialsInd = [aiRelevantTrialsInd,aiTrialInd];
            end
            
            if ~isempty(aiRelevantTrialsInd)
                strctUnit = fnCollectNeuralStatisticsForSpecificPassiveFixationList(...
                    strctKofiko, strctPlexon, strctSession, strctConfig, strListName, aiRelevantTrialsInd, iExperimentIndex, iUnitIter,iParadigmIndex);
                acUnitsStat = [acUnitsStat,{strctUnit}];
            end
        else
            fnWorkerLog('Analysis pipline: skipping analysis of design %s because it is not active',strListName);
        end
    end % End of List iter
end % End of Plexon Iter

return;


function strctUnit = fnCollectNeuralStatisticsForSpecificPassiveFixationList(...
    strctKofiko, strctPlexon, strctSession, strctConfig, strListName, aiTrialIndices, iExperimentIndex, iSelectedUnit,iParadigmIndex)


strctUnit = [];

% if strcmpi(strListName,'\\kofiko-23g\StimulusSet\PlaceLocalizerPhysiology\imlist.txt')
%    strCatFile='W:\AnalysisScripts\Paradigm_Specific\PassiveFixation\PlaceLocalizer\imlist_place_localizer_physiology_Cat.mat';
%    strctTmp = load(strCatFile);
%     a2bStimulusCategory = strctTmp.a2bStimulusCategory;
%     acCatNames = strctTmp.acCatNames;
%     strImageListDescrip = 'PlaceLocalizer';
% elseif strcmpi(strListName,'\\kofiko-23g\StimulusSet\PlaceLocalizerPhysiology2\imlist.txt')
%    strCatFile='W:\AnalysisScripts\Paradigm_Specific\PassiveFixation\PlaceLocalizer\imlist_place_localizer_physiology_2_Cat.mat';
%    strctTmp = load(strCatFile);
%     a2bStimulusCategory = strctTmp.a2bStimulusCategory;
%     acCatNames = strctTmp.acCatNames;
%     strImageListDescrip = 'PlaceLocalizer2';
%     
%     
% else
    [a2bStimulusCategory,acCatNames,strImageListDescrip] = fnLoadCategoryFile(strListName);
%end
if isempty(a2bStimulusCategory)
    % No category file is avaialble. Dont know how to do this analysis.
    return;
end;

fnWorkerLog('Passive fixation experiment. List: %s',strImageListDescrip);
[strSpecialAnalysisFunc, strDisplayFunction,strctSpecialAnalysis] = fnFindSpecialAnalysis(strctConfig,  strListName);
% Assume FlipTime is the sync method.

SyncTime = strctKofiko.g_strctDAQParams.StimulusServerSync;

aiStimulusIndex = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials.Buffer(1,aiTrialIndices);

afOnset_StimServer_TS = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials.Buffer(2,aiTrialIndices);
afOffset_StimServer_TS = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials.Buffer(3,aiTrialIndices);
  
afModifiedStimulusON_TS_Plexon = fnStimulusServerTimeToPlexonTime(SyncTime,strctSession, afOnset_StimServer_TS);
afModifiedStimulusOFF_TS_Plexon = fnStimulusServerTimeToPlexonTime(SyncTime,strctSession, afOffset_StimServer_TS);
  
% Crop to ones that have a positive plexon timestamp
abInsideSessionInterval =  (afModifiedStimulusON_TS_Plexon >= strctSession.m_fPlexonStartTS & afModifiedStimulusON_TS_Plexon <= strctSession.m_fPlexonEndTS);
afModifiedStimulusON_TS_Plexon = afModifiedStimulusON_TS_Plexon(abInsideSessionInterval);
afModifiedStimulusOFF_TS_Plexon = afModifiedStimulusOFF_TS_Plexon(abInsideSessionInterval);
aiStimulusIndex = aiStimulusIndex(abInsideSessionInterval);
  
  
  
% Find valid trials, in which monkey fixated at the fixation point
strctValidTrials = fnFindValidTrials(strctKofiko, strctPlexon, strctSession,iParadigmIndex,...
    strctConfig.m_strctParams.m_fFixationPercThreshold,...
    aiStimulusIndex,afModifiedStimulusON_TS_Plexon,afModifiedStimulusOFF_TS_Plexon,strctSpecialAnalysis);

abValidTrials = strctValidTrials.m_abValidTrials;


[strctStimulusParams,afValidStimuliOnEventTimeStamps] = ...
    fnGetStimulusParametersForValidTrialsNewStyle(strctKofiko, strctSession,iParadigmIndex,abValidTrials,afModifiedStimulusON_TS_Plexon);

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

   
strctUnit.m_strRecordedTimeDate = strctKofiko.g_strctAppConfig.m_strTimeDate;
   
strctUnit.m_iRecordedSession = iExperimentIndex;
strctUnit.m_iChannel = strctPlexon.m_astrctUnits(iSelectedUnit).m_iChannel;
strctUnit.m_iUnitID = strctPlexon.m_astrctUnits(iSelectedUnit).m_iUnit;
strctUnit.m_fDurationMin = (strctSession.m_fKofikoEndTS-strctSession.m_fKofikoStartTS)/60;
strctUnit.m_strParadigm = 'Passive Fixation';
strctUnit.m_strImageListUsed = strListName;
strctUnit.m_strSubject = strctKofiko.g_strctAppConfig.m_strctSubject.m_strName;
strctUnit.m_strParadigmDesc = strImageListDescrip;
strctUnit.m_strImageListDescrip = strImageListDescrip;
    
strctUnit.m_afSpikeTimes = strctPlexon.m_astrctUnits(iSelectedUnit).m_afTimestamps(...
    strctPlexon.m_astrctUnits(iSelectedUnit).m_afTimestamps >= strctSession.m_fPlexonStartTS & ...
    strctPlexon.m_astrctUnits(iSelectedUnit).m_afTimestamps <= strctSession.m_fPlexonEndTS );

if length(strctUnit.m_afSpikeTimes) < strctConfig.m_strctParams.m_iDiscardUnitMinimumSpikes
    fnWorkerLog('Skipping. Not enough spikes');
    strctUnit = [];
    return;
end;



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

[a2bRaster,Tmp,a2fAvgSpikeForm] = fnRaster(strctPlexon.m_astrctUnits(iSelectedUnit), ...
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
    strctUnit.m_afStdStimulusResponseMinusBaseline = NaN*ones(1,iNumStimuli);
    strctUnit.m_afStdErrStimulusResponseMinusBaseline = NaN*ones(1,iNumStimuli);
    for iStimulusIter=1:iNumStimuli
        aiIndex = find(strctUnit.m_aiStimulusIndexValid == iStimulusIter);
        if ~isempty(aiIndex)
            [strctUnit.m_afAvgStimulusResponseMinusBaseline(iStimulusIter),strctUnit.m_afStdStimulusResponseMinusBaseline(iStimulusIter),...
                strctUnit.m_afStdErrStimulusResponseMinusBaseline(iStimulusIter)] = fnMyMean(strctUnit.m_afStimulusResponseMinusBaseline(aiIndex));
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
        if ~isempty(afSamplesCat1)
            [h,p] = ttest(afSamplesCat1);
            strctUnit.m_a2fPValueCat(iCat1,end) = p;
            strctUnit.m_a2fPValueCat(end,iCat1) = p;
        else
            strctUnit.m_a2fPValueCat(iCat1,end) = NaN;
            strctUnit.m_a2fPValueCat(end,iCat1) = NaN;
        end
    end
    
    
    
    
else
    [strctUnit.m_a2fPValueCat] = ...
        fnStatisticalTestBy(strctUnit.m_a2bRaster_Valid, aiStimulusIndexValid, a2bStimulusCategory,...
        iStartAvg,iEndAvg,iStartBaselineAvg,iEndBaselineAvg);
end

strctUnit.m_afRecordingRange = fnGeDepthRecordingRange(strctKofiko,afValidStimuliOnEventTimeStamps,...
    strctPlexon.m_astrctUnits(iSelectedUnit).m_iChannel);

if strctConfig.m_strctParams.m_bIncludeLFP_PerGroup || strctConfig.m_strctParams.m_bIncludeLFP_PerTrial
    % Sample LFPs
    iNumTrials = length(abValidTrials);
    a2fSampleTimes = zeros(iNumTrials, length(aiPeriStimulusRangeMS));
    for iTrialIter = 1:iNumTrials
        a2fSampleTimes(iTrialIter,:) = afModifiedStimulusON_TS_Plexon(iTrialIter)+ aiPeriStimulusRangeMS/1e3;
    end;
    
    
    iSelectedFrame = find(strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iSelectedUnit).m_iChannel).m_afTimeStamp0 < strctSession.m_fPlexonStartTS,1,'last');
    if isempty(iSelectedFrame)
        iSelectedFrame= 1;
    end;
    fSamplingFreq = strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iSelectedUnit).m_iChannel).m_fFreq;
    afPlexonTime = single(strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iSelectedUnit).m_iChannel).m_afTimeStamp0(iSelectedFrame):...
        1/fSamplingFreq:strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iSelectedUnit).m_iChannel).m_afTimeStamp0(iSelectedFrame)+...
        (strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iSelectedUnit).m_iChannel).m_aiNumSamplesInFragment(iSelectedFrame)-1)*1/fSamplingFreq);
    
    a2fLFPs = single(reshape(interp1(afPlexonTime, strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iSelectedUnit).m_iChannel).m_afData(...
        strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iSelectedUnit).m_iChannel).m_aiStart(iSelectedFrame):...
        strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iSelectedUnit).m_iChannel).m_aiEnd(iSelectedFrame)),...
        a2fSampleTimes(:)),size(a2fSampleTimes)));
    
    if strctConfig.m_strctParams.m_bIncludeLFP_PerTrial
        strctUnit.m_a2fLFP = a2fLFPs;
    end
    strctUnit.m_a2fAvgLFPCategory = fnAverageBy(a2fLFPs(abValidTrials,:), aiStimulusIndexValid, a2bStimulusCategory,0);
else
    strctUnit.m_a2fLFP = [];
    strctUnit.m_a2fAvgLFPCategory = [];
end

strctUnit.m_iUnitID = strctPlexon.m_astrctUnits(iSelectedUnit).m_iUnit;

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










function bActiveAnalysis = fnSearchForSpecialAnalysis(strctConfig,strListName)
iNumSpecific = length(strctConfig.m_acSpecificAnalysis);
bActiveAnalysis = false;
for k=1:iNumSpecific
    if isfield(strctConfig.m_acSpecificAnalysis{k},'m_bActive') && strctConfig.m_acSpecificAnalysis{k}.m_bActive
        acFieldNames = fieldnames(strctConfig.m_acSpecificAnalysis{k});
        for j=1:length(acFieldNames)
            if strncmpi(acFieldNames{j},'m_strDesignName',length('m_strDesignName'))
                strMatch = getfield(strctConfig.m_acSpecificAnalysis{k},acFieldNames{j});
                if strcmpi(strMatch,strListName)
                    bActiveAnalysis = true;
                    return;
                end;
            end;
        end;
    end;
end;

return;

function strctKofiko = fnConvertOldKofikoFormatToNewVersion(strctKofiko, strctPlexon, strctSession,iParadigmIndex,strctConfig)
if ~isfield(strctKofiko.g_strctAppConfig,'m_strctVersion')
    % Super old files...
    % Don't know if this will work
    strctKofiko = fnConvertPriorTo1010(strctKofiko, strctPlexon, strctSession,iParadigmIndex,strctConfig);
    
elseif ~isfield(strctKofiko.g_astrctAllParadigms{iParadigmIndex},'ImageList')
    % Prior to S1010, Should work...
    strctKofiko = fnConvertPriorTo1010(strctKofiko, strctPlexon, strctSession,iParadigmIndex,strctConfig);
end


return;

function strctKofiko = fnConvertPriorTo1010(strctKofiko, strctPlexon, strctSession,iParadigmIndex,strctConfig)
% Move Image list to the correct place and other things to the right spot
strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ImageList = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.ImageList;
strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusON_MS = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.StimulusON_MS;
strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusOFF_MS = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.StimulusOFF_MS;
strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusSizePix = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.StimulusSizePix;
strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusPos = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.StimulusPos;
strctKofiko.g_astrctAllParadigms{iParadigmIndex}.FixationSpotPix = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.FixationSpotPix;


if isfield(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams,'RotationAngle')
    strctKofiko.g_astrctAllParadigms{iParadigmIndex}.RotationAngle = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.RotationAngle;
else
    strctKofiko.g_astrctAllParadigms{iParadigmIndex}.RotationAngle.TimeStamp = 0;
    strctKofiko.g_astrctAllParadigms{iParadigmIndex}.RotationAngle.Buffer = 0;
end

% Next problem. We assume to have a sync signal between Kofiko & Stimulus
% server. We did not have that before...


% First, we extract it and align to it to how we did it before (i.e., align
% to plexon)
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
            fnWorkerLog('WARNING! Cannot use flip time information. This is an old session without the needed information. ');
            fnWorkerLog('Using photodiode instead and moving timestamps one frame backwards');
            
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
% Now change it back to Kofiko time zone
afModifiedStimulusON_TS_Kofiko = fnPlexonTimeToKofikoTime(strctSession,afModifiedStimulusON_TS_Plexon);
afModifiedStimulusOFF_TS_Kofiko = fnPlexonTimeToKofikoTime(strctSession,afModifiedStimulusOFF_TS_Plexon);

iNumTrials = length(afModifiedStimulusON_TS_Kofiko);
Trials.TimeStamp= zeros(1,iNumTrials);
Trials.Buffer = zeros(5,iNumTrials);
for k=1:iNumTrials
    Trials.TimeStamp(k)  = afModifiedStimulusON_TS_Kofiko(k);
    aiTrialStoreInfo = [aiStimulusIndex(k),...
        afModifiedStimulusON_TS_Kofiko(k),...
        afModifiedStimulusOFF_TS_Kofiko(k),...
        NaN,... %g_strctParadigm.m_strctCurrentTrial.m_fSentMessageTimer,...
        NaN]'; %g_strctParadigm.m_strctCurrentTrial.m_fImageFlipON_TS_Kofiko]';
    Trials.Buffer(:,k) =  aiTrialStoreInfo;
end

strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials=   Trials;
% Fake Time stamp for stimulus server...
SyncTime.Buffer = zeros(2,3);    
SyncTime.Buffer(1,:) = [strctSession.m_fKofikoStartTS,strctSession.m_fKofikoStartTS,1e-6];
SyncTime.Buffer(2,:) = [strctSession.m_fKofikoEndTS,strctSession.m_fKofikoEndTS,1e-6];
SyncTime.TimeStamp = [strctSession.m_fKofikoStartTS,strctSession.m_fKofikoEndTS];
strctKofiko.g_strctDAQParams.StimulusServerSync = SyncTime;

return;
