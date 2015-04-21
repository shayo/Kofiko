%
%PAL_inverseLogistic
%
%PAL_inverseLogistic is no longer functional.
%
%Use x = PAL_CumulativeLogistic(params,y,'inverse'); instead of 
%   x = PAL_inverseLogistic(params,y);
%
% Introduced: Palamedes version 1.0.0 (NP)
% Modified: Palamedes version 1.2.0 (NP). Added warning regarding removal of
%   the function from a future version of Palamedes.
% Modified: Palamedes version 1.4.0 (NP). Functionality removed.


function out = PAL_inverseLogistic(params, y)

message = 'PAL_inverseLogistic is no longer functional. Use ';
message = [message 'x = PAL_Logistic(params,y,''inverse'') instead '];
message = [message 'of x = PAL_inverseLogistic(params,y).'];
error(message);
out = [];