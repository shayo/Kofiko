function [strctAnalog, afTime] = fnReadDumpAnalogFile(strInputFile, varargin)
bReadHeaderOnly = false;
bReadInterval = false;
iParamCount = 0;
strReadMode = 'Normal';
while iParamCount < length(varargin)
    iParamCount=iParamCount+1;
    switch lower(varargin{iParamCount})
        case 'readheaderonly'
            bReadHeaderOnly = true;
            strReadMode = 'HeaderOnly';
        case 'resample'
            a2fSampleTimes = varargin{iParamCount+1};
            iParamCount=iParamCount+1;
            strReadMode = 'Resample';
        case 'interval'
            strReadMode = 'Interval';
            fStartTS =varargin{iParamCount+1}(1);
            fEndTS =varargin{iParamCount+1}(2);
            bReadInterval = true;
            iParamCount=iParamCount+1;
    end
end
afTime = [];


hFileID = fopen(strInputFile,'rb+');
strHeader = fread(hFileID, 13,'char=>char'); % Identifier...
strKofiko_v100_file = 'KOFIKO_v1.00A';
if ( all(strHeader(:) == strKofiko_v100_file(:)))
    iHeaderSize = fread(hFileID, 1,'uint64=>double'); % Identifier...
    
    strctAnalog.m_iChannel = fread(hFileID,1,'uint64=>double'); % Identifier...
    strctAnalog.m_fSamplingFreq = fread(hFileID,1,'uint64=>double'); % Identifier...
    iStringLength = fread(hFileID,1,'uint64=>double'); % Identifier...
    strctAnalog.m_strChannelName = fread(hFileID,iStringLength,'char=>char'); % Identifier...
    iNumFrames = fread(hFileID,1,'uint64=>double'); % Identifier...
    strctAnalog.m_aiNumSamplesPerFrame = fread(hFileID,iNumFrames,'uint64=>double'); % Identifier...
    strctAnalog.m_afStartTS = fread(hFileID,iNumFrames,'double=>double'); % Identifier...
    strctAnalog.m_afEndTS =strctAnalog.m_afStartTS+strctAnalog.m_aiNumSamplesPerFrame/strctAnalog.m_fSamplingFreq;
    fseek(hFileID,13+iHeaderSize,'bof');
    switch (strReadMode)
        case 'Normal'
            strctAnalog.m_afData = fread(hFileID, sum(strctAnalog.m_aiNumSamplesPerFrame),'single=>double');
            afTime = zeros(1, length(strctAnalog.m_afData));
            aiStartInd = [1;1+cumsum(strctAnalog.m_aiNumSamplesPerFrame)];
            for k=1:length(strctAnalog.m_aiNumSamplesPerFrame)
                afTime( aiStartInd(k):aiStartInd(k+1)-1) = strctAnalog.m_afStartTS(k) + [(0:(strctAnalog.m_aiNumSamplesPerFrame(k)-1))]/strctAnalog.m_fSamplingFreq;
            end
            
        case 'Interval'
            [strctAnalog.m_afData,afTime] = fnReadInterval(hFileID, iHeaderSize, strctAnalog, fStartTS, fEndTS);
        case 'Resample'
            strctAnalog.m_afData = fnReadIntervalAndResample(hFileID, iHeaderSize, strctAnalog, a2fSampleTimes);
    end
    
end
fclose(hFileID);


function [afData, afTime] = fnReadInterval(hFileID, iHeaderSize,strctAnalog, fStartTS, fEndTS)
iStartFrame = find(strctAnalog.m_afStartTS <= fStartTS,1,'last');
if isempty(iStartFrame)
    iStartFrame = 1;
end
iEndFrame = find(strctAnalog.m_afEndTS >= fEndTS,1,'first');
if isempty(iEndFrame)
    iEndFrame = length(strctAnalog.m_afEndTS);
end


if iStartFrame == iEndFrame
    % OK. We narrowed it down to a specific interval
    % Find out the first sample to read and how many as
    % well....
    fDeltaTime = fStartTS - strctAnalog.m_afStartTS(iStartFrame);
    if fDeltaTime < 0
        % Ahh... need to handle this at some point as well...
        % Zero out samples before and make the first sample to
        % be read the first in this interval....
        
        iNumSamplesAfterFrameStart = floor(fDeltaTime * strctAnalog.m_fSamplingFreq);
        fActualTS_FirstDataSample = strctAnalog.m_afStartTS(iStartFrame) + iNumSamplesAfterFrameStart/strctAnalog.m_fSamplingFreq;
           iNumSamplesRequested = ceil((fEndTS-fStartTS) * strctAnalog.m_fSamplingFreq);
          afTime = fActualTS_FirstDataSample + [0:iNumSamplesRequested-1]/strctAnalog.m_fSamplingFreq;
         
         afData = nans(length(afTime),1);
            return;
        
    else
        iNumSamplesAfterFrameStart = floor(fDeltaTime * strctAnalog.m_fSamplingFreq);
        fActualTS_FirstDataSample = strctAnalog.m_afStartTS(iStartFrame) + iNumSamplesAfterFrameStart/strctAnalog.m_fSamplingFreq;
        
        % How many samples to read ?
        iNumSamplesRequested = ceil((fEndTS-fStartTS) * strctAnalog.m_fSamplingFreq);
        
        % How many samples to read ?
            if iNumSamplesAfterFrameStart > strctAnalog.m_aiNumSamplesPerFrame(iStartFrame)
                % Completely outside analog range....
                afTime = fActualTS_FirstDataSample + [0:iNumSamplesRequested-1]/strctAnalog.m_fSamplingFreq;
                afData = nans(length(afTime),1);
                return;
            end        
        
        if iNumSamplesAfterFrameStart+iNumSamplesRequested > strctAnalog.m_aiNumSamplesPerFrame(iStartFrame)
            
            iNumSamplesUnavailable = (iNumSamplesAfterFrameStart+iNumSamplesRequested)-strctAnalog.m_aiNumSamplesPerFrame(iStartFrame);
            
            % Samples requested exceed the available data...
            % Sample the ones that are available, but fill the rest with NaNs.
            iNumEntriesBefore = iNumSamplesAfterFrameStart+sum(strctAnalog.m_aiNumSamplesPerFrame(1:iStartFrame-1));
            
            % afAllData = fread(hFileID, sum(strctAnalog.m_aiNumSamplesPerFrame),'single=>double');
            afTime = fActualTS_FirstDataSample + [0:iNumSamplesRequested-1]/strctAnalog.m_fSamplingFreq;
            fseek(hFileID, 13+iHeaderSize+iNumEntriesBefore*4,'bof');
            afData = zeros(iNumSamplesRequested,1,'single');
            afData(1:iNumSamplesRequested-iNumSamplesUnavailable) = fread(hFileID, iNumSamplesRequested-iNumSamplesUnavailable,'single=>double');
            afData(iNumSamplesRequested-iNumSamplesUnavailable:end) = NaN;
            
            
        else
            % Seek to the correct location and read the data
            iNumEntriesBefore = iNumSamplesAfterFrameStart+sum(strctAnalog.m_aiNumSamplesPerFrame(1:iStartFrame-1));
            
            % afAllData = fread(hFileID, sum(strctAnalog.m_aiNumSamplesPerFrame),'single=>double');
            afTime = fActualTS_FirstDataSample + [0:iNumSamplesRequested-1]/strctAnalog.m_fSamplingFreq;
            fseek(hFileID, 13+iHeaderSize+iNumEntriesBefore*4,'bof');
            afData = fread(hFileID, iNumSamplesRequested,'single=>double');
        end
    end
    
else
 % A bit more complicated....
 % We will have a gap in the A/D... since the samples span multiple
 % plexon frames
 % see: Session : 110506_152934_Houdini.

 % I'm cutting corners here. Just load the whole thing and use interp1?
 iNumRequestedSamples = ceil(strctAnalog.m_fSamplingFreq * (fEndTS-fStartTS));
 afTime = linspace(fStartTS, fEndTS,iNumRequestedSamples );
 
 abValid = zeros(1, iNumRequestedSamples)>0;
 for iFrameIter=iStartFrame:iEndFrame
     abValidInThisFrame = afTime >= strctAnalog.m_afStartTS(iFrameIter) & afTime <= strctAnalog.m_afEndTS(iFrameIter);
     abValid = abValid | abValidInThisFrame;
 end
 
afAllFrameData = [];
afAllFrameTime = [];
aiFrames = iStartFrame:iEndFrame;
for iFrameIter=1:length(aiFrames)
    iFrame = aiFrames(iFrameIter);
     % Seek to the correct location and read the data
     iSamplesBeforeStartFrame = sum(strctAnalog.m_aiNumSamplesPerFrame(1:iFrame-1));
     fseek(hFileID, 13+iHeaderSize+iSamplesBeforeStartFrame*4,'bof');
     afAllFrameData = [afAllFrameData;...
         fread(hFileID, strctAnalog.m_aiNumSamplesPerFrame(iFrame),'single=>double');];
     afAllFrameTime = [afAllFrameTime,...
         strctAnalog.m_afStartTS(iFrame) + [0:strctAnalog.m_aiNumSamplesPerFrame(iFrame)-1]/strctAnalog.m_fSamplingFreq;];
end
      
 afData = reshape(single(interp1(afAllFrameTime,afAllFrameTime,afTime)), iNumRequestedSamples,1);
 afData(~abValid) = NaN;
 
end;
return;

function afData = fnReadIntervalAndResample(hFileID,iHeaderSize, strctAnalog, SampleTimes)
if iscell(SampleTimes)
    afAllSamplingTimes = cat(2,SampleTimes{:});
    fMinTS = min(afAllSamplingTimes(:));
    fMaxTS = max(afAllSamplingTimes(:));
else
    a2fSampleTimes = SampleTimes;
    fMinTS = min(a2fSampleTimes(:));
    fMaxTS = max(a2fSampleTimes(:));
end;
[afDataCont, afTime] = fnReadInterval(hFileID, iHeaderSize,strctAnalog, fMinTS, fMaxTS);

% Here we assume that sampling times are close enough in time, and we save
% the multiple seeks by reading a big chunk...

if iscell(SampleTimes)
    acData = cell(1, length(SampleTimes));
    for k=1:length(SampleTimes)
        afData{k}  = interp1(afTime, afDataCont, SampleTimes{k});
    end
else
    afData  = reshape(interp1(afTime, afDataCont, a2fSampleTimes(:)),size(a2fSampleTimes));
end
return;
