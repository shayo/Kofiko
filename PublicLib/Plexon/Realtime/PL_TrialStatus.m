function [runFlag, trialStartedFlag, spikeStartedFlag, analogStartedFlag, lastTrialStatus] = PL_TrialStatus(s, waitFor, waitTimeout);
%
%  PL_TrialStatus
%
%  runFlag                1 if Plexon map is collecting data, 0 otherwise
%  trialStartedFlag       1 if a startTrialEventCode was more recent than endTrialEventCode
%  spikeStartedFlag       1 if a startSpikeEventCode was more recent than endSpikeEventCode
%  analogStartedFlag      1 if a startAnalogEventCode was more recent than endAnalogEventCode
%  lastTrialStatus        0 if there was no last trial, 1 if last trial ended normally, 2 if it was force-ended
%
%  waitFor                0 = do not wait, return immediately with flag results
%                         1 = do not return until runFlag==1
%                         2 = do not return until trialStartedFlag==1
%                         3 = do not return until trial ends (trialStartedFlag==0 and lastTrialStatus != 0)
%  waitTimeout            Maximum amount of time to wait; will return after this many msecs (<=0 means wait indefinitely)
%
% Copyright (c) 2005 Plexon Inc
%
[runFlag, trialStartedFlag, spikeStartedFlag, analogStartedFlag, lastTrialStatus] = mexPlexOnline(13, s, waitFor, waitTimeout);
