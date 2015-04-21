function [n, ts, analogSamples] = PL_TrialAnalogSamples(s, waitForCode, waitTimeout);
%
%   PL_TrialAnalogSamples
%
%  n                     Number of samples per channel in analogSamples
%  ts                    Timestamp of first sample
%  analogSamples         Matrix of sampled analog values for channels listed in activeAnalogChannels parameter of PL_DefineTrial
%   Note: analogSamples matrix is reset after each read, so list of samples must be accumulated by the calling program.
%
%  waitForCode           This event code, or the endTrialEventCode must occur before command is executed
%                        If zero, do not wait.
%  waitTimeout           Maximum amount of time to wait; will return after this many msecs (<=0 means wait indefinitely)
%
% Copyright (c) 2005 Plexon Inc
%
[n, ts, analogSamples] = mexPlexOnline(16, s, waitForCode, waitTimeout);
