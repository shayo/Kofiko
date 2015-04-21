function strctStrobe = fnReadDumpStrobeFile(strInputFile, varargin)
hFileID = fopen(strInputFile,'rb+');
strHeader = fread(hFileID, 13,'char=>char'); % Identifier...
strKofiko_v100_file = 'KOFIKO_v1.00E';
if ( all(strHeader(:) == strKofiko_v100_file(:)))
    iHeaderSize = fread(hFileID, 1,'uint64=>double'); % Identifier...
    
    iNumStrobeWords = fread(hFileID,1,'uint64=>double'); 
    strctStrobe.m_aiWords = fread(hFileID,iNumStrobeWords,'uint64=>double'); 
    strctStrobe.m_afTimestamp = fread(hFileID,iNumStrobeWords,'double=>double'); 
end

fclose(hFileID);
