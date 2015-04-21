function [nCoords, nDim, nVTMode, c] = PL_VTInterpret(t);
% PL_VTInterpret - interpret CinePlex video tracking data
%
% [nCoords, nDim, nVTMode, c] = PL_VTInterpret(t);
%
% Input:
%   t - n by 4 matrix, timestamp info (see PL_GetTS and PL_GetWFEvs for more info):
%       t(:, 1) - timestamp types (only #4 (external events) are used)
%       t(:, 2) - channel numbers (only =257 (strobed ext events) are used)
%       t(:, 3) - unit numbers (strobe value for strobed ext events)
%       t(:, 4) - timestamps in seconds
%
% Output:
%   nCoords - number of produced coordinates
%   nDim    - number of elemnts in produced coordinates
%             nDim = 3 for CENTROID, LED_1, LED_2, LED3
%             nDim = 4 for CENTROID_WITH_MOTION
%             nDim = 5 for LED_12, LED_23, LED_13
%             nDim = 7 for LED_123
%   nVTMode - VT mode:
%			  0 = UNKNOWN
%			  1 = CENTROID                // 1 set of coordinates, no motion
%			  2 = CENTROID_WITH_MOTION    // 1 set of coordinates, with motion
%			  3 = LED_1                   // 1 set of coordinates
%			  4 = LED_2                  
%			  5 = LED_3
%			  6 = LED_12                  // 2 sets of coordinates
%			  7 = LED_13
%			  8 = LED_23
%			  9 = LED_123                 // 3 sets of coordinates
%   c       - nCoords by nDim matrix of produced coordinates
%             c(:, 1) - timestamp
%             c(:, 2) - x1
%             c(:, 3) - y1
%             c(:, 4) - x2 or motion (if present)
%             c(:, 5) - y2 (if present)
%             c(:, 6) - x3 (if present)
%             c(:, 7) - y3 (if present)
%
[nCoords, nDim, nVTMode, c] = mexPlexOnline(18, t);