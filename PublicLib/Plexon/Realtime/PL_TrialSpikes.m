function [n, spikeList] = PL_TrialSpikes(s, waitForCode, waitTimeout);
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
%
% Copyright (c) 2005 Plexon Inc
%
[n, spikeList] = mexPlexOnline(15, s, waitForCode, waitTimeout);
