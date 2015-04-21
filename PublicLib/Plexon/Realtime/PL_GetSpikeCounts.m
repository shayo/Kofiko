function counts = PL_GetSpikeCounts(s);
% PL_GetSpikeCounts - get spike counts 
%
% counts = PL_GetSpikeCounts(s)
%
% Input:
%   s - server reference (see PL_Init)
%
% Output:
%   counts - 1 by 512 matrix, array of spike counts.
%            The array contains the spike counts
%            for all possible 128 channels and 4 units per channel:
%              counts(1) = number of spikes for unit a of channel 1
%              counts(2) = number of spikes for unit b of channel 1
%              counts(3) = number of spikes for unit c of channel 1
%              counts(4) = number of spikes for unit d of channel 1
%              counts(5) = number of spikes for unit a of channel 2
%              ...
%              counts(512) = number of spikes for unit d of channel 128
%
% Copyright (c) 2004, Plexon Inc
counts = mexPlexOnline(8,s);
