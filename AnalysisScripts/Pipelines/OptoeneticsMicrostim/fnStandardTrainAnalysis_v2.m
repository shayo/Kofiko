function fnStandardTrainAnalysis_v2(strSubject, strTimeDate,strctChannelInfo,strctUnitInterval, strctAdvancerInformation, strTrainFile,strAnalogChannelFile,strOutputFolder,strOpsin,...
    strEyeXFile,strEyeYFile,strctKofiko,strctSync)

if isempty(strctUnitInterval.m_afTimestamps)
    return;
end;

[strctTrain, afTrainTime] = fnReadDumpAnalogFile(strTrainFile,'Interval', strctUnitInterval.m_afInterval);
astrctUniqueTrains = fnIdentifyStimulationTrains(strctTrain,afTrainTime);
if ~isempty(astrctUniqueTrains)
fnStandardTrainAnalysisAux(strSubject, strTimeDate,strctChannelInfo,strctUnitInterval, strctAdvancerInformation, astrctUniqueTrains,strAnalogChannelFile,strOutputFolder,strOpsin,...
    strEyeXFile,strEyeYFile,strctKofiko,strctSync,'Grass1');
end

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

    % analyze all trains.
    aiTrainSubset = 1:length(astrctUniqueTrains(iTrainIter).m_aiTrainOffsetIndices);
    
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
         
        abTrainsWithFixationBeforeOnset = afAverageDistBeforeTrial<fFixationCriterionPix;
        strctUnitInterval.m_astrctTrain(iGlobalIter).m_a2fXEyePix = a2fEyeXpix(abTrainsWithFixationBeforeOnset,:);
        strctUnitInterval.m_astrctTrain(iGlobalIter).m_a2fYEyePix = a2fEyeYpix(abTrainsWithFixationBeforeOnset,:);
        strctUnitInterval.m_astrctTrain(iGlobalIter).m_afAverageDistBeforeTrial = afAverageDistBeforeTrial;
        strctUnitInterval.m_astrctTrain(iGlobalIter).m_abTrainsWithFixationBeforeOnset = abTrainsWithFixationBeforeOnset;
        strctUnitInterval.m_astrctTrain(iGlobalIter).m_a2fDistToFixationSpotPixZeroBaseline = a2fDistToFixationSpotPixZeroBaseline;
    end
    
    strctUnitInterval.m_astrctTrain(iGlobalIter).m_strctLFP = strctLFP;
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
    strctUnitInterval = fnAddAttribute(strctUnitInterval,'Unit', num2str(strctUnitInterval.m_iUnitIndex));
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