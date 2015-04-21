function PL_TrialDefine(s, startTrialEventCode, endTrialEventCode, startSpikeEventCode, endSpikeEventCode, startAnalogEventCode, endAnalogEventCode, activeSpikeChannels, activeAnalogChannels, sizeLimitMB);
%
%  PL_TrialDefine 
%
%  startTrialEventCode     event that defines the start of a trial
%  endTrialEventCode       event that defines the end of a trial
%  startSpikeEventCode     event that starts the trial-oriented saving of spike data
%  endSpikeEventCode       event that ends the trial-oriented saving of spike data
%  startAnalogEventCode    event that starts the trial-oriented saving of analog data
%  endAnalogEventCode      event that ends the trial-oriented saving of analog data
%  activeSpikeChannels     array of spike channel numbers to save
%  activeAnalogChannels    array of analog channel numbers to save
%  sizeLimitMB             maximum amount of data that can be buffered before trial end is forced
%
% Notes:
% 1) You can specify strobed values instead of event numbers. Just use negative numbers for that.
% 2) If you want to start saving spikes and analog data as soon as trial starts, use 0 to indicate it.
% 3) If you don't want to restrict the amount of data, use 0 to indicate it.
%
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
%
% Copyright (c) 2005 Plexon Inc
%
mexPlexOnline(12, s, startTrialEventCode, endTrialEventCode, startSpikeEventCode, endSpikeEventCode, startAnalogEventCode, endAnalogEventCode, activeSpikeChannels, activeAnalogChannels, sizeLimitMB);
