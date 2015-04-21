%% Client
addpath('D:\Code\Doris\PublicLib\Msocket\');

% Connect to the server on port 3000 

sock = msconnect('Kofiko-23b',3000); 

for k=1:10000
    fprintf('Sending packet %d...',k);
    drawnow
    X=mssend_nonblk(sock, rand(1,10));
    fprintf('%d\n',X);
end

% Receive the variable -- 5 second 
% timeout before failure 

strImageList = 'D:\Data\Doris\Stimuli\rf3_files\Monkey_Bodyparts\imlist_faces_objects_bodies_new.txt';

success = mssend(sock,'StartPTB'); 

success = mssend(sock,['LoadList ',strImageList]); 

success = mssend(sock,'StopPTB'); 

success = mssend(sock,'CloseConnection'); 
%success = mssend(sock,'KillServer'); 

% close the socket 
msclose(sock);