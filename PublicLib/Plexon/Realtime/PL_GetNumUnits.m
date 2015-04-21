function counts = PL_GetNumUnits(s);
% PL_GetNumUnits - get number of sorted units on each DSP channel
%
% counts = PL_GetNumUnits(s)
%
% Input:
%   s - server reference (see PL_InitClient)
%
% Output:
%   counts - 1 by 128 matrix, number of sorted units on each DSP channel
%
% Copyright (c) 2004 Plexon Inc
counts = mexPlexOnline(7,s);
