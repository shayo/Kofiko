function fnDumpStrobeWords(strctStrobeWord, strOutFileName)
[strPath,strFile]=fileparts(strOutFileName);
if ~exist(strPath,'dir')
    mkdir(strPath)
end

Cnt = 0;
% Dump information to file....
hFileID = fopen(strOutFileName,'wb+');
iHeaderPrefix = fwrite(hFileID, 'KOFIKO_v1.00E','char'); % Identifier...
Cnt=Cnt+8*fwrite(hFileID,0 ,'uint64'); % HeaderSize

iNumStrobeWords = length(strctStrobeWord.m_aiWords);

Cnt=Cnt+8*fwrite(hFileID,iNumStrobeWords ,'uint64'); 
Cnt=Cnt+8*fwrite(hFileID,strctStrobeWord.m_aiWords ,'uint64'); 
Cnt=Cnt+8*fwrite(hFileID,strctStrobeWord.m_afTimestamp ,'double'); % Identifier...

fseek(hFileID,iHeaderPrefix,'bof');
fwrite(hFileID,Cnt,'uint64');
fclose(hFileID);

return;
