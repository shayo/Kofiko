% This experiment was to test the precsision of delivering precise wave
% forms using the fnDAQ function:
% Parameters used were:

% GatePort = 18;
% TriggerPort = 19;
% TriggerDelayMS = 1;
% GatePeriodMS = 3;
% FirstPulseLengthMS = 0.15;
% SecondPulseLengthMS = 0.15;
% InterPulseIntervalMS = 0.1;
% fnDAQ('DelayedTrigger',GatePort,TriggerPort,TriggerDelayMS,GatePeriodMS,FirstPulseLengthMS,SecondPulseLengthMS,InterPulseIntervalMS );
% WaitSecs(0.5);


% Analyze precision of using DAQ to drive wave forms....
strInputFile = 'D:\Data\Doris\Dual Wave Pulsing\AccuracyDualWaveDAQ.plx';
 
[iNumChannels, aiNumSamples] = plx_adchan_samplecounts(strInputFile);



[   strctAnalog1.m_fFreq, ...
    strctAnalog1.m_iNumSamples, ...
    strctAnalog1.m_afTimeStamp0, ... w
    strctAnalog1.m_aiNumSamplesInFragment, ...
    strctAnalog1.m_afData] = ...
    plx_ad_v(strInputFile, 25-1); %Plexon counts from zero


[   strctAnalog2.m_fFreq, ...
    strctAnalog2.m_iNumSamples, ...
    strctAnalog2.m_afTimeStamp0, ...
    strctAnalog2.m_aiNumSamplesInFragment, ...
    strctAnalog2.m_afData] = ...
    plx_ad_v(strInputFile, 26-1); %Plexon counts from zero

% Gating Signal is analog 2
astrctGateIntervals = fnGetIntervals(strctAnalog2.m_afData > 0.2);

fExpectedJitterDueToSamplingRateMS = 1/strctAnalog2.m_fFreq * 1e3;
fExpectedJitterDueToSamplingRateUsec = fExpectedJitterDueToSamplingRateMS *1e3;

iNumIntervals = length(astrctGateIntervals);
afGateLengthMS = (cat(1,astrctGateIntervals.m_iLength) / strctAnalog2.m_fFreq) * 1e3;

iPercOutliers = sum(afGateLengthMS > 3.06) / iNumIntervals * 1e2;

figure(1);
clf;
hist(afGateLengthMS,linspace(2.95,3.25,100));
fprintf('%.2f%% pulses were slightly longer than 3ms\n',iPercOutliers);

% Analyze the twin pulse length...

for iInterval=1:iNumIntervals
    aiInterval = astrctGateIntervals(iInterval).m_iStart:astrctGateIntervals(iInterval).m_iEnd;
    afTwinPulseData = strctAnalog1.m_afData(aiInterval);
    aiLatency(iInterval) = find(afTwinPulseData > 0.2,1,'first');
end

aiLatency/strctAnalog2.m_fFreq * 1e3