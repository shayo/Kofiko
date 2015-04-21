function [n, t, w] = PL_GetWFEvs(s);
% PL_GetWFEvs - get waveforms and events
%
% [n, t, w] = PL_GetWFEvs(s)
%
% Input:
%   s - server reference (see PL_Init)
%
% Output:
%   n - 1 by 1 matrix, number of waveforms retrieved
%
%   t - n by 4 matrix, timestamp info:
%       t(:, 1) - timestamp type (1 - neuron, 4 - external event)
%       t(:, 2) - channel numbers
%       t(:, 3) - unit numbers
%       t(:, 4) - timestamps in seconds
%
%   w - n by wf_len matrix of waveforms, where wf_len is the waveform length
%       (in data points)
%       w(1,:) - first waveform, w(2,:) - second waveform, etc.
%       waveforms for external events (when t(:,1) == 4) are all zeros
%
% Copyright (c) 2005, Plexon Inc
[n, t, w] = mexPlexOnline(17,s);
