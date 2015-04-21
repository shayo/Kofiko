function [a2bRaster,aiPeriStimulusRangeMS, a2fAvgSpikeForm] = fnRaster(strctUnit, afStimulusTime, iBeforeMS, iAfterMS)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

% -200..500 ( for example....)

aiPeriStimulusRangeMS = iBeforeMS:iAfterMS;
iNumTrials = length(afStimulusTime);
a2bRaster = zeros(iNumTrials, length(aiPeriStimulusRangeMS));
a2fAvgSpikeForm = zeros(iNumTrials, size(strctUnit.m_a2fWaveforms,2));
warning off
for iTrialIter=1:iNumTrials
    aiSpikesInd = find(...
        strctUnit.m_afTimestamps >= afStimulusTime(iTrialIter) + iBeforeMS/1e3 & ...
        strctUnit.m_afTimestamps <= afStimulusTime(iTrialIter) + iAfterMS/1e3);
    
    if ~isempty(aiSpikesInd)
        a2fAvgSpikeForm(iTrialIter,:) = mean(strctUnit.m_a2fWaveforms(aiSpikesInd,:),1);
        aiSpikeTimesBins = 1+floor( (strctUnit.m_afTimestamps(aiSpikesInd) - afStimulusTime(iTrialIter) -iBeforeMS/1e3)*1e3);
        aiIncreaseCount = hist(aiSpikeTimesBins, 1:length(aiPeriStimulusRangeMS));
        a2bRaster(iTrialIter, :) = a2bRaster(iTrialIter, :) + aiIncreaseCount;
        
    end;
end;
%a2bRaster = a2bRaster > 0; % Ignore multiple spikes falling inside same bin ?
return;