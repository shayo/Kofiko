function a2fSurrogateSpikes = fnGenerateSurrogateShuffleTrains(afSpikes, fBlockLengthMS, iNumSurrogate) 
iNumSpikes = length(afSpikes);
fStart = afSpikes(1);
fEnd = afSpikes(end);
fLenSec = fEnd-fStart;
fLenMS = ceil(fLenSec*1e3);

%fBlockLengthMS = 1000;

iMaxNumBlocks = floor(fLenMS/fBlockLengthMS);

afBlockOnset = linspace(fStart, fEnd, iMaxNumBlocks);
% Generate a single surrogate spike train by shuffling....

% First, represent spikes in each block relative to block onset
acRelativeSpikes = cell(1,iMaxNumBlocks-1);
for iBlockIter=1:iMaxNumBlocks-1
    aiSpikeInd = find( afSpikes >= afBlockOnset(iBlockIter) & afSpikes <= afBlockOnset(iBlockIter+1));
    acRelativeSpikes{iBlockIter} = afSpikes(aiSpikeInd) - afBlockOnset(iBlockIter);
end


a2fSurrogateSpikes = zeros(iNumSurrogate, iNumSpikes);
for iSurrogateIter=1:iNumSurrogate
    aiRandPerm = randperm(iMaxNumBlocks-1);
    % Build the new spike train...
    afNewSpikes = NaN*ones(1,iNumSpikes);
    iCounter = 1;
    for iBlockIter=1:iMaxNumBlocks-1
        iSelectedBlock = aiRandPerm(iBlockIter);
        afRelativeSpikes = acRelativeSpikes{iSelectedBlock};
        iNumSpikesInBlock = length(afRelativeSpikes);
        afNewSpikes(iCounter:iCounter+iNumSpikesInBlock-1) = afRelativeSpikes + afBlockOnset(iBlockIter);
        iCounter=iCounter+iNumSpikesInBlock;
    end
    a2fSurrogateSpikes(iSurrogateIter,:) = afNewSpikes;
end

%all(afNewSpikes == sort(afNewSpikes))

return;

