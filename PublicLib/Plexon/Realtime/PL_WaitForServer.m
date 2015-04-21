function res = PL_WaitForServer(s, wait_time);
% res = PL_WaitForServer - wait until the server signals that it had
%  just received new data
%
% res = PL_WaitForServer(s, wait_time)
%
% Input:
%   s - server reference (see PL_Init)
%   wait_time - 1 by 1 matrix, wait time in milliseconds
%        (maximum time to wait for the signal from the server)
%
% Output:
%   res - 1 by 1 matrix, res = 1 if the function returned due
%        to the server event, res = 0, if function did not get the server
%        event and returned due to the timeout
%  
% Copyright (c) 2004 Plexon Inc
res = mexPlexOnline(6,s, wait_time);