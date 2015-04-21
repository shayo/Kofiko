function [n, t, d] = PL_GetAD(s)
% PL_GetAD - get A/D data
%
% [n, t, d] = PL_GetAD(s)
%
% Input:
%   s - server reference (see PL_Init)
%
% Output:
%   n - 1 by 1 matrix, number of data points retrieved (for each channel)
%   t - 1 by 1 matrix, timestamp of the first data point (in seconds)
%   d - n by nch matrix, where nch is the number of active A/D channels,
%       A/D data
%       d(:, 1) - a/d values for the first active channel 
%       d(:, 2) - a/d values for the second active channel
%       etc.
%
% NOTE1: Reading data from up to 256 A/D ("slow") channels is supported; however, 
% please make sure that you are using the latest version of Rasputin (which includes
% support for acquisition from multiple NIDAQ cards in parallel).
%
% NOTE2: Although Rasputin now allows each A/D card to be run at either "slow" rate 
% (submultiple of 40 kHz, e.g. 10 kHz) or "fast" rate (MAP rate, 40 kHz) if the TIM
% mezzanine board option is installed, PL_GetAD assumes that all A/D cards are run 
% at the same rate.  If you are using both fast and slow A/D cards, please use the
% function PL_GetADEx, which returns the number of data points per channel for each
% channel separately in the n matrix.
%
% Copyright (c) 2004, Plexon Inc
%
[n, t, d] = mexPlexOnline(2, s);
