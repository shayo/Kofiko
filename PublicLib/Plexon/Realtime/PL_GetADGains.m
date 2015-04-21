function gains = PL_GetADGains(s);
% PL_GetGains - get total analog gain (including preamp and NIDAQ gain) 
% for each continuous NIDAQ A/D channel
%
% gains = PL_GetADGains(s)
%
% Input:
%   s - server reference (see PL_InitClient)
%
% Output:
%   counts - 1 by 256 matrix, total analog gain for each NIDAQ channel
%            note: systems with < 256 channels will report a gain of 0
%            for the unused entries
%
% Copyright (c) 2007 Plexon Inc
gains = mexPlexOnline(22, s);
