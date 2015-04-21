function [ret] = PL_SendUserEvent(s, eventCode);
%
%  [ret] = PL_SendUserEvent(s, eventCode)
%
% Input :
%   s           - server reference (see PL_InitClient)
%   eventCode   - event code to inject
%
% Calling PL_SendUserEvent will inject an Event with event code (channel number) eventCode 
% into the data stream.
% Important - this function will ONLY work on the computer that is directly connected to the MAP.
% Server must be running on the same computer. This will not work across PlexNet.
%
% Copyright (c) 2005 Plexon Inc
%
[ret] = mexPlexOnline(19, s, eventCode);
