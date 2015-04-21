%
%PAL_inverseCumulativeNormal   
%
%PAL_inverseCumulativeNormal is no longer functional.
%
%Use x = PAL_CumulativeNormal(params,y,'inverse'); instead of 
%   x = PAL_inverseCumulativeNormal(params,y);
%
% Introduced: Palamedes version 1.0.0 (NP)
% Modified: Palamedes version 1.2.0 (NP). Added warning regarding removal of
%   the function from a future version of Palamedes.
% Modified: Palamedes version 1.4.0 (NP). Functionality removed.


function out = PAL_inverseCumulativeNormal(params, y)

message = 'PAL_inverseCumulativeNormal is no longer functional. Use ';
message = [message 'x = PAL_CumulativeNormal(params,y,''inverse'') instead '];
message = [message 'of x = PAL_inverseCumulativeNormal(params,y).'];
error(message);
out = [];