s= PL_InitClient(0);

startTrialEventCode = 32000;
endTrialEventCode   = 32001;

startSpikeEventCode =  32002;
endSpikeEventCode = 32003;

startAnalogEventCode = 32004;
endAnalogEventCode = 32005;

activeSpikeChannels = 1:2;
activeAnalogChannels =  1:2;
sizeLimitMB = 5;

% Example:
%	PL_TrialDefine(s, -20793, 259, 0, 0, 0, 0, 0)
%	- trial starts at strobe event (257) with value 20793
%   - trial ends at event 259 (PL_StopExtChannel)
%	- spikes collection starts when trial starts
%	- spike collection stops at the end of the trial
%	- analog data collection starts when trial starts
%	- analog data collection stops at the end of the trial
%	- there is no restriction on how much data can be collected
%
% Calling PL_TrialDefine will reset any trial in progress.


%  PL_TrialDefine(s, -startTrialEventCode, -endTrialEventCode, -startSpikeEventCode, -endSpikeEventCode, ...
%      -startAnalogEventCode, -endAnalogEventCode, activeSpikeChannels, activeAnalogChannels, 0);

 PL_TrialDefine(s, -startTrialEventCode, -endTrialEventCode, -startSpikeEventCode, -endSpikeEventCode, ...
     0, 0, activeSpikeChannels, activeAnalogChannels, 0);



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
waitFor = 0;
waitTimeout = 0;
[rn, trial, spike, analog, last] = PL_TrialStatus(s, waitFor, waitTimeout)

PL_SendUserEventWord(s, startTrialEventCode);
PL_SendUserEventWord(s, startSpikeEventCode);
PL_SendUserEventWord(s, endSpikeEventCode);
 
 
PL_SendUserEventWord(s, endTrialEventCode);


% PL_SendUserEventWord(s, startSpikeEventCode);
% PL_SendUserEventWord(s, startAnalogEventCode);
% 
% 
% PL_SendUserEventWord(s, endAnalogEventCode);
% PL_SendUserEventWord(s, endSpikeEventCode);




%
%  PL_TrialEvents
%
%  n                     Number of events in eventList
%  eventList             Matrix n by 2, where (:, 1) is a timestamp, (:, 2) is a code
%
% Notes:
% 1) eventList is maintained as complete list, not segment that is cleared by each read.
% 2) Negative code means it is a strobe event with given value. For example, if code is -20973,
%    it was a strobe event (257) with value of 20973.
%
%  waitForCode           This event code, or the endTrialEventCode must occur before command is executed
%                        If zero, do not wait.
%  waitTimeout           Maximum amount of time to wait; will return after this many msecs (<=0 means wait indefinitely)
waitForCode = 0;
waitTimeout = 0;
[ne, eventList]  = PL_TrialEvents(s, waitForCode, waitTimeout);


%
%  PL_TrialSpikes
%
%  n                     Number of spikes in spikeList
%  spikeList             Matrix n by 3, where (:, 1) is a timestamp, (:, 2) is a channel, (:, 3 ) is a unit
%   Note: spikeList matrix is reset after each read, so list of times must be accumulated by the calling program.
%
%  waitForCode           This event code, or the endTrialEventCode must occur before command is executed
%                        If zero, do not wait.
%  waitTimeout           Maximum amount of time to wait; will return after this many msecs (<=0 means wait indefinitely)
[ns, spikeList]  = PL_TrialSpikes(s, waitForCode, waitTimeout);


