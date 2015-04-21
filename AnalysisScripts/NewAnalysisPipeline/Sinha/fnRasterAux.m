function [a2bRaster] = fnRasterAux(afSpikeTimes, afStimulusTime, iBeforeMS, iAfterMS)
%
% Copyright (c) 2011 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

% -200..500 ( for example....)

aiPeriStimulusRangeMS = iBeforeMS:iAfterMS;
iNumTrials = length(afStimulusTime);
a2bRaster = zeros(iNumTrials, length(aiPeriStimulusRangeMS));
for iTrialIter=1:iNumTrials
    aiSpikesInd = find(...
        afSpikeTimes >= afStimulusTime(iTrialIter) + iBeforeMS/1e3 & ...
        afSpikeTimes <= afStimulusTime(iTrialIter) + iAfterMS/1e3);
    
    if ~isempty(aiSpikesInd)
        aiSpikeTimesBins = 1+floor( (afSpikeTimes(aiSpikesInd) - afStimulusTime(iTrialIter) -iBeforeMS/1e3)*1e3);
        aiIncreaseCount = hist(aiSpikeTimesBins, 1:length(aiPeriStimulusRangeMS));
        a2bRaster(iTrialIter, :) = a2bRaster(iTrialIter, :) + aiIncreaseCount;
    end;
end;
return;
