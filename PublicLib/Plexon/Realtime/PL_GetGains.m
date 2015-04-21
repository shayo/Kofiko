function gains = PL_GetGains(s);
% PL_GetGains - get total analog gain (including preamp and SIG board gains) 
% for each MAP channel
%
% gains = PL_GetGains(s)
%
% Input:
%   s - server reference (see PL_InitClient)
%
% Output:
%   counts - 1 by 128 matrix, total analog gain for each MAP channel
%            note: systems with < 128 channels will report a gain of 0
%            for the unused entries
%
% Copyright (c) 2007 Plexon Inc
gains = mexPlexOnline(21, s);
