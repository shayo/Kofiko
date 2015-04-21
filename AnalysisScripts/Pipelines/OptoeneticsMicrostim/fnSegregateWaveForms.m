function [aiBefore, aiDuring, aiAfter, afAvgWaveFormBefore,afAvgWaveFormDuring, afAvgWaveFormAfter,...
    afStdWaveFormBefore,afStdWaveFormDuring,afStdWaveFormAfter ] = fnSegregateWaveForms(afTimestamps,a2fWaveForms, afTrainOnsetTS, iBeforeMS, iTrainLengthMS, iAfterMS)
%
% Copyright (c) 2011 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

iNumTrials = length(afTrainOnsetTS);
aiBefore = [];
aiDuring = [];
aiAfter = [];
for iTrialIter=1:iNumTrials
    aiSpikesIndBefore = find(afTimestamps >= afTrainOnsetTS(iTrialIter) + iBeforeMS/1e3 & ...
                                                afTimestamps <= afTrainOnsetTS(iTrialIter));
                                            
    aiSpikesIndDuring  = find(afTimestamps >= afTrainOnsetTS(iTrialIter) & ...
                                                afTimestamps <= afTrainOnsetTS(iTrialIter) + iTrainLengthMS/1e3);

    aiSpikesIndAfter = find(afTimestamps >= afTrainOnsetTS(iTrialIter) + iTrainLengthMS/1e3 &  ...
                                                afTimestamps <= afTrainOnsetTS(iTrialIter) + (iTrainLengthMS+iAfterMS)/1e3);
                                            
    aiBefore = [aiBefore;aiSpikesIndBefore];
    aiDuring = [aiDuring; aiSpikesIndDuring];
    aiAfter = [aiAfter;aiSpikesIndAfter];
end;
afAvgWaveFormBefore = mean(a2fWaveForms(aiBefore,:),1);
afAvgWaveFormDuring = mean(a2fWaveForms(aiDuring,:),1);
afAvgWaveFormAfter = mean(a2fWaveForms(aiAfter,:),1);

afStdWaveFormBefore = std(a2fWaveForms(aiBefore,:),[],1);
afStdWaveFormDuring = std(a2fWaveForms(aiDuring,:),[],1);
afStdWaveFormAfter = std(a2fWaveForms(aiAfter,:),[],1);

return;