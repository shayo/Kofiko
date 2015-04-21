function [astrctUnits,strctChannelInfo] = fnReadDumpSpikeFile(strInputFile, varargin)
strctOpt=fnParseParams(varargin{:});

hFileID = fopen(strInputFile,'rb+');
strHeader = fread(hFileID, 13,'char=>char'); % Identifier...
if all(strHeader' == 'KOFIKO_v1.01S')
    astrctUnits = fnRead101Version(hFileID,strctOpt);
    strctChannelInfo = [];
elseif all(strHeader' == 'KOFIKO_v1.02S')
    [astrctUnits,strctChannelInfo] = fnRead102Version(hFileID,strctOpt);
else
    assert(false);
end
fclose(hFileID);
return;

function strctOpt=fnParseParams(varargin)
strctOpt.m_bReadInterval = false;
iParamCount = 0;
strctOpt.m_iUnitOfInterest = [];
strctOpt.m_iChannelOfInterest = [];
strctOpt.m_bHeaderOnly = false;
while iParamCount < length(varargin)
    iParamCount=iParamCount+1;
    switch lower(varargin{iParamCount})
        case 'headeronly'
            strctOpt.m_bHeaderOnly = true;
        case 'singleunit'
            strctOpt.m_iChannelOfInterest = varargin{iParamCount+1}(1);
            strctOpt.m_iUnitOfInterest = varargin{iParamCount+1}(2);
            iParamCount=iParamCount+1;
        case 'interval'
            strctOpt.m_fStartTS =varargin{iParamCount+1}(1);
            strctOpt.m_fEndTS =varargin{iParamCount+1}(2);
            strctOpt.m_bReadInterval = true;
            iParamCount=iParamCount+1;
    end
end
return;

function astrctUnits = fnRead101Version(hFileID,strctOpt)
iHeaderSize = fread(hFileID, 1,'uint64=>double'); % Identifier...

iNumUnits = fread(hFileID,1,'uint64=>double');
iWaveFormLength = fread(hFileID,1,'uint64=>double');
aiChannels = fread(hFileID,iNumUnits,'uint64=>double');
aiUnitIndices = fread(hFileID,iNumUnits,'uint64=>double');
aiNumSpikes = fread(hFileID,iNumUnits,'uint64=>double');
a2fIntervals = reshape(fread(hFileID,2*iNumUnits,'double=>double'),iNumUnits,2);

if isempty(strctOpt.m_iUnitOfInterest)
    for k=1:iNumUnits
        astrctUnits(k).m_iChannel = aiChannels(k);
        astrctUnits(k).m_iUnitIndex = aiUnitIndices(k);
        astrctUnits(k).m_afTimestamps = fread(hFileID,aiNumSpikes(k),'double=>double');
        astrctUnits(k).m_a2fWaveforms = reshape(fread(hFileID,iWaveFormLength*aiNumSpikes(k),'single=>double'),aiNumSpikes(k),iWaveFormLength);
        astrctUnits(k).m_afInterval = a2fIntervals(k,:);
    end
else
    % Skip directly to the unit of interest....
    
    iEntry = find(aiChannels ==strctOpt.m_iChannelOfInterest & aiUnitIndices == strctOpt.m_iUnitOfInterest);
    assert(~isempty(iEntry) && length(iEntry) == 1);
    iNumSpikesBefore = sum(aiNumSpikes(1:iEntry-1));
    % Jump directly to the region of interest....
    fseek(hFileID,13+iHeaderSize +iNumSpikesBefore*(8+iWaveFormLength*4),'bof');
    astrctUnits.m_iChannel = strctOpt.m_iChannelOfInterest;
    astrctUnits.m_iUnitIndex = strctOpt.m_iUnitOfInterest;
    astrctUnits.m_afTimestamps = fread(hFileID,aiNumSpikes(iEntry),'double=>double');
    astrctUnits.m_a2fWaveforms = reshape(fread(hFileID,iWaveFormLength*aiNumSpikes(iEntry),'single=>double'),aiNumSpikes(iEntry),iWaveFormLength);
    astrctUnits.m_afInterval = a2fIntervals(iEntry,:);
    if bReadInterval
        % Filter out non-relevant spikes...
        abInsideInterval = (astrctUnits.m_afTimestamps >= strctOpt.m_fStartTS & astrctUnits.m_afTimestamps <= strctOpt.m_fEndTS);
        astrctUnits.m_afTimestamps = astrctUnits.m_afTimestamps(abInsideInterval);
        astrctUnits.m_a2fWaveforms = astrctUnits.m_a2fWaveforms(abInsideInterval,:);
    end
end
return;


function [astrctUnits,strctChannelInfo] = fnRead102Version(hFileID,strctOpt)
iHeaderSize = fread(hFileID, 1,'uint64=>double'); % Identifier...

iPLXFileLen = fread(hFileID,1,'uint64=>double');
strctChannelInfo.m_strPlxFile = fread(hFileID,iPLXFileLen,'char=>char')';

iChannelNameLen = fread(hFileID,1,'uint64=>double');
strctChannelInfo.m_strChannelName = fread(hFileID,iChannelNameLen,'char=>char')';
strctChannelInfo.m_iChannelID = fread(hFileID,1,'uint64=>double');
strctChannelInfo.m_fGain = fread(hFileID,1,'double=>double');
strctChannelInfo.m_fThreshold = fread(hFileID,1,'double=>double');
strctChannelInfo.m_bFiltersActive = fread(hFileID,1,'uint64=>double');
strctChannelInfo.m_bSorted = fread(hFileID,1,'uint64=>double');

iNumUnits = fread(hFileID,1,'uint64=>double');
iWaveFormLength = fread(hFileID,1,'uint64=>double');
%aiChannels = fread(hFileID,iNumUnits,'uint64=>double');
aiUnitIndices = fread(hFileID,iNumUnits,'uint64=>double');
aiNumSpikes = fread(hFileID,iNumUnits,'uint64=>double');
a2fIntervals = reshape(fread(hFileID,2*iNumUnits,'double=>double'),iNumUnits,2);
if strctOpt.m_bHeaderOnly 
    for k=1:iNumUnits
        astrctUnits(k).m_iUnitIndex = aiUnitIndices(k);
        astrctUnits(k).m_afTimestamps = [];
        astrctUnits(k).m_a2fWaveforms = [];
        astrctUnits(k).m_afInterval = a2fIntervals(k,:);
    end
    return;
end;

if isempty(strctOpt.m_iUnitOfInterest)
    for k=1:iNumUnits
        astrctUnits(k).m_iUnitIndex = aiUnitIndices(k);
        astrctUnits(k).m_afTimestamps = fread(hFileID,aiNumSpikes(k),'double=>double');
        astrctUnits(k).m_a2fWaveforms = reshape(fread(hFileID,iWaveFormLength*aiNumSpikes(k),'single=>double'),aiNumSpikes(k),iWaveFormLength);
        astrctUnits(k).m_afInterval = a2fIntervals(k,:);
    end
else
    % Skip directly to the unit of interest....
    
    iEntry = find(aiUnitIndices == strctOpt.m_iUnitOfInterest);
    assert(~isempty(iEntry) && length(iEntry) == 1);
    iNumSpikesBefore = sum(aiNumSpikes(1:iEntry-1));
    % Jump directly to the region of interest....
    fseek(hFileID,13+iHeaderSize +iNumSpikesBefore*(8+iWaveFormLength*4),'bof');
%    astrctUnits.m_iChannel = iChannelOfInterest;
    astrctUnits.m_iUnitIndex = strctOpt.m_iUnitOfInterest;
    astrctUnits.m_afTimestamps = fread(hFileID,aiNumSpikes(iEntry),'double=>double');
    astrctUnits.m_a2fWaveforms = reshape(fread(hFileID,iWaveFormLength*aiNumSpikes(iEntry),'single=>double'),aiNumSpikes(iEntry),iWaveFormLength);
    astrctUnits.m_afInterval = a2fIntervals(iEntry,:);
    if strctOpt.m_bReadInterval
        % Filter out non-relevant spikes...
        abInsideInterval = (astrctUnits.m_afTimestamps >= strctOpt.m_fStartTS & astrctUnits.m_afTimestamps <= strctOpt.m_fEndTS);
        astrctUnits.m_afTimestamps = astrctUnits.m_afTimestamps(abInsideInterval);
        astrctUnits.m_a2fWaveforms = astrctUnits.m_a2fWaveforms(abInsideInterval,:);
    end
end

return;
