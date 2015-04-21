function s = PL_InitClient(s);
% PL_InitClient - initialize Plexon Client
%
% s = PL_InitClient(0)
%
% If the initialization is successful, 
% PL_InitClient returns a nonzero reference to the server
% that should be used in calls to other PL_* functions.
%
% PL_InitClient(0) returns zero if the initialization failed.
%
% Copyright (c) 2004, Plexon Inc
s = mexPlexOnline(9, -1);