function [a2fAvg] = fnAverageByCell(a2bRaster, aiStimulusIndex,  acConditionInd, iAvgLen, bGaussian)
%
% Copyright (c) 2011 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)


iNumConditions = length(acConditionInd);
iRaster_Length = size(a2bRaster,2);

a2fAvg = NaN*ones(iNumConditions, iRaster_Length);

for iConditionIter=1:iNumConditions
    aiRelevantRasterInd = find(ismember(aiStimulusIndex, acConditionInd{iConditionIter}));
    if ~isempty(aiRelevantRasterInd)
        a2fAvg(iConditionIter,:) = mean(a2bRaster(aiRelevantRasterInd,:),1);
    end
end

% Average time
if iAvgLen > 0
    if bGaussian
        afSmoothingKernelMS = fspecial('gaussian',[1 7*iAvgLen],iAvgLen);
    else
        afSmoothingKernelMS = ones(1,iAvgLen)/iAvgLen;
    end
    a2fAvg = conv2(a2fAvg,afSmoothingKernelMS ,'same');
end;

return;
