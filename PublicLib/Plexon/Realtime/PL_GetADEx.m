function [n, t, d] = PL_GetADEx(s)
%
% PL_GetADEx - get continuous A/D sample data 
% (supports both "fast" and "slow" channels, unlike PL_GetAD)
%
% [n, t, d] = PL_GetADEx(s)
%
% Input:
%   s - server reference (see PL_Init)
%
% Output:
%   n - m by 1 matrix, where m is the total number of enabled A/D channels,
%		number of data points retrieved (for each channel),
%   t - m by 1 matrix, timestamp of the first data point for each enabled channel (in seconds)
%   d - n by nch matrix, where nch is the number of enabled A/D channels,
%       continuous A/D channel sample data:
%         d(:, 1) - a/d values for the first enabled channel
%         d(:, 2) - a/d values for the second enabled channel
%         etc.

% Note 1: Reading data from up to 256 A/D ("slow") channels is supported; 
% however, please make sure that you are using the latest version of 
% Rasputin, which includes support for acquisition from multiple NIDAQ 
% cards.
%
% Note 2: If you are using multiple A/D cards running at different per-
% channel sampling rates (e.g. 1 kHz and 40 kHz), the counts in the n 
% matrix, which determine the number of samples for the corresponding
% channel in the d matrix, will be different for "fast" and "slow"
% channels.  
%
% See also: PL_GetPars.m, which can be used to obtain the acquisition 
% parameters for continuous A/D channels, such as the sampling rates and a
% list of enabled channels.
%
% Copyright (c) 2008, Plexon Inc
%
[n, t, d] = mexPlexOnline(20, s);
