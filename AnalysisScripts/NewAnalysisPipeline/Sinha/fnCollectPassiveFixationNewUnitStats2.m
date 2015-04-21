function acUnitsStat = fnCollectPassiveFixationNewUnitStats(strctKofiko, strctSync, strctConfig, strctInterval,afActualFlipTime_PLX)
% Computes various statistics about the recorded units in a given recorded session
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
if ~exist('afActualFlipTime_PLX','var')
    afActualFlipTime_PLX = [];
end
iParadigmIndex = fnFindParadigmIndex(strctKofiko,'Passive Fixation New');
assert(iParadigmIndex~=-1);
acUnitsStat = [];

% First, find which lists were loaded during the entire Kofiko recording file
acUniqueLists = setdiff(unique(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ImageList.Buffer),{''});
iNumUniqueLists = length(acUniqueLists);
afTrialsStartTime_Kofiko = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials.TimeStamp;
afListOnsetTimes_Kofiko = [strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ImageList.TimeStamp,Inf];

afListOnsetTimes_Plexon = fnTimeZoneChange(afListOnsetTimes_Kofiko,strctSync,'Kofiko','Plexon');
afTrialsStartTime_Plexon = fnTimeZoneChange(afTrialsStartTime_Kofiko,strctSync,'Kofiko','Plexon');
% Iterate over all unique lists
fnWorkerLog('Channel %d, Unit %d...',strctInterval.m_iChannel,strctInterval.m_iUniqueID);
   
% fStartTS_PTB_Kofiko = fnTimeZoneChange(strctInterval.m_fStartTS_Plexon,strctSync,'Plexon','Kofiko');
% fEndTS_PTB_Kofiko = fnTimeZoneChange(strctInterval.m_fEndTS_Plexon,strctSync,'Plexon','Kofiko');

for iListIter=1:iNumUniqueLists
    strListName = acUniqueLists{iListIter};
    
    
    % Find all relevant trials: ones that belond to this list AND were
    % recorded during this experiment.
    aiListIndicesInArray = find(ismember(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ImageList.Buffer,strListName));
    afListOnsetTime_PLX = afListOnsetTimes_Plexon(aiListIndicesInArray);
    afListOffsetTime_PLX = afListOnsetTimes_Plexon(aiListIndicesInArray+1);
    
    aiRelevantTrialsInd = [];
    for k=1:length(afListOnsetTime_PLX)
        aiTrialInd = find(  afTrialsStartTime_Plexon >= strctInterval.m_fStartTS_Plexon & afTrialsStartTime_Plexon <= strctInterval.m_fEndTS_Plexon & ...
            afTrialsStartTime_Plexon >= afListOnsetTime_PLX(k) & afTrialsStartTime_Plexon <= afListOffsetTime_PLX(k));
        aiRelevantTrialsInd = [aiRelevantTrialsInd,aiTrialInd];
    end
    
    if ~isempty(aiRelevantTrialsInd)
        strctUnit = fnCollectPassiveFixationNewUnitStatsAux(...
            strctKofiko, strctSync, strctConfig, strctInterval, strListName, aiRelevantTrialsInd, iParadigmIndex,afActualFlipTime_PLX);
        if ~isempty(strctUnit)
            acUnitsStat = [acUnitsStat,{strctUnit}];
        end
    end
end % End of List iter

return;




function strctUnit = fnCollectPassiveFixationNewUnitStatsAux(...
    strctKofiko, strctSync, strctConfig, strctInterval, strListName, aiTrialIndices, iParadigmIndex,afActualFlipTime_PLX)

global g_acDesignCache

strctUnit = [];

fStartTS_PTB_Kofiko = fnTimeZoneChange(strctInterval.m_fStartTS_Plexon,strctSync,'Plexon','Kofiko');
fEndTS_PTB_Kofiko = fnTimeZoneChange(strctInterval.m_fEndTS_Plexon,strctSync,'Plexon','Kofiko');

[Dummy, Dummy, strExt]=fileparts(strListName);
if strcmpi(strExt,'.txt')
    [a2bStimulusToCondition,acConditionNames,strImageListDescrip] = fnLoadCategoryFile(strListName);
    
elseif strcmpi(strExt,'.xml')
    [strPath,strImageListDescrip]=fileparts(strListName);
    
    
    % Is in cache?
    if isempty(g_acDesignCache)
        bExist = false;
    else
        [bExist, strValue, Value] = fnFindAttribute(g_acDesignCache.m_a2cAttributes, strListName);
    end
    
    if bExist
         fnWorkerLog('Loading Design (from cache) to infer conditions (%s)',strListName);
        acConditionNames = Value{1};
        a2bStimulusToCondition = Value{2};
    else
        
        if exist(strListName,'file')
            fnWorkerLog('Loading Design to infer conditions (%s)',strListName);
            
            
           
            strctDesign = fnParsePassiveFixationDesignMediaFiles(strListName, false, false);
        else
            % Try locally ?
            if exist([strImageListDescrip,'.xml'])
                fnWorkerLog('Loading Design to infer conditions (%s)',strImageListDescrip);
                strctDesign = fnParsePassiveFixationDesignMediaFiles([strImageListDescrip,'.xml'], false, false);
            else
                assert(false);
            end;
        end
        
        acConditionNames = strctDesign.m_acConditionNames;
        a2bStimulusToCondition = strctDesign.m_a2bStimulusToCondition;
        
        g_acDesignCache = fnAddAttribute(g_acDesignCache, strListName, '', {acConditionNames, a2bStimulusToCondition});
        
    end
end

fnWorkerLog('Passive fixation experiment. List: %s',strImageListDescrip);
[strSpecialAnalysisFunc, strDisplayFunction,strctSpecialAnalysis] = fnFindSpecialAnalysis(strctConfig,  strListName);
% Seems like PTB returns crappy time estimates when flips actually occurred
% with our LCD monitor.
% use the timestamp stored in Kofiko instead...
aiStimulusIndex = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials.Buffer(1,aiTrialIndices);

afOnset_StimServer_TS = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials.Buffer(2,aiTrialIndices);
%afOffset_StimServer_TS = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials.Buffer(3,aiTrialIndices);
afStimulusON_TS_Plexon_Using_StimulusServer = fnTimeZoneChange(afOnset_StimServer_TS, strctSync,'StimulusServer','Plexon');
%afStimulusOFF_TS_Plexon = fnTimeZoneChange(afOffset_StimServer_TS, strctSync,'StimulusServer','Plexon');

afOnset_Kofiko_TS = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials.Buffer(5,aiTrialIndices);

if size(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials.Buffer,1) < 8
    afImageON =  fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusON_MS.TimeStamp,...
    strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusON_MS.Buffer(:,1),afOnset_Kofiko_TS);

    afImageOFF =  fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusOFF_MS.TimeStamp,...
    strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusOFF_MS.Buffer(:,1),afOnset_Kofiko_TS);
else
    afImageON =  strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials.Buffer(8,aiTrialIndices);
    afImageOFF =  strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials.Buffer(9,aiTrialIndices);
end

afStimulusON_TS_Plexon = fnTimeZoneChange(afOnset_Kofiko_TS, strctSync,'Kofiko','Plexon');
afStimulusOFF_TS_Plexon = afStimulusON_TS_Plexon+afImageON/1e3;

if ~isempty(afActualFlipTime_PLX)
    fnWorkerLog('Adjusting image onset times using photodiode information!');
    afScreenLag_ON_MS = nans(1,  length(afStimulusON_TS_Plexon));
    afScreenLag_OFF_MS = nans(1,  length(afStimulusOFF_TS_Plexon));
    afModifiedStimulusON_TS_Plexon = nans(1,  length(afStimulusON_TS_Plexon));
    afModifiedStimulusOFF_TS_Plexon = nans(1,  length(afStimulusOFF_TS_Plexon));
    for k=1:length(afStimulusON_TS_Plexon)
        % Find the closest actual flip that happened on monitor (should be
        % later than the expected flip...around 10-15 ms later ?)
        [~,iIndex1] = min( abs(afActualFlipTime_PLX - afStimulusON_TS_Plexon(k)));
        [~,iIndex2] = min( abs(afActualFlipTime_PLX - afStimulusON_TS_Plexon_Using_StimulusServer(k)));
        lag1 = (afActualFlipTime_PLX(iIndex1) - afStimulusON_TS_Plexon(k))*1e3;
        lag2 = (afActualFlipTime_PLX(iIndex2) - afStimulusON_TS_Plexon_Using_StimulusServer(k))*1e3;
        % [iIndex] = find( (afActualFlipTime_PLX >= afStimulusON_TS_Plexon(k)),1,'first');
        
        if (abs(lag1) < abs(lag2))
            iIndex = iIndex1;
            afScreenLag_ON_MS(k) = (afActualFlipTime_PLX(iIndex) - afStimulusON_TS_Plexon(k))*1e3;
        else
            iIndex = iIndex2;
            afScreenLag_ON_MS(k) = (afActualFlipTime_PLX(iIndex) - afStimulusON_TS_Plexon_Using_StimulusServer(k))*1e3;
        end
        
        
        afModifiedStimulusON_TS_Plexon(k) = afActualFlipTime_PLX(iIndex);
        
        if 0
            figure(11);
            clf; hold on;
            for a=iIndex-155:iIndex+155
                plot(afActualFlipTime_PLX(a)*ones(1,2),[0 1],'b');
            end
            hold on;
            plot(afStimulusON_TS_Plexon(k)*ones(1,2),[0 0.5],'r--','LineWidth',2);
            plot(afStimulusON_TS_Plexon_Using_StimulusServer(k)*ones(1,2),[0 0.25],'c--','LineWidth',2);
            plot(afActualFlipTime_PLX(iIndex)*ones(1,2),[0.5 1],'g','LineWidth',2);
        end
        
        %iIndex = find(afActualFlipTime_PLX > afStimulusOFF_TS_Plexon(k),1,'first');
        [~,iIndex1] = min( abs(afActualFlipTime_PLX - afStimulusOFF_TS_Plexon(k)));
        [~,iIndex2] = min( abs(afActualFlipTime_PLX - afStimulusOFF_TS_Plexon(k)));
        lag1 = (afActualFlipTime_PLX(iIndex1) - afStimulusON_TS_Plexon(k))*1e3;
        lag2 = (afActualFlipTime_PLX(iIndex2) - afStimulusON_TS_Plexon_Using_StimulusServer(k))*1e3;
        % [iIndex] = find( (afActualFlipTime_PLX >= afStimulusON_TS_Plexon(k)),1,'first');
        
        if (abs(lag1) < abs(lag2))
            iIndex = iIndex1;
            afScreenLag_OFF_MS(k) = (afActualFlipTime_PLX(iIndex) - afStimulusOFF_TS_Plexon(k))*1e3;
            
        else
            iIndex = iIndex2;
            afScreenLag_OFF_MS(k) = (afActualFlipTime_PLX(iIndex) - afStimulusON_TS_Plexon_Using_StimulusServer(k))*1e3;
            
        end
        
        
        
        afModifiedStimulusOFF_TS_Plexon(k) = afActualFlipTime_PLX(iIndex);
        
        if 0
            figure(11);
            clf; hold on;
            for a=iIndex-5:iIndex+5
                plot(afActualFlipTime_PLX(a)*ones(1,2),[0 1],'b');
            end
            
            plot(afStimulusOFF_TS_Plexon(k)*ones(1,2),[0 0.5],'r--','LineWidth',2);
            plot(afActualFlipTime_PLX(iIndex)*ones(1,2),[0 0.5],'g','LineWidth',2);
        end
        %         plot(afStimulusON_TS_Plexon(k-1)*ones(1,2),[0 0.5],'c--','LineWidth',2);
        %         plot(afStimulusON_TS_Plexon(k-2)*ones(1,2),[0 0.5],'m--','LineWidth',2);
        %
        %         plot(afStimulusOFF_TS_Plexon(k)*ones(1,2),[0 0.5],'r','LineWidth',2);
        %         plot(afStimulusOFF_TS_Plexon(k-1)*ones(1,2),[0 0.5],'c','LineWidth',2);
        %         plot(afStimulusOFF_TS_Plexon(k-2)*ones(1,2),[0 0.5],'m','LineWidth',2);
        %         [afImageON(k-2:k);
        %         afImageOFF(k-2:k)]
        %
        
        
        
    end
    fnWorkerLog('Average screen lag: %.2f ms',nanmean(afScreenLag_ON_MS));
    
end
% Adjust 
iNumFlipONErrors = sum(abs(afScreenLag_ON_MS) > 50);
iNumFlipOFFErrors = sum(abs(afScreenLag_OFF_MS) > 50);
if iNumFlipONErrors > 0 && iNumFlipONErrors <= 4
    fprintf('WARNING, %d flip mismatchs with lag longer than 50 ms were detected\n',iNumFlipONErrors+iNumFlipOFFErrors);
elseif iNumFlipONErrors  > 5
    error('Something went terribly wrong with photodiode synchronization');
end;

% Find valid trials, in which monkey fixated at the fixation point
strctValidTrials = fnFindValidTrialsAux(strctKofiko,strctInterval, strctSync, iParadigmIndex,...
    strctConfig.m_strctParams.m_fFixationPercThreshold,...
    aiStimulusIndex,afModifiedStimulusON_TS_Plexon,afModifiedStimulusOFF_TS_Plexon,strctSpecialAnalysis);

abValidTrials = strctValidTrials.m_abValidTrials;

if isempty(a2bStimulusToCondition)
    iNumStimuli = length(unique(aiStimulusIndex));
else
    iNumStimuli = size(a2bStimulusToCondition,1);
end


% iMinimumValidTrialsToAnalyzeThisList = iNumStimuli;

if sum(abValidTrials) < 10
    fnWorkerLog('Less than 10 valid trials. Skipping this interval.');
    strctUnit = [];
    return;
end;

[strctStimulusParams,afValidStimuliOnEventTimeStamps] = ...
    fnGetStimulusParametersAux(strctKofiko, strctSync,iParadigmIndex,abValidTrials,afModifiedStimulusON_TS_Plexon);

fMaxTrialLengthMS = ceil(max(strctStimulusParams.m_afStimulusOFF_ALL_MS)+max(strctStimulusParams.m_afStimulusON_ALL_MS));

% Find which image list was used and get the categories
aiStimulusIndexValid = aiStimulusIndex(abValidTrials);

%%


% Construct Peristimulus intervals
aiPeriStimulusRangeMS = strctConfig.m_strctParams.m_iBeforeMS:fMaxTrialLengthMS+strctConfig.m_strctParams.m_iAfterMS;
iStartAvg = find(aiPeriStimulusRangeMS>=strctConfig.m_strctParams.m_iStartAvgMS,1,'first');
iEndAvg = find(aiPeriStimulusRangeMS>=strctConfig.m_strctParams.m_iEndAvgMS,1,'first');
iStartBaselineAvg = find(aiPeriStimulusRangeMS>=strctConfig.m_strctParams.m_iStartBaselineAvgMS,1,'first');
iEndBaselineAvg = find(aiPeriStimulusRangeMS>=strctConfig.m_strctParams.m_iEndBaselineAvgMS,1,'first');

   
strctUnit.m_strRecordedTimeDate = strctKofiko.g_strctAppConfig.m_strTimeDate;
strctUnit.m_iRecordedSession = strctInterval.m_iPlexonFrame;
strctUnit.m_iChannel = strctInterval.m_iChannel;
strctUnit.m_iUnitID = strctInterval.m_iUniqueID;
strctUnit.m_fDurationMin = (fEndTS_PTB_Kofiko - fStartTS_PTB_Kofiko)/60;
strctUnit.m_strParadigm = 'Passive Fixation New';
strctUnit.m_strImageListUsed = strListName;
strctUnit.m_strSubject = strctKofiko.g_strctAppConfig.m_strctSubject.m_strName;
strctUnit.m_strParadigmDesc = strImageListDescrip;
strctUnit.m_strImageListDescrip = strImageListDescrip;

% Read spikes!
strSpikesFile = strctInterval.m_strSpikeFile;
[strctSpikes, strctChannelInfo] = fnReadDumpSpikeFile(strSpikesFile, 'SingleUnit',[strctInterval.m_iChannel,strctInterval.m_iUniqueID],'Interval',[strctInterval.m_fStartTS_Plexon,strctInterval.m_fEndTS_Plexon]);


% Add attributes to unit
strctUnit = fnAddAttribute(strctUnit,'Type','Single Unit Statistics');
strctUnit = fnAddAttribute(strctUnit,'Depth', median(strctInterval.m_a2fAdvancerPositionTS_Plexon(2,:)));

strctUnit = fnAddAttribute(strctUnit,'Paradigm','Passive Fixation New');
strctUnit = fnAddAttribute(strctUnit,'List', strImageListDescrip);
strctUnit = fnAddAttribute(strctUnit,'Channel', num2str(strctInterval.m_iChannel),strctInterval.m_iChannel);
strctUnit = fnAddAttribute(strctUnit,'Unit', num2str(strctInterval.m_iUniqueID),strctInterval.m_iUniqueID);
strctUnit = fnAddAttribute(strctUnit,'Target', strctChannelInfo.m_strChannelName);
strctUnit = fnAddAttribute(strctUnit,'TimeDate', strctUnit.m_strRecordedTimeDate);
strctUnit = fnAddAttribute(strctUnit,'Subject', strctUnit.m_strSubject);

strctUnit.m_strctChannelInfo = strctChannelInfo;   
strctUnit.m_afSpikeTimes = strctSpikes.m_afTimestamps;

if length(strctUnit.m_afSpikeTimes) < strctConfig.m_strctParams.m_iDiscardUnitMinimumSpikes
    fnWorkerLog('Skipping. Not enough spikes');
    strctUnit = [];
    return;
end;


[strctUnit.m_fSNR,strctUnit.m_afSNR_Time] = fnComputeUnitSNR_Aux(strctSpikes.m_a2fWaveforms, strctSpikes.m_afTimestamps);
strctUnit = fnAddAttribute(strctUnit,'SNR', strctUnit.m_fSNR);


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

strctTmp.m_a2fWaveforms = strctSpikes.m_a2fWaveforms;
strctTmp.m_afTimestamps = strctSpikes.m_afTimestamps;

[a2bRaster,Tmp,a2fAvgSpikeForm] = fnRaster(strctTmp, ...
    afModifiedStimulusON_TS_Plexon, strctConfig.m_strctParams.m_iBeforeMS,...
    fMaxTrialLengthMS+strctConfig.m_strctParams.m_iAfterMS);

bDiscardOFFperiodInMultipleRasters = true;

if (bDiscardOFFperiodInMultipleRasters)
    [a2fUniquePresentationTimes, ~, aiMapToUnique] = unique([strctStimulusParams.m_afStimulusON_MS'],'rows');
else
    [a2fUniquePresentationTimes, ~, aiMapToUnique] = unique([strctStimulusParams.m_afStimulusON_MS',strctStimulusParams.m_afStimulusOFF_MS'],'rows');    
end
iNumUnique = size(a2fUniquePresentationTimes,1);
aiValidTrials = find(abValidTrials);
if iNumUnique> 1
    aiNumPresentations = histc(aiMapToUnique,1:iNumUnique);
    aiValidLongPresentations = find(aiNumPresentations > 20);
    iNumSubRasters = length(aiValidLongPresentations);
    for iRasterIter=1:iNumSubRasters
        fTrialLengthMS = sum(a2fUniquePresentationTimes(aiValidLongPresentations(iRasterIter),:));
        aiTimeRange = 1:find(strctUnit.m_aiPeriStimulusRangeMS >= (fTrialLengthMS+strctConfig.m_strctParams.m_iAfterMS),1,'first');
        strctUnit.m_astrctRaster(iRasterIter).m_aiTimeRange = strctUnit.m_aiPeriStimulusRangeMS(aiTimeRange);
        strctUnit.m_astrctRaster(iRasterIter).m_fON_MS = a2fUniquePresentationTimes(aiValidLongPresentations(iRasterIter),1);
        if (bDiscardOFFperiodInMultipleRasters)
            strctUnit.m_astrctRaster(iRasterIter).m_fOFF_MS = [];
        else
            strctUnit.m_astrctRaster(iRasterIter).m_fOFF_MS = a2fUniquePresentationTimes(aiValidLongPresentations(iRasterIter),2);
        end
        strctUnit.m_astrctRaster(iRasterIter).m_a2bRaster = a2bRaster(aiValidTrials(aiMapToUnique == aiValidLongPresentations(iRasterIter)), aiTimeRange);
        
        
        strctUnit.m_astrctRaster(iRasterIter).m_a2fAvgFirintRate_Stimulus  = 1e3 * fnAverageBy(strctUnit.m_astrctRaster(iRasterIter).m_a2bRaster, ...
            aiStimulusIndexValid(aiMapToUnique == aiValidLongPresentations(iRasterIter)),...
            diag(1:iNumStimuli)>0,strctConfig.m_strctParams.m_iTimeSmoothingMS,...
            strctConfig.m_strctParams.m_bGaussianSmoothing);
        
        if ~isempty(a2bStimulusToCondition)
            strctUnit.m_astrctRaster(iRasterIter).m_a2fAvgFirintRate_Category = 1e3 *  fnAverageBy(strctUnit.m_astrctRaster(iRasterIter).m_a2bRaster, ...
                aiStimulusIndexValid(aiMapToUnique == aiValidLongPresentations(iRasterIter)),...
                     a2bStimulusToCondition,strctConfig.m_strctParams.m_iTimeSmoothingMS,...
                strctConfig.m_strctParams.m_bGaussianSmoothing);
        end
    end
    
end
% 
% for iRasterIter=1:iNumUnique
%     figure(11);
%     clf;
%     imagesc(strctUnit.m_astrctRaster(iRasterIter).m_a2fAvgFirintRate_Stimulus,...
%     'xdata',strctUnit.m_astrctRaster(iRasterIter).m_aiTimeRange,'ydata',1:size(strctUnit.m_astrctRaster(iRasterIter).m_a2fAvgFirintRate_Stimulus,1));
% end

strctUnit.m_a2bRaster_Valid = a2bRaster(abValidTrials,:) > 0;
strctUnit.m_afStimulusONTime = afModifiedStimulusON_TS_Plexon(abValidTrials);
strctUnit.m_afStimulusONTimeAll = afModifiedStimulusON_TS_Plexon;

strctUnit.m_aiStimulusIndexValid = aiStimulusIndexValid;
strctUnit.m_aiStimulusIndex = aiStimulusIndex;

strctUnit.m_aiTrialIndex = aiTrialIndices;
strctUnit.m_aiTrialIndexValid = aiTrialIndices(abValidTrials);


if ~isfield( strctConfig.m_strctParams,'m_bGaussianSmoothing')
    strctConfig.m_strctParams.m_bGaussianSmoothing = true;
end;

strctUnit.m_a2fAvgFirintRate_Stimulus  = 1e3 * fnAverageBy(strctUnit.m_a2bRaster_Valid, ...
    aiStimulusIndexValid, diag(1:iNumStimuli)>0,strctConfig.m_strctParams.m_iTimeSmoothingMS,...
    strctConfig.m_strctParams.m_bGaussianSmoothing);

if ~isempty(a2bStimulusToCondition)
    strctUnit.m_a2fAvgFirintRate_Category = 1e3 *  fnAverageBy(strctUnit.m_a2bRaster_Valid, ...
        aiStimulusIndexValid, a2bStimulusToCondition,strctConfig.m_strctParams.m_iTimeSmoothingMS,...
        strctConfig.m_strctParams.m_bGaussianSmoothing);
else
    strctUnit.m_a2fAvgFirintRate_Category = [];
end
strctUnit.m_afAvgFirintRate_Stimulus = mean(strctUnit.m_a2fAvgFirintRate_Stimulus(:, iStartAvg:iEndAvg),2);
strctUnit.m_afBaseline = mean(strctUnit.m_a2fAvgFirintRate_Stimulus (:, iStartBaselineAvg:iEndBaselineAvg),2);
strctUnit.m_fAvgBaseline = mean(strctUnit.m_afBaseline);

strctUnit.m_iNumStimuli = iNumStimuli;
strctUnit.m_iNumCategories = size(a2bStimulusToCondition,2);

strctUnit.m_acConditionNames = acConditionNames;
strctUnit.m_a2bStimulusToCondition = a2bStimulusToCondition;


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
        abSamplesCat = ismember(strctUnit.m_aiStimulusIndexValid, find(a2bStimulusToCondition(:, iCatIter)));
        if sum(abSamplesCat) > 0
            strctUnit.m_afAvgFiringRateCategory(iCatIter) = fnMyMean(strctUnit.m_afStimulusResponseMinusBaseline(abSamplesCat));
        end
    end
    
    
end
if isfield(strctConfig.m_strctParams,'m_bSubtractBaseline') && strctConfig.m_strctParams.m_bSubtractBaseline
    strctUnit.m_a2fPValueCat = NaN*ones(strctUnit.m_iNumCategories +1,strctUnit.m_iNumCategories +1); % Last one is baseline
    
    
    for iCat1=1:strctUnit.m_iNumCategories
        
        abSamplesCat1 = ismember(strctUnit.m_aiStimulusIndexValid, find(a2bStimulusToCondition(:, iCat1)));
        afSamplesCat1 = strctUnit.m_afStimulusResponseMinusBaseline(abSamplesCat1);
        if sum(abSamplesCat1) > 0
            
            for iCat2=iCat1+1:strctUnit.m_iNumCategories
                abSamplesCat2 = ismember(strctUnit.m_aiStimulusIndexValid, find(a2bStimulusToCondition(:, iCat2)));
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
        fnStatisticalTestBy(strctUnit.m_a2bRaster_Valid, aiStimulusIndexValid, a2bStimulusToCondition,...
        iStartAvg,iEndAvg,iStartBaselineAvg,iEndBaselineAvg);
end

strctUnit.m_afRecordingRange = [min(strctInterval.m_a2fAdvancerPositionTS_Plexon(2,:)),max(strctInterval.m_a2fAdvancerPositionTS_Plexon(2,:))];

if strctConfig.m_strctParams.m_bIncludeLFP_PerGroup || strctConfig.m_strctParams.m_bIncludeLFP_PerTrial &&  exist(strctInterval.m_strAnalogChannelFile,'file')
    % Sample LFPs
    iNumTrials = length(abValidTrials);
    a2fSampleTimes = zeros(iNumTrials, length(aiPeriStimulusRangeMS));
    for iTrialIter = 1:iNumTrials
        a2fSampleTimes(iTrialIter,:) = afModifiedStimulusON_TS_Plexon(iTrialIter)+ aiPeriStimulusRangeMS/1e3;
    end;
    
    % Try new style file system...
%     
%     X.g_strctNeuralServer.m_aiActiveSpikeChannels
%     
%     X.g_strctNeuralServer.m_aiSpikeToAnalogMapping
%     
%     X.g_strctNeuralServer.m_aiEnabledChannels

    strctAnalog = fnReadDumpAnalogFile(strctInterval.m_strAnalogChannelFile,'Resample',a2fSampleTimes);
    
    
    a2fLFPs = strctAnalog.m_afData;

    bDoFrequencyAnalysis = false;
    
    strctUnit.m_a2fLFP = a2fLFPs;
    if ~isempty(a2bStimulusToCondition)
        strctUnit.m_a2fAvgLFPCategory = fnAverageBy(a2fLFPs(abValidTrials,:), aiStimulusIndexValid, a2bStimulusToCondition,0);
    else
        strctUnit.m_a2fAvgLFPCategory = [];
    end
    
    if bDoFrequencyAnalysis
    % Moving Frequency analysis
    adfreq = 1000;
    NW = 3;
    K = 2*NW-1;
    params.tapers=[NW K];
    params.fpass = [0 200];
    params.Fs = adfreq;
    params.trialave = 1;
    params.pad =2;
    
    winsize = 0.1; % 0.1 second window (i.e., 100 samples per window)
    winstep = 0.01; % 0.1 second intervals (i.e., advance window 10 sample points)
    movingwin = [winsize winstep];
    [S2,t2,f2] = mtspecgramc( a2fLFPs', movingwin, params );       
    strctUnit.m_strctSpectogram.m_afTime = t2-strctUnit.m_aiPeriStimulusRangeMS(1);
    strctUnit.m_strctSpectogram.m_afFreq = f2;
    strctUnit.m_strctSpectogram.m_a2fPower = real(S2);
    
    
    % Estimate the frequency spectrum for the first 30 seconds, and last 30
    % seconds. 
    
    afFirst = [strctInterval.m_fStartTS_Plexon, min(strctInterval.m_fStartTS_Plexon+30, strctInterval.m_fEndTS_Plexon)];
    afLast = [max(strctInterval.m_fStartTS_Plexon, strctInterval.m_fEndTS_Plexon-30) strctInterval.m_fEndTS_Plexon];
    strctAnalogFirst30 = fnReadDumpAnalogFile(strctInterval.m_strAnalogChannelFile,'Interval',afFirst);
    strctAnalogLast30 = fnReadDumpAnalogFile(strctInterval.m_strAnalogChannelFile,'Interval',afLast);
    
    adfreq = 2000;
    NW = 3;
    K = 2*NW-1;
    params.tapers=[NW K];
    params.fpass = [0 200];
    params.Fs = adfreq;
    params.trialave = 1;
    params.pad =0;    
    
    [strctUnit.strctSpectrum.m_afPowerStart,strctUnit.strctSpectrum.m_afFreqStart]=mtspectrumc(strctAnalogFirst30.m_afData,params) ;   
    [strctUnit.strctSpectrum.m_afPowerEnd,strctUnit.strctSpectrum.m_afFreqEnd]=mtspectrumc(strctAnalogLast30.m_afData,params) ;   
    end
 else
    strctUnit.m_a2fLFP = [];
    strctUnit.m_a2fAvgLFPCategory = [];
end

strctUnit.m_iUnitID = strctInterval.m_iUniqueID;

%      Wave form
warning off

strctUnit.m_afAvgWaveForm = mean(a2fAvgSpikeForm(abValidTrials,:), 1);
strctUnit.m_afStdWaveForm = std(a2fAvgSpikeForm(abValidTrials,:), [], 1);
strctUnit.m_iNumValidTrials = sum(abValidTrials);
warning on

strctUnit.m_abValidTrials = abValidTrials;

if ~isempty(strSpecialAnalysisFunc)
    try
    strctUnit = feval(strSpecialAnalysisFunc, strctUnit, strctKofiko, strctInterval,strctConfig,aiTrialIndices);
    catch
        fprintf('Failed to run %s\n',strSpecialAnalysisFunc);
    end
end
strctUnit.m_strDisplayFunction = strDisplayFunction;

% Comments
if isfield(strctKofiko.g_strctAppConfig,'Comments')
    aiIndicesOfCommentsDuringTheExperiment = find(strctKofiko.g_strctAppConfig.Comments.TimeStamp >= fStartTS_PTB_Kofiko & ...
        strctKofiko.g_strctAppConfig.Comments.TimeStamp <= fEndTS_PTB_Kofiko);
    strctUnit.m_acComments = strctKofiko.g_strctAppConfig.Comments.Buffer(aiIndicesOfCommentsDuringTheExperiment);
else
    strctUnit.m_acComments = [];
end


return;





function     strctValidTrials = fnFindValidTrialsAux(strctKofiko, strctInterval, strctSync, iParadigmIndex,fFixationPercThreshold, ...
    aiStimulusIndex,afModifiedStimulusON_TS_Plexon,afModifiedStimulusOFF_TS_Plexon,strctSpecialAnalysis)



% Now we know what was presented and at what time. 
% We can now extract eye position information and see whether the monkey
% actually looked inside the gaze rect
% For that we need several variables:
% 1. Eye Position in pixel coordinates
% 2. Fixation spot position in pixel coordinates
% 3. Gaze rect size (in pixels)


% Read in the Eye signal for this given frame...
strEyeXfile = [strctInterval.m_strRawFolder,filesep,strctInterval.m_strSession,'-EyeX.raw'];
strEyeYfile = [strctInterval.m_strRawFolder,filesep,strctInterval.m_strSession,'-EyeY.raw'];
if ~exist(strEyeXfile,'file') || ~exist(strEyeYfile,'file') 
    fprintf('Cannot find eye tracking file (%s). Aborting!\n',strEyeXfile);
    assert(false);
end;
[strctEyeX, afPlexonTime] = fnReadDumpAnalogFile(strEyeXfile,'Interval',[strctInterval.m_fStartTS_Plexon,strctInterval.m_fEndTS_Plexon]);
strctEyeY = fnReadDumpAnalogFile(strEyeYfile,'Interval',[strctInterval.m_fStartTS_Plexon,strctInterval.m_fEndTS_Plexon]);
iNumSamplesInInterval = length(afPlexonTime);
fSamplingFreq = strctEyeX.m_fSamplingFreq;
% 1. Eye position in pixel coordinates.
% Eye position is recorded by plexon in mV. This needs to be converted to
% pixel coordinates using the information stored in Kofiko data structure. 

% 1.1 Raw eye signal from Plexon:
afEyeXraw =  strctEyeX.m_afData;
afEyeYraw =  strctEyeY.m_afData;

% Notice, Raw eye signal can also be obtained from Kofiko:
% EyeRaw = fnResampleKofikoToPlex(strctKofiko.g_strctEyeCalib.EyeRaw, afPlexonTime, strctSession);
% However, plexon DAQ and Kofiko DAQ sample values a bit differently.
% Raw Eye signal (represented in kofiko) - 2048 = Raw eye signal (represented in plexon)

% 1.2 Gain, Offset, Fixation Spot and Rect, all obtained from Kofiko and
% aligned to Plexon time frame:
apt2fFixationSpot = fnTimeZoneChangeTS_Resampling(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.FixationSpotPix, 'Kofiko','Plexon',afPlexonTime, strctSync);

afStimulusSizePix = fnTimeZoneChangeTS_Resampling(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusSizePix, 'Kofiko','Plexon',afPlexonTime, strctSync);
afGazeBoxPix = fnTimeZoneChangeTS_Resampling(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.GazeBoxPix, 'Kofiko','Plexon',afPlexonTime, strctSync);
afOffsetX = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.CenterX, 'Kofiko','Plexon',afPlexonTime, strctSync);
afOffsetY = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.CenterY, 'Kofiko','Plexon',afPlexonTime, strctSync);
afGainX = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.GainX, 'Kofiko','Plexon',afPlexonTime, strctSync);
afGainY = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.GainY, 'Kofiko','Plexon',afPlexonTime, strctSync);

% The way to convert Raw Eye signal from plexon to screen coordinates is:
afEyeXpix = (afEyeXraw+2048 - afOffsetX).*afGainX + strctKofiko.g_strctStimulusServer.m_aiScreenSize(3)/2;
afEyeYpix = (afEyeYraw+2048 - afOffsetY).*afGainY + strctKofiko.g_strctStimulusServer.m_aiScreenSize(4)/2;


clear afOffsetX  afOffsetY  afGainX  afGainY afEyeXraw afEyeYraw
 
% Now, Test whether it was inside the rect box or not:
%afStimulusSizePix

abInsideGazeRect = afEyeXpix >= (apt2fFixationSpot(:,1) -  afGazeBoxPix) & afEyeXpix <= (apt2fFixationSpot(:,1) +  afGazeBoxPix) & ...
                   afEyeYpix >= (apt2fFixationSpot(:,2) -  afGazeBoxPix) & afEyeYpix <= (apt2fFixationSpot(:,2) +  afGazeBoxPix);

abInsideStimRect = afEyeXpix >= (apt2fFixationSpot(:,1) -  afStimulusSizePix) & afEyeXpix <= (apt2fFixationSpot(:,1) +  afStimulusSizePix) & ...
                   afEyeYpix >= (apt2fFixationSpot(:,2) -  afStimulusSizePix) & afEyeYpix <= (apt2fFixationSpot(:,2) +  afStimulusSizePix);
               
afDistToFixationSpot = sqrt( (afEyeXpix- apt2fFixationSpot(:,1)          ).^2 +  (afEyeYpix- apt2fFixationSpot(:,2)          ).^2 );

% Now, find invalid trials:
iNumTrials = length(aiStimulusIndex);
abValidTrials = zeros(1, iNumTrials) > 0;
afEyeDistanceFromFixationSpotMedian = zeros(1,iNumTrials);
afEyeDistanceFromFixationSpotMin = zeros(1,iNumTrials);
afEyeDistanceFromFixationSpotMax = zeros(1,iNumTrials);
afAvgStimulusSize = zeros(1,iNumTrials);
afFixationPerc = zeros(1,iNumTrials);
warning off

for iTrialIter=1:iNumTrials
  % The first or last trials can exceed the available data...
    % Crop them out...
 
    iStartIndex = max(1,1 + floor((afModifiedStimulusON_TS_Plexon(iTrialIter) - afPlexonTime(1)) * fSamplingFreq));
    iEndIndex =min(size(abInsideGazeRect,1),  1 + ceil((afModifiedStimulusOFF_TS_Plexon(iTrialIter) - afPlexonTime(1)) * fSamplingFreq));
    
    afDistX = afEyeXpix(iStartIndex:iEndIndex)-apt2fFixationSpot(iStartIndex:iEndIndex,1);
    afDistY = afEyeYpix(iStartIndex:iEndIndex)-apt2fFixationSpot(iStartIndex:iEndIndex,2);
    afDist = sqrt(afDistX.^2+afDistY.^2);
    if isempty(afDist)
        afEyeDistanceFromFixationSpotMax(iTrialIter)= NaN;
        afEyeDistanceFromFixationSpotMedian(iTrialIter)= NaN;
        afEyeDistanceFromFixationSpotMin(iTrialIter)= NaN;
    else
        afEyeDistanceFromFixationSpotMax(iTrialIter)= max(afDist);
        afEyeDistanceFromFixationSpotMedian(iTrialIter)= median(afDist);
        afEyeDistanceFromFixationSpotMin(iTrialIter)= min(afDist);
    end
    
    if isempty(strctSpecialAnalysis) || ~isfield(strctSpecialAnalysis,'m_strValidTrialMethod')
        
        fFixationPerc = sum(abInsideGazeRect(iStartIndex:iEndIndex)) / (iEndIndex-iStartIndex+1) * 100;
        afFixationPerc(iTrialIter) = fFixationPerc;
        
        abValidTrials(iTrialIter) = fFixationPerc > fFixationPercThreshold;
    else
        switch lower(strctSpecialAnalysis.m_strValidTrialMethod)
            
            case 'insidegazerect'
                fFixationPerc = sum(abInsideGazeRect(iStartIndex:iEndIndex)) / (iEndIndex-iStartIndex+1) * 100;
                afFixationPerc(iTrialIter) = fFixationPerc;
                abValidTrials(iTrialIter) = fFixationPerc > fFixationPercThreshold;
            case 'insidestimulus'
                fFixationPerc = sum(abInsideStimRect(iStartIndex:iEndIndex)) / (iEndIndex-iStartIndex+1) * 100;
                afFixationPerc(iTrialIter) = fFixationPerc;
                abValidTrials(iTrialIter) = fFixationPerc > fFixationPercThreshold;
            case 'fixeddisttofixationspot'
                abValidTrials(iTrialIter) = all( afDistToFixationSpot(iStartIndex:iEndIndex) <= strctSpecialAnalysis.m_fValidTrialDist);
                afFixationPerc(iTrialIter) = double(abValidTrials(iTrialIter)) * 100;
                
        end
    end
        
    
    
    
    afAvgStimulusSize(iTrialIter) = mean(afStimulusSizePix(iStartIndex:iEndIndex));
end
warning on
strctValidTrials.m_fFixationPercThreshold = fFixationPercThreshold;
strctValidTrials.m_abValidTrials = abValidTrials;
strctValidTrials.m_afEyeDistanceFromFixationSpotMedian = afEyeDistanceFromFixationSpotMedian;
strctValidTrials.m_afEyeDistanceFromFixationSpotMin = afEyeDistanceFromFixationSpotMin;
strctValidTrials.m_afEyeDistanceFromFixationSpotMax = afEyeDistanceFromFixationSpotMax;
strctValidTrials.m_afAvgStimulusSize = afAvgStimulusSize;
strctValidTrials.m_afFixationPerc = afFixationPerc;


if isfield(strctKofiko.g_astrctAllParadigms{iParadigmIndex},'DrawAttentionEvents')
   assert( sum(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.DrawAttentionEvents.TimeStamp==0) == sum(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.DrawAttentionEvents.TimeStamp==1))
   % Discard any trials that occured next to a draw attention event.
   aiStartIndices = find(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.DrawAttentionEvents.Buffer == 1);
   aiEndIndices = aiStartIndices+1;
   
   afStart_DrawAttention_TS_Kofiko = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.DrawAttentionEvents.TimeStamp(aiStartIndices);
   
   afImageON_TS_Kofiko = fnTimeZoneChange(afModifiedStimulusON_TS_Plexon,strctSync,'Plexon','Kofiko');
   afImageOFF_TS_Kofiko =fnTimeZoneChange(afModifiedStimulusOFF_TS_Plexon,strctSync,'Plexon','Kofiko');

   aiAttentionEvents = find(afStart_DrawAttention_TS_Kofiko >=afImageON_TS_Kofiko(1) & afStart_DrawAttention_TS_Kofiko<=afImageOFF_TS_Kofiko(end));
   
   
   if ~isempty(aiAttentionEvents)
       fnWorkerLog('Several trials were dropped because of a draw attention event');
       % Kill before, current and next trials that are close to a draw
       % attention event.
       iNumTrials = length(afImageON_TS_Kofiko);
       for k=1:length(aiAttentionEvents)
          % Find nearest trial
          [fDummy, iTrialIndex]=min( abs(afImageON_TS_Kofiko - afStart_DrawAttention_TS_Kofiko(aiAttentionEvents(k))));
          strctValidTrials.m_abValidTrials(max(1,iTrialIndex-1):min(iNumTrials,iTrialIndex+1)) = false;
       end
   end
   
   
end
    


return;



function [strctStimulusParams, afTimeStamps] = fnGetStimulusParametersAux(strctKofiko, strctSync,iParadigmIndex, abValidTrials,afModifiedStimulusON_TS_Plexon)
afTimeStampsALL = fnTimeZoneChange(afModifiedStimulusON_TS_Plexon,strctSync,'Plexon','Kofiko');
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
