function afTrainOnsetTS = fnIdentifyStimulationTrainsSafe(strTrigFile, strTrainFile)
% Ideally, we could only use the Train file to identify trains
% But just to be sure, we also look at the trigger file.
% This will tell us if some trains were missed or if some were elicited
% manually without a trigger.
%%
bDropInvalidTrains = true;

fnWorkerLog('Loading Trigger File %s',strTrigFile);
[strctTrigger, afTriggerTime] = fnReadDumpAnalogFile(strTrigFile);
fnWorkerLog('Loading Train File %s',strTrainFile);
[strctTrain, afTrainTime] = fnReadDumpAnalogFile(strTrainFile);

fThreshold = max(strctTrigger.m_afData(:))/5;
if fThreshold < 100
    % Threshold of analog signal should be above 100.
    % if it is below 100 is means there were no pulses....
    afTrainOnsetTS = [];
    return;
end

astrctTriggerIntervals = fnGetIntervals(strctTrigger.m_afData > fThreshold);
iNumTriggers  = length(astrctTriggerIntervals);

fTrainAfterTriggerMS = 200;

afPeri = [0:fTrainAfterTriggerMS]/1e3;  % Assume train is elicited within 200ms after trigger (max) ? 
afTriggerOnsetsTS = afTriggerTime(cat(1,astrctTriggerIntervals.m_iStart));
a2fSampleTimes = zeros(iNumTriggers, length(afPeri));
for k=1:iNumTriggers
    a2fSampleTimes(k,:) = afTriggerOnsetsTS(k) + afPeri;
end

fMinTriggerSeparationMS = 50;
abInvalidTriggers = ([Inf,diff(afTriggerOnsetsTS)*1e3] < fMinTriggerSeparationMS);
iNumDoubleTriggers = sum(abInvalidTriggers);

% Now, sample the analog values of the train data
a2fTrainValues = reshape(interp1(afTrainTime, strctTrain.m_afData, a2fSampleTimes(:)),size(a2fSampleTimes));
if bDropInvalidTrains
    abValidTrains = sum(a2fTrainValues > fThreshold,2) > 0 & ~abInvalidTriggers';
else
    abValidTrains = ones(1,iNumTriggers)>0;
end

fnWorkerLog('%d Triggers were detected', iNumTriggers);
fnWorkerLog('%d Trains were detected right after those trigger (%d missed trains, %d double triggers)',sum(abValidTrains), sum(sum(a2fTrainValues > fThreshold,2) == 0),iNumDoubleTriggers);

% detect "spurious" trains 
if bDropInvalidTrains
astrctIntervalsRAW = fnGetIntervals(strctTrain.m_afData > fThreshold);
fMergeDistanceMS = 100;  % Merge train spikes that are within 100ms to be the same "Train"
iMergeDistancePoints = fMergeDistanceMS/1000 * strctTrain.m_fSamplingFreq;
astrctTrainIntervals = fnMergeIntervals(astrctIntervalsRAW, iMergeDistancePoints);
iNumTrains =length(astrctTrainIntervals); 
fnWorkerLog('%d Trains were detected from train data (regardless of triggers)', iNumTrains);
if ~isempty(astrctTrainIntervals)
afTrainOnsetsTS = afTrainTime(cat(1,astrctTrainIntervals.m_iStart));
% Match trains to triggers....
afMinTime = zeros(1, iNumTrains);
for iTrainIter=1:iNumTrains
    afMinTime(iTrainIter) = min(abs(afTrainOnsetsTS(iTrainIter) - afTriggerOnsetsTS));
end

abSpuriousTrains = afMinTime > fTrainAfterTriggerMS/1e3;

fnWorkerLog('%d Spurious Trains were detected (without triggers)',sum(abSpuriousTrains));

fnWorkerLog('Dropping spurious trains and reporting only ones that were with a trigger');
end
end

afTrainOnsetTS = afTriggerOnsetsTS(abValidTrains);

return;