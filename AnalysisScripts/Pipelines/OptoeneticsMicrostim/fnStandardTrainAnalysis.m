function fnStandardTrainAnalysis(strSubject, strTimeDate,strctChannelInfo,strctUnitInterval, strctAdvancerInformation, strTrainFile,strTrainFile2,strAnalogChannelFile,strOutputFolder,strOpsin,...
    strEyeXFile,strEyeYFile,strctKofiko,strctSync)

if isempty(strctUnitInterval.m_afTimestamps)
    return;
end;

[strctTrain, afTrainTime] = fnReadDumpAnalogFile(strTrainFile,'Interval', strctUnitInterval.m_afInterval);
astrctUniqueTrains = fnIdentifyStimulationTrains(strctTrain,afTrainTime,true);
if ~isempty(astrctUniqueTrains)
fnStandardTrainAnalysisAux(strSubject, strTimeDate,strctChannelInfo,strctUnitInterval, strctAdvancerInformation, astrctUniqueTrains,strAnalogChannelFile,strOutputFolder,strOpsin,...
    strEyeXFile,strEyeYFile,strctKofiko,strctSync,'Grass1');
end

if exist(strTrainFile2,'file')
    fprintf('Running analysis using second trigger\n');
    [strctTrain2, afTrainTime2] = fnReadDumpAnalogFile(strTrainFile2,'Interval', strctUnitInterval.m_afInterval);
    astrctUniqueTrains2 = fnIdentifyStimulationTrains(strctTrain2,afTrainTime2,true);
    if isempty(astrctUniqueTrains2)
        return;
    end;
    fnStandardTrainAnalysisAux(strSubject, strTimeDate,strctChannelInfo,strctUnitInterval, strctAdvancerInformation, astrctUniqueTrains2,strAnalogChannelFile,strOutputFolder,strOpsin,...
        strEyeXFile,strEyeYFile,strctKofiko,strctSync,'Grass2');
    
    % And then another analysis joint trigger events...
    fFarAwaythresholdSec = 1.0;
    
    if ~isempty(astrctUniqueTrains)
        astrctTrainsIntersect = fnFindTrainsDeliveredRoughlyAtTheSameOnset(astrctUniqueTrains,astrctUniqueTrains2);
        if ~isempty(astrctTrainsIntersect)
            fnStandardTrainAnalysisAux(strSubject, strTimeDate,strctChannelInfo,strctUnitInterval, strctAdvancerInformation, astrctTrainsIntersect,strAnalogChannelFile,strOutputFolder,strOpsin,...
                strEyeXFile,strEyeYFile,strctKofiko,strctSync,'Grass1and2');
        end
        
        astrctTrainsIntersect1ButNot2 = fnFindNonIntersectingTrains(astrctUniqueTrains,astrctUniqueTrains2,fFarAwaythresholdSec);
        if ~isempty(astrctTrainsIntersect1ButNot2)
            fnStandardTrainAnalysisAux(strSubject, strTimeDate,strctChannelInfo,strctUnitInterval, strctAdvancerInformation, astrctTrainsIntersect1ButNot2,strAnalogChannelFile,strOutputFolder,strOpsin,...
                strEyeXFile,strEyeYFile,strctKofiko,strctSync,'Grass1no2');
        end
        astrctTrainsIntersect2ButNot1 = fnFindNonIntersectingTrains(astrctUniqueTrains2,astrctUniqueTrains,fFarAwaythresholdSec);
        if ~isempty(astrctTrainsIntersect2ButNot1)
            fnStandardTrainAnalysisAux(strSubject, strTimeDate,strctChannelInfo,strctUnitInterval, strctAdvancerInformation, astrctTrainsIntersect2ButNot1,strAnalogChannelFile,strOutputFolder,strOpsin,...
                strEyeXFile,strEyeYFile,strctKofiko,strctSync,'Grass2no1');
        end
    end
     
end


return;


function   astrctTrainsIntersect = fnFindNonIntersectingTrains(astrctUniqueTrains,astrctUniqueTrains2, fFarAwaythresholdSec)
iNumTrainTypesA = length(astrctUniqueTrains);
iNumTrainTypesB = length(astrctUniqueTrains2);
iGlobalCounter = 0;

for iIter1=1:iNumTrainTypesA
    for iIter2=1:iNumTrainTypesB
        
            % Check how many joint train triggers exist.
            % We need to find the closest time point for each trigger....
            iNumTrainsA = length(astrctUniqueTrains(iIter1).m_afTrainOnsetTS_Plexon);
            afMinDistSec = zeros(1,iNumTrainsA);
            aiCorrespondingIndB = zeros(1,iNumTrainsA);
            for k=1:iNumTrainsA
                [afMinDistSec(k), aiCorrespondingIndB(k)]= min(abs(astrctUniqueTrains(iIter1).m_afTrainOnsetTS_Plexon(k) - astrctUniqueTrains2(iIter2).m_afTrainOnsetTS_Plexon));
            end
            % Assume trains that occur within less than 1 ms to be the same
            % event...
            aiA_no_B = find(afMinDistSec>fFarAwaythresholdSec);
            
            iNumEvents = length(aiA_no_B);
            if iNumEvents > 10
                clear strctTrainIntersect
                strctTrainIntersect.m_iNumTrains = iNumEvents;
                strctTrainIntersect.m_iPulsesPerTrain = astrctUniqueTrains(iIter1).m_iPulsesPerTrain;
                strctTrainIntersect.m_afInterPulseMS = astrctUniqueTrains(iIter1).m_afInterPulseMS;
                strctTrainIntersect.m_afPulseLengthMS =astrctUniqueTrains(iIter1).m_afPulseLengthMS(aiA_no_B);
                strctTrainIntersect.m_fTrainLengthMS = astrctUniqueTrains(iIter1).m_fTrainLengthMS;
                
                strctTrainIntersect.m_aiTrainOnsetIndices = astrctUniqueTrains(iIter1).m_aiTrainOnsetIndices(aiA_no_B);
                strctTrainIntersect.m_aiTrainOffsetIndices = astrctUniqueTrains(iIter1).m_aiTrainOffsetIndices(aiA_no_B);
                strctTrainIntersect.m_afTrainOnsetTS_Plexon = astrctUniqueTrains(iIter1).m_afTrainOnsetTS_Plexon(aiA_no_B); 
                strctTrainIntersect.m_afTrainOffsetTS_Plexon  = astrctUniqueTrains(iIter1).m_afTrainOffsetTS_Plexon(aiA_no_B);
                 iGlobalCounter=iGlobalCounter+1;
                 astrctTrainsIntersect(iGlobalCounter) = strctTrainIntersect;
            end
    end
end

if iGlobalCounter == 0
    astrctTrainsIntersect= [];
    return;
end;

return;


function   astrctTrainsIntersect = fnFindTrainsDeliveredRoughlyAtTheSameOnset(astrctUniqueTrains,astrctUniqueTrains2)
iNumTrainTypesA = length(astrctUniqueTrains);
iNumTrainTypesB = length(astrctUniqueTrains2);
iGlobalCounter = 0;

for iIter1=1:iNumTrainTypesA
    for iIter2=1:iNumTrainTypesB
        
            % Check how many joint train triggers exist.
            % We need to find the closest time point for each trigger....
            iNumTrainsA = length(astrctUniqueTrains(iIter1).m_afTrainOnsetTS_Plexon);
            afMinDistSec = zeros(1,iNumTrainsA);
            aiCorrespondingIndB = zeros(1,iNumTrainsA);
            for k=1:iNumTrainsA
                [afMinDistSec(k), aiCorrespondingIndB(k)]= min(abs(astrctUniqueTrains(iIter1).m_afTrainOnsetTS_Plexon(k) - astrctUniqueTrains2(iIter2).m_afTrainOnsetTS_Plexon));
            end
            % Assume trains that occur within less than 1 ms to be the same
            % event...
            aiJointEventsA=find(afMinDistSec<1e-3);
            aiJointEventsB = aiCorrespondingIndB(aiJointEventsA);
            
            iNumJointEvents = length(aiJointEventsA);
            if iNumJointEvents > 10
                clear strctTrainIntersect
                strctTrainIntersect.m_iNumTrains = iNumJointEvents;
                strctTrainIntersect.m_iPulsesPerTrain = [astrctUniqueTrains(iIter1).m_iPulsesPerTrain,astrctUniqueTrains2(iIter2).m_iPulsesPerTrain];
                strctTrainIntersect.m_afPulseLengthMS = [astrctUniqueTrains(iIter1).m_afPulseLengthMS(aiJointEventsA)';...
                                                                                         astrctUniqueTrains2(iIter2).m_afPulseLengthMS(aiJointEventsB)'];
                strctTrainIntersect.m_fTrainLengthMS = max(astrctUniqueTrains(iIter1).m_fTrainLengthMS,astrctUniqueTrains2(iIter2).m_fTrainLengthMS);
                strctTrainIntersect.m_aiTrainOnsetIndices = min([astrctUniqueTrains(iIter1).m_aiTrainOnsetIndices(aiJointEventsA),                astrctUniqueTrains2(iIter2).m_aiTrainOnsetIndices(aiJointEventsB)],[],2)';
                strctTrainIntersect.m_aiTrainOffsetIndices = max([astrctUniqueTrains(iIter1).m_aiTrainOffsetIndices(aiJointEventsA),                astrctUniqueTrains2(iIter2).m_aiTrainOffsetIndices(aiJointEventsB)],[],2)';
                strctTrainIntersect.m_afTrainOnsetTS_Plexon = min([astrctUniqueTrains(iIter1).m_afTrainOnsetTS_Plexon(aiJointEventsA);                astrctUniqueTrains2(iIter2).m_afTrainOnsetTS_Plexon(aiJointEventsB)],[],1);
                strctTrainIntersect.m_afTrainOffsetTS_Plexon  = max([astrctUniqueTrains(iIter1).m_afTrainOffsetTS_Plexon(aiJointEventsA);                astrctUniqueTrains2(iIter2).m_afTrainOffsetTS_Plexon(aiJointEventsB)],[],1);
                
                strctTrainIntersect.m_strctTrainA = astrctUniqueTrains(iIter1);
                strctTrainIntersect.m_strctTrainB = astrctUniqueTrains(iIter2);
                strctTrainIntersect.m_aiJointEventsA = aiJointEventsA;
                strctTrainIntersect.m_aiJointEventsB = aiJointEventsB;
                 iGlobalCounter=iGlobalCounter+1;
                 astrctTrainsIntersect(iGlobalCounter) = strctTrainIntersect;
            end
    end
end

if iGlobalCounter == 0
    astrctTrainsIntersect= [];
    return;
end;

return;

    


function fnStandardTrainAnalysisAux(strSubject, strTimeDate,strctChannelInfo,strctUnitInterval, strctAdvancerInformation,astrctUniqueTrains, strAnalogChannelFile,strOutputFolder,strOpsin,...
    strEyeXFile,strEyeYFile,strctKofiko,strctSync,strTrigger)
% Align spikes and build a raster
% Build raster in 1ms percision.
iBeforeMS = -2000;
iAfterMS  =  2000;
iPassiveFixationParadigmIndex = fnFindParadigmIndex(strctKofiko,'Passive Fixation New');

fPercentContamination = sum(1e3*diff(strctUnitInterval.m_afTimestamps) <= 2) / length(strctUnitInterval.m_afTimestamps) * 100;

bHasContPulse = false;

iMinSpikesToAnalyze = 30;
iGlobalIter = 0;
for iTrainIter=1:length(astrctUniqueTrains)
    if isempty(strctUnitInterval.m_afTimestamps) || length(strctUnitInterval.m_afTimestamps) < iMinSpikesToAnalyze
        continue;
    end;
    
    iGlobalIter=iGlobalIter+1;
    
    if sum(astrctUniqueTrains(iTrainIter).m_iPulsesPerTrain == 1) > 0 && ...
            mean(mean(astrctUniqueTrains(iTrainIter).m_afPulseLengthMS)) > 200
        bHasContPulse = true;
        
        % Find the cont' train that was repeated most times and only
        % analyze the times for that one...
        if size(astrctUniqueTrains(iTrainIter).m_afPulseLengthMS,1) > 1
            fMode = mode(astrctUniqueTrains(iTrainIter).m_afPulseLengthMS(:,1));
            aiTrainSubset = find( abs(astrctUniqueTrains(iTrainIter).m_afPulseLengthMS(:, 1) -fMode) < 1);
        else
            fMode = mode(astrctUniqueTrains(iTrainIter).m_afPulseLengthMS(1,:));
            aiTrainSubset = find( abs(astrctUniqueTrains(iTrainIter).m_afPulseLengthMS(1,:) -fMode) < 1);
        end
        astrctUniqueTrains(iTrainIter).m_fTrainLengthMS = fMode;
    else
        aiTrainSubset = 1:length(astrctUniqueTrains(iTrainIter).m_aiTrainOffsetIndices);
    end
    
    [a2bRaster,aiPeriStimulusRangeMS] = fnRaster2(strctUnitInterval.m_afTimestamps,...
        astrctUniqueTrains(iTrainIter).m_afTrainOnsetTS_Plexon(aiTrainSubset) , iBeforeMS, astrctUniqueTrains(iTrainIter).m_fTrainLengthMS +iAfterMS);
    
    [aiBefore, aiDuring, aiAfter, afAvgWaveFormBefore,afAvgWaveFormDuring, afAvgWaveFormAfter,...
        afStdWaveFormBefore,afStdWaveFormDuring,afStdWaveFormAfter] = ...
        fnSegregateWaveForms(strctUnitInterval.m_afTimestamps,strctUnitInterval.m_a2fWaveforms, ...
        astrctUniqueTrains(iTrainIter).m_afTrainOnsetTS_Plexon(aiTrainSubset), iBeforeMS, astrctUniqueTrains(iTrainIter).m_fTrainLengthMS, iAfterMS);
    
    iAvgLen = 8;
    afSmoothingKernelMS = fspecial('gaussian',[1 7*iAvgLen],iAvgLen);
    a2fSmoothRaster = conv2(a2bRaster,afSmoothingKernelMS ,'same');
    
    
    
    strctUnitInterval.m_strctChannelInfo = strctChannelInfo;
    strctUnitInterval.m_iUnitIndex = strctUnitInterval.m_iUnitIndex;
    
    % Set before/after according to "during" to have equal variance....
    abBefore = aiPeriStimulusRangeMS<=0 & aiPeriStimulusRangeMS >= -astrctUniqueTrains(iTrainIter).m_fTrainLengthMS;
    abDuring = aiPeriStimulusRangeMS>0 & aiPeriStimulusRangeMS <= astrctUniqueTrains(iTrainIter).m_fTrainLengthMS;
    abAfter = aiPeriStimulusRangeMS > astrctUniqueTrains(iTrainIter).m_fTrainLengthMS & aiPeriStimulusRangeMS < 2*astrctUniqueTrains(iTrainIter).m_fTrainLengthMS;
    
    strctUnitInterval.m_astrctTrain(iGlobalIter).m_afAvgSpikesBefore = sum( a2bRaster(:,aiPeriStimulusRangeMS<=0),2) / sum(aiPeriStimulusRangeMS<=0)*1e3;
    
    afAvgResponse = mean(a2bRaster,1);

    fHighThres = mean(afAvgResponse(abBefore)) + 3*std(afAvgResponse(abBefore));
    fLowThres = mean(afAvgResponse(abBefore)) - 3*std(afAvgResponse(abBefore));
    
    iIndexLatency = find(afAvgResponse(abDuring) >fHighThres | afAvgResponse(abDuring) < fLowThres,1,'first');
    if isempty(iIndexLatency)
        strctUnitInterval.m_astrctTrain(iGlobalIter).m_fLatencyMS = NaN;
    else
        strctUnitInterval.m_astrctTrain(iGlobalIter).m_fLatencyMS = iIndexLatency;
    end
    
    strctUnitInterval.m_astrctTrain(iGlobalIter).m_afAvgSpikesDuring = sum( a2bRaster(:,abDuring),2) / sum(abDuring)*1e3;
    strctUnitInterval.m_astrctTrain(iGlobalIter).m_afAvgSpikesAfter = sum( a2bRaster(:,abAfter),2) / sum(abAfter)*1e3;
    [h1,p1]=ttest(strctUnitInterval.m_astrctTrain(iGlobalIter).m_afAvgSpikesBefore, strctUnitInterval.m_astrctTrain(iTrainIter).m_afAvgSpikesDuring);
    [h1,p2]=ttest(strctUnitInterval.m_astrctTrain(iGlobalIter).m_afAvgSpikesAfter, strctUnitInterval.m_astrctTrain(iTrainIter).m_afAvgSpikesDuring);
    [h1,p3]=ttest(strctUnitInterval.m_astrctTrain(iGlobalIter).m_afAvgSpikesBefore, strctUnitInterval.m_astrctTrain(iTrainIter).m_afAvgSpikesAfter);
    if isnan(p1) || isnan(p2) || isnan(p3)
        dbg = 1;
    end
    strctUnitInterval.m_astrctTrain(iGlobalIter).m_afStatisticalTests = [p1,p2,p3];
    
    strctUnitInterval.m_astrctTrain(iGlobalIter).m_strctTrain = astrctUniqueTrains(iTrainIter);
    strctUnitInterval.m_astrctTrain(iGlobalIter).m_a2bRaster = a2bRaster;
    strctUnitInterval.m_astrctTrain(iGlobalIter).m_a2fSmoothRaster = a2fSmoothRaster;
    strctUnitInterval.m_astrctTrain(iGlobalIter).m_aiPeriStimulusRangeMS = aiPeriStimulusRangeMS;
    strctUnitInterval.m_astrctTrain(iGlobalIter).m_afAvgWaveFormBefore = afAvgWaveFormBefore;
    strctUnitInterval.m_astrctTrain(iGlobalIter).m_afAvgWaveFormDuring = afAvgWaveFormDuring;
    strctUnitInterval.m_astrctTrain(iGlobalIter).m_afAvgWaveFormAfter = afAvgWaveFormAfter;
    
    strctUnitInterval.m_astrctTrain(iGlobalIter).m_afStdWaveFormBefore = afStdWaveFormBefore;
    strctUnitInterval.m_astrctTrain(iGlobalIter).m_afStdWaveFormDuring = afStdWaveFormDuring;
    strctUnitInterval.m_astrctTrain(iGlobalIter).m_afStdWaveFormAfter = afStdWaveFormAfter;
    strctUnitInterval.m_astrctTrain(iGlobalIter).m_afAvgWaveFormAll = mean(strctUnitInterval.m_a2fWaveforms,1);
    strctUnitInterval.m_astrctTrain(iGlobalIter).m_afStdWaveFormAll = std(strctUnitInterval.m_a2fWaveforms,1);
    
    
    % Sample LFPs
    iNumTrials = length(aiTrainSubset);
    a2fSampleTimes = zeros(iNumTrials, length(aiPeriStimulusRangeMS));
    for iTrialIter = 1: iNumTrials
        a2fSampleTimes(iTrialIter,:) = astrctUniqueTrains(iTrainIter).m_afTrainOnsetTS_Plexon(aiTrainSubset(iTrialIter))+ aiPeriStimulusRangeMS/1e3;
    end;
    strctLFP= fnReadDumpAnalogFile(strAnalogChannelFile,'resample',a2fSampleTimes);
    
    
    
    % Eye movements
    strctEyeX= fnReadDumpAnalogFile(strEyeXFile,'resample',a2fSampleTimes);
    strctEyeY= fnReadDumpAnalogFile(strEyeYFile,'resample',a2fSampleTimes);
    
    a2fOffsetX = reshape(fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.CenterX, 'Kofiko','Plexon',a2fSampleTimes(:), strctSync), size(a2fSampleTimes));
    a2fOffsetY = reshape(fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.CenterY, 'Kofiko','Plexon',a2fSampleTimes(:), strctSync), size(a2fSampleTimes));
    a2fGainX = reshape(fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.GainX, 'Kofiko','Plexon',a2fSampleTimes(:), strctSync), size(a2fSampleTimes));
    a2fGainY = reshape(fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.GainY, 'Kofiko','Plexon',a2fSampleTimes(:), strctSync), size(a2fSampleTimes));
    a2fEyeXpix = (strctEyeX.m_afData+2048 - a2fOffsetX).*a2fGainX + strctKofiko.g_strctStimulusServer.m_aiScreenSize(3)/2;
    a2fEyeYpix = (strctEyeY.m_afData+2048 - a2fOffsetY).*a2fGainY + strctKofiko.g_strctStimulusServer.m_aiScreenSize(4)/2;
    
    
    % Do a bit more analysis about eye movments
    abTrialsDuringPassiveFixation = zeros(1,iNumTrials);
    
    afParadigmsOnsetTimesAug = [strctKofiko.g_strctAppConfig.ParadigmSwitch.TimeStamp, Inf];
    aiPassiveFixationOnsets = find(ismember(strctKofiko.g_strctAppConfig.ParadigmSwitch.Buffer,'Passive Fixation New'));
    for iParadigmIter=1:length(aiPassiveFixationOnsets)
        fStart = afParadigmsOnsetTimesAug(aiPassiveFixationOnsets(iParadigmIter));
        fEnd= afParadigmsOnsetTimesAug(aiPassiveFixationOnsets(iParadigmIter)+1);
        afTrainOnsetsTS_Kofiko = fnTimeZoneChange(astrctUniqueTrains(iTrainIter).m_afTrainOnsetTS_Plexon(aiTrainSubset),strctSync,'Plexon','Kofiko');
        abTrialsDuringPassiveFixation(afTrainOnsetsTS_Kofiko >= fStart & afTrainOnsetsTS_Kofiko <= fEnd) = true;
    end
    
    if sum(abTrialsDuringPassiveFixation)  > 5 % We have at least five trains....
    
        % Was the monkey fixating before the onset for the relevant trials?
        % Where was the fixation spot ?
        iBeforeFixationMS = 200;
        fFixationCriterionPix = 50;
        aiTrainsDuringPassiveFixation = find(abTrialsDuringPassiveFixation);
        afAverageDistBeforeTrial = nans(size(abTrialsDuringPassiveFixation));
        iOnsetIndex = find(aiPeriStimulusRangeMS == 0);
        a2fDistToFixationSpotPix = zeros(length(aiTrainsDuringPassiveFixation),length(aiPeriStimulusRangeMS));
        a2fDistToFixationSpotPixZeroBaseline= zeros(length(aiTrainsDuringPassiveFixation),length(aiPeriStimulusRangeMS));
        a3fFixationSpot = reshape(fnTimeZoneChangeTS_Resampling(strctKofiko.g_astrctAllParadigms{iPassiveFixationParadigmIndex}.FixationSpotPix, 'Kofiko','Plexon',a2fSampleTimes(:), strctSync),[size(a2fSampleTimes),2]);
        
        
        for k=1:length(aiTrainsDuringPassiveFixation)
            iTrial = aiTrainsDuringPassiveFixation(k);
            afDistX = a3fFixationSpot(iTrial,:,1) - a2fEyeXpix(iTrial,:);
            afDistY = a3fFixationSpot(iTrial,:,2) - a2fEyeYpix(iTrial,:);
            a2fDistToFixationSpotPix(iTrial,:) = sqrt(afDistX.^2+afDistY .^2);
            afAverageDistBeforeTrial(iTrial) = mean(a2fDistToFixationSpotPix(iTrial,iOnsetIndex-iBeforeFixationMS:iOnsetIndex));
            a2fDistToFixationSpotPixZeroBaseline(iTrial,:) = sqrt(afDistX.^2+afDistY .^2)-afAverageDistBeforeTrial(iTrial) ;
        end
        %strctUnitInterval.m_astrctTrain(iGlobalIter).m_a2fXEyePos = a2fEyeXpix(
        
        abTrainsWithFixationBeforeOnset = afAverageDistBeforeTrial<fFixationCriterionPix;
        strctUnitInterval.m_astrctTrain(iGlobalIter).m_a2fXEyePix = a2fEyeXpix(abTrainsWithFixationBeforeOnset,:);
        strctUnitInterval.m_astrctTrain(iGlobalIter).m_a2fYEyePix = a2fEyeYpix(abTrainsWithFixationBeforeOnset,:);
        
        strctUnitInterval.m_astrctTrain(iGlobalIter).m_afAverageDistBeforeTrial = afAverageDistBeforeTrial;
        strctUnitInterval.m_astrctTrain(iGlobalIter).m_abTrainsWithFixationBeforeOnset = abTrainsWithFixationBeforeOnset;
        strctUnitInterval.m_astrctTrain(iGlobalIter).m_a2fDistToFixationSpotPixZeroBaseline = a2fDistToFixationSpotPixZeroBaseline;
        
        if 0
        % Add control statistics (random selcted events that are not within
        % a stimulation pulse). Search for similar number of events to
        % those of trains (?)
        dbg = 1;
        
        fIntervalLengthSec = strctUnitInterval.m_afInterval(2)-strctUnitInterval.m_afInterval(1);
        
        iNumAttempts = 10000;
        afRandomTimeEvents =strctUnitInterval.m_afInterval(1)+ ( rand(1,iNumAttempts) * fIntervalLengthSec);
        abNoTrainNearBy= zeros(1,iNumAttempts)>0;
        for k=1:iNumAttempts
            % 1. Test whether there is a sitmulation train near by. If so,
            % discard this random event
            fEventTS_PLX = afRandomTimeEvents(k);
            abNoTrainNearBy(k) = min(abs(astrctUniqueTrains(iTrainIter).m_afTrainOffsetTS_Plexon - fEventTS_PLX)) > 2*astrctUniqueTrains(iTrainIter).m_fTrainLengthMS/1e3;
        end
        fprintf('%d Random events were found to be valid (far away from stimulation)\n',sum(abNoTrainNearBy));
        afValidRandomEvents = afRandomTimeEvents(abNoTrainNearBy);
        iNumRandomEvents = sum(abNoTrainNearBy);
        % Sample time for eye movements
        a2fRandSampleTimes = zeros(iNumRandomEvents, length(aiPeriStimulusRangeMS));
        for iTrialIter = 1:iNumRandomEvents
            a2fRandSampleTimes(iTrialIter,:) = afValidRandomEvents(iTrialIter)+ aiPeriStimulusRangeMS/1e3;
        end;
        
        % Eye movements during random events
        strctEyeX= fnReadDumpAnalogFile(strEyeXFile,'resample',a2fRandSampleTimes);
        strctEyeY= fnReadDumpAnalogFile(strEyeYFile,'resample',a2fRandSampleTimes);
        
        a2fOffsetX = reshape(fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.CenterX, 'Kofiko','Plexon',a2fRandSampleTimes(:), strctSync), size(a2fRandSampleTimes));
        a2fOffsetY = reshape(fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.CenterY, 'Kofiko','Plexon',a2fRandSampleTimes(:), strctSync), size(a2fRandSampleTimes));
        a2fGainX = reshape(fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.GainX, 'Kofiko','Plexon',a2fRandSampleTimes(:), strctSync), size(a2fRandSampleTimes));
        a2fGainY = reshape(fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.GainY, 'Kofiko','Plexon',a2fRandSampleTimes(:), strctSync), size(a2fRandSampleTimes));
        a2fEyeXpix = (strctEyeX.m_afData+2048 - a2fOffsetX).*a2fGainX + strctKofiko.g_strctStimulusServer.m_aiScreenSize(3)/2;
        a2fEyeYpix = (strctEyeY.m_afData+2048 - a2fOffsetY).*a2fGainY + strctKofiko.g_strctStimulusServer.m_aiScreenSize(4)/2;
        % Monkey is fixating ?
        a2fDistToFixationSpotPix = zeros(iNumRandomEvents,length(aiPeriStimulusRangeMS));
        a2fDistToFixationSpotPixZeroBaselineRandomEvents= zeros(iNumRandomEvents,length(aiPeriStimulusRangeMS));
            a3fFixationSpot = reshape(fnTimeZoneChangeTS_Resampling(strctKofiko.g_astrctAllParadigms{iPassiveFixationParadigmIndex}.FixationSpotPix, 'Kofiko','Plexon',a2fRandSampleTimes(:), strctSync),[size(a2fRandSampleTimes),2]);        
            abCleanBaseline = zeros(1,iNumRandomEvents)>0;
            abNoBlink= zeros(1,iNumRandomEvents)>0;
        for iTrial=1:iNumRandomEvents
            afDistX = a3fFixationSpot(iTrial,:,1) - a2fEyeXpix(iTrial,:);
            afDistY = a3fFixationSpot(iTrial,:,2) - a2fEyeYpix(iTrial,:);
            a2fDistToFixationSpotPix(iTrial,:) = sqrt(afDistX.^2+afDistY .^2);
            afAverageDistBeforeTrial(iTrial) = mean(a2fDistToFixationSpotPix(iTrial,iOnsetIndex-iBeforeFixationMS:iOnsetIndex));
            abCleanBaseline(iTrial) = max(a2fDistToFixationSpotPix(iTrial,iOnsetIndex-iBeforeFixationMS:iOnsetIndex)) < fFixationCriterionPix;
            abNoBlink(iTrial) = max( abs(a2fDistToFixationSpotPix(iTrial,:))) < 1500;
            a2fDistToFixationSpotPixZeroBaselineRandomEvents(iTrial,:) = sqrt(afDistX.^2+afDistY .^2)-afAverageDistBeforeTrial(iTrial) ;
        end        
           
        aiValidRandomEventsWithFixation = find(afAverageDistBeforeTrial < fFixationCriterionPix & abCleanBaseline & abNoBlink);
        if ~isempty(aiValidRandomEventsWithFixation)
            aiRandom1000 = randi(length(aiValidRandomEventsWithFixation),1,1000);
            fprintf('Out of those, %d were with proper fixation in the preceeding 50 ms. keeping up to 1000!\n',length(aiValidRandomEventsWithFixation));
            strctUnitInterval.m_astrctTrain(iGlobalIter).m_afRandomEventsValid = afValidRandomEvents(aiValidRandomEventsWithFixation(aiRandom1000));
            strctUnitInterval.m_astrctTrain(iGlobalIter).m_a2fDistToFixationSpotPixZeroBaselineRandomEvents = a2fDistToFixationSpotPixZeroBaselineRandomEvents(aiValidRandomEventsWithFixation(aiRandom1000),:);
            strctUnitInterval.m_astrctTrain(iGlobalIter).m_a2fEyeXRandEvents = a2fEyeXpix(aiValidRandomEventsWithFixation(aiRandom1000),:);
            strctUnitInterval.m_astrctTrain(iGlobalIter).m_a2fEyeYRandEvents = a2fEyeYpix(aiValidRandomEventsWithFixation(aiRandom1000),:);
        else
            strctUnitInterval.m_astrctTrain(iGlobalIter).m_afRandomEventsValid = [];
            strctUnitInterval.m_astrctTrain(iGlobalIter).m_a2fDistToFixationSpotPixZeroBaselineRandomEvents = [];
        end
        end
        
    end
   
    
%     strctUnitInterval.m_astrctTrain(iGlobalIter).m_strctEye.m_afAverageDistBeforeTrial = afAverageDistBeforeTrial;
%     strctUnitInterval.m_astrctTrain(iGlobalIter).m_strctEye.m_abTrialsDuringPassiveFixation = abTrialsDuringPassiveFixation;
    
    strctUnitInterval.m_astrctTrain(iGlobalIter).m_strctLFP = strctLFP;
%     strctUnitInterval.m_astrctTrain(iGlobalIter).m_strctEye.m_a2fDistToFixationSpotPix = a2fDistToFixationSpotPix;
%     strctUnitInterval.m_astrctTrain(iGlobalIter).m_strctEye.m_a2fEyeXpix = a2fEyeXpix;
%     strctUnitInterval.m_astrctTrain(iGlobalIter).m_strctEye.m_a2fEyeYpix = a2fEyeYpix;
    
    
    afSampleAdvancerTimes =[strctUnitInterval.m_afTimestamps(1),strctUnitInterval.m_afTimestamps(end)];
    strctUnitInterval.m_astrctTrain(iGlobalIter).m_afIntervalDepthMM= fnMyInterp1( strctAdvancerInformation.m_afTS_PLX, strctAdvancerInformation.m_afDepth,afSampleAdvancerTimes);
end

if isfield(strctUnitInterval,'m_astrctTrain')
    strctUnitInterval.m_strDisplayFunction = 'fnDefaultOptogeneticsStimDisplayFunc';
    strctUnitInterval.m_fPercentContamination = fPercentContamination;
    strctUnitInterval  = fnAddAttribute(strctUnitInterval ,'Subject', strSubject);
    strctUnitInterval = fnAddAttribute(strctUnitInterval,'TimeDate', strTimeDate);
    strctUnitInterval = fnAddAttribute(strctUnitInterval,'Type','Optogenetics SUA/MUA Stat');
    strctUnitInterval = fnAddAttribute(strctUnitInterval,'Channel', num2str(strctChannelInfo.m_iChannelID));
    strctUnitInterval = fnAddAttribute(strctUnitInterval,'Interval', num2str(strctUnitInterval.m_iUnitIndex));
    strctUnitInterval = fnAddAttribute(strctUnitInterval,'Opsin', strOpsin);
    strctUnitInterval = fnAddAttribute(strctUnitInterval,'Trigger',  strTrigger);
    strctUnitInterval = fnAddAttribute(strctUnitInterval,'Depth',  mean(strctUnitInterval.m_astrctTrain(iGlobalIter).m_afIntervalDepthMM));
    
    strctUnitInterval = fnAddAttribute(strctUnitInterval,'Num Trains', length(astrctUniqueTrains));
    if bHasContPulse
        strctUnitInterval = fnAddAttribute(strctUnitInterval,'Cont Pulse', 'Yes');
    else
        strctUnitInterval = fnAddAttribute(strctUnitInterval,'Cont Pulse', 'No');
        
    end
    strStatFile = [strOutputFolder, filesep, strSubject,'-',strTimeDate,'_OptogeneticsMicrostim_Channel_',num2str(strctChannelInfo.m_iChannelID),'_Interval',num2str(strctUnitInterval.m_iUnitIndex),'_Trigger_',strTrigger,'.mat'];
    strctUnitInterval  = fnAddAttribute(strctUnitInterval ,'SUA/MUA', sprintf('%.2f',fPercentContamination));
    
    
    fnWorkerLog('Saving things to %s',strStatFile);
    save(strStatFile,'strctUnitInterval');
end
return;