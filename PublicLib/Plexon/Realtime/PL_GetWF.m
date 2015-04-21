function [n, t, w] = PL_GetWF(s);
% PL_GetWF - get waveforms
%
% [n, t, w] = PL_GetWF(s)
%
% Input:
%   s - server reference (see PL_Init)
%
% Output:
%   n - 1 by 1 matrix, number of waveforms retrieved
%
%   t - n by 3 matrix, timestamp info:
%       t(:, 1) - channel numbers
%       t(:, 2) - unit numbers
%       t(:, 3) - timestamps in seconds
%
%   w - n by wf_len matrix of waveforms, where wf_len is the waveform length
%       (in data points)
%       w(1,:) - first waveform, w(2,:) - second waveform, etc.
%
% Copyright (c) 2004, Plexon Inc
[n, t, w] = mexPlexOnline(5,s);
