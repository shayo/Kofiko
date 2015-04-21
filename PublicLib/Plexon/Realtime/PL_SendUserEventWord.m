function [ret] = PL_SendUserEventWord(s, eventWord);
%
%  [ret] = PL_SendUserEventWord(s, eventWord)
%
% Input :
%   s           - server reference (see PL_InitClient)
%   eventWord   - event word (user data word)
%
% Calling PL_SendUserEventWord will inject a user event word with value eventWord 
% into the data stream.  Note that eventWord is treated as a 16 bit unsigned 
% integer value; any nonzero upper bits will be ignored.  Event words injected with
% this function will appear on the strobed event channel (257).
%
% Important - this function will ONLY work on the computer that is directly connected to the MAP.
% Server must be running on the same computer. This will not work across PlexNet.
%
% Copyright (c) 2009 Plexon Inc
%
[ret] = mexPlexOnline(25, s, eventChan, eventWord);
