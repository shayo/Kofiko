function fnMakeCompatibleWithCondor(strPath,strSession)
astrctPlexonFiles=dir([strPath,strSession,'*_spl*.plx']);
acNames = {astrctPlexonFiles.name};
iNumFiles = length(acNames);
% First, Identify which frames we have
iMaxFrames = 500;
abFrames = zeros(1,iMaxFrames);
aiCounters = zeros(1,iMaxFrames);
aiLinkToFileIndex = zeros(1,iMaxFrames);
bFoundIncompatibility = false;
for k=1:iNumFiles
    [strDummy,strFile,strExt]=fileparts(acNames{k});
    iIndex = strfind(strFile,'_spl_f');
    if ~isempty(iIndex)
        bFoundIncompatibility = true;
        
        if length( strFile(iIndex+6:end)) > 3
            iFrameIndex = str2num(strFile(iIndex+6:iIndex+8));
            iCounter = str2num(strFile(iIndex+10:end));
            if iCounter > aiCounters(iFrameIndex)
                aiCounters(iFrameIndex) = iCounter;
                aiLinkToFileIndex(iFrameIndex) = k;
            end
            abFrames(iFrameIndex) = 1;
        else
            iFrameIndex = str2num(strFile(iIndex+6:end));
            if aiCounters(iFrameIndex) == 0
                aiLinkToFileIndex(iFrameIndex) = k;
            end
            abFrames(iFrameIndex) = 1;
            
            
        end
    end
    
end

aiFramesFound = find(abFrames);
if ~isempty(aiFramesFound)
    % Make compatible
    for iFrameIter=1:length(aiFramesFound)
        fprintf('Renaming %-50s to %-50s\n',acNames{aiLinkToFileIndex(iFrameIter)}, [strSession,'_part_',num2str(iFrameIter-1),'.plx']);
        movefile([strPath,acNames{aiLinkToFileIndex(iFrameIter)}],[strPath,[strSession,'_part_',num2str(iFrameIter-1),'.plx']]);
    end
    
    % delete old spl files
    
    astrctRedundantPlexFiles=dir([strPath,strSession,'*_spl*.plx']);
    for k=1:length(astrctRedundantPlexFiles)
        fprintf('Deleting %s\n',astrctRedundantPlexFiles(k).name);
        delete([strPath,astrctRedundantPlexFiles(k).name]);
    end;
end
