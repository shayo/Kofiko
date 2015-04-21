function fnDumpChannelSpikes(strctChannelInfo,astrctSpikes, strOutFileName)
% The astrctSpikes structure contains:
% m_iUnitIndex
% m_afTimestamps
% m_iChannel
% m_afInterval
% m_a2fWaveforms

% check folder exist
[strPath,strFile]=fileparts(strOutFileName);
if ~exist(strPath,'dir')
    mkdir(strPath)
end

Cnt = 0;
% Dump information to file....
hFileID = fopen(strOutFileName,'wb+');
iHeaderPrefix = fwrite(hFileID, 'KOFIKO_v1.02S','char'); % Identifier...
Cnt=Cnt+8*fwrite(hFileID,0 ,'uint64'); % HeaderSize

% Dump channel information
Cnt=Cnt+8*fwrite(hFileID,length(strctChannelInfo.m_strPlxFile),'uint64'); 
Cnt=Cnt+fwrite(hFileID,strctChannelInfo.m_strPlxFile,'char'); 
Cnt=Cnt+8*fwrite(hFileID,length(strctChannelInfo.m_strChannelName),'uint64'); 
Cnt=Cnt+fwrite(hFileID,strctChannelInfo.m_strChannelName,'char'); 
Cnt=Cnt+8*fwrite(hFileID,strctChannelInfo.m_iChannelID,'uint64'); 
Cnt=Cnt+8*fwrite(hFileID,strctChannelInfo.m_fGain,'double'); 
Cnt=Cnt+8*fwrite(hFileID,strctChannelInfo.m_fThreshold,'double'); 
Cnt=Cnt+8*fwrite(hFileID,strctChannelInfo.m_bFiltersActive,'uint64'); 
Cnt=Cnt+8*fwrite(hFileID,strctChannelInfo.m_bSorted,'uint64'); 

iNumUnits = length(astrctSpikes);
aiNumSpikes = zeros(1,iNumUnits);
aiUnitIndices= zeros(1,iNumUnits);
a2fIntervals = zeros(iNumUnits,2);
for k=1:iNumUnits
    aiUnitIndices(k) = astrctSpikes(k).m_iUnitIndex;
    aiNumSpikes(k) = length(astrctSpikes(k).m_afTimestamps);
    a2fIntervals(k,:) = astrctSpikes(k).m_afInterval;
end
iWaveFormLength = size(astrctSpikes(1).m_a2fWaveforms,2);
Cnt=Cnt+8*fwrite(hFileID,iNumUnits,'uint64'); 
Cnt=Cnt+8*fwrite(hFileID,iWaveFormLength,'uint64'); 
Cnt=Cnt+8*fwrite(hFileID,aiUnitIndices,'uint64'); 
Cnt=Cnt+8*fwrite(hFileID,aiNumSpikes,'uint64'); 
Cnt=Cnt+8*fwrite(hFileID,a2fIntervals,'double'); 

for k=1:iNumUnits
    fwrite(hFileID,astrctSpikes(k).m_afTimestamps,'double'); 
    fwrite(hFileID,astrctSpikes(k).m_a2fWaveforms,'single'); 
end

fseek(hFileID,iHeaderPrefix,'bof');
fwrite(hFileID,Cnt,'uint64');
fclose(hFileID);

return;
