function [a2bRaster,aiPeriStimulusRangeMS] = fnRaster4(afTimestamps, afStimulusTime, iBefore, iAfter)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

% -200..500 ( for example....)

aiPeriStimulusRangeMS = iBefore:iAfter;
iNumTrials = length(afStimulusTime);
a2bRaster = zeros(iNumTrials, length(aiPeriStimulusRangeMS));
warning off
for iTrialIter=1:iNumTrials
    aiSpikesInd = find(...
        afTimestamps >= afStimulusTime(iTrialIter) + iBefore & ...
        afTimestamps <= afStimulusTime(iTrialIter) + iAfter);
    
    if ~isempty(aiSpikesInd)
        aiSpikeTimesBins = 1+floor( (afTimestamps(aiSpikesInd) - afStimulusTime(iTrialIter) -iBefore));
        aiIncreaseCount = hist(aiSpikeTimesBins, 1:length(aiPeriStimulusRangeMS));
        a2bRaster(iTrialIter, :) = a2bRaster(iTrialIter, :) + aiIncreaseCount;
        
    end;
end;
%a2bRaster = a2bRaster > 0; % Ignore multiple spikes falling inside same bin ?
return;