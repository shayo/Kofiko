function [a2fAvg, a2fStd, aiCount] = fnAverageBy(a2bRaster, aiStimulusIndex, a2bStimulusCategory, iAvgLen, bGaussian)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)


iNumStimuli = size(a2bStimulusCategory,1);
iNumCategories = size(a2bStimulusCategory,2);
iRaster_Length = size(a2bRaster,2);

a2fAvg = zeros(iNumCategories, iRaster_Length);
% a2fStd = zeros(iNumCategories, iRaster_Length);
aiCount = zeros(1,iNumCategories);
for iIter=1:length(aiStimulusIndex)
    % Find which categories this stimulus belongs to
    aiCat = find(a2bStimulusCategory(aiStimulusIndex(iIter),:));
    % Add the Raster to matched categories
    abResponse = double(a2bRaster(iIter,:));
    bNaN = sum(isnan(abResponse)) > 0;
    if ~bNaN
        a2fAvg(aiCat,:) = a2fAvg(aiCat,:) + repmat(abResponse , length(aiCat),1);
        aiCount(aiCat) = aiCount(aiCat) + 1;
    end
end;
% Average trials
a2fAvg(aiCount>0,:) = a2fAvg(aiCount>0,:) ./ repmat(aiCount(aiCount>0)', 1, iRaster_Length);
a2fAvg(aiCount==0,:) = NaN;

% Estimate standard deviation for each time point on the Raster
a2fStd = zeros(iNumCategories, iRaster_Length);
for iIter=1:length(aiStimulusIndex)
    % Find which categories this stimulus belongs to
    aiCat = find(a2bStimulusCategory(aiStimulusIndex(iIter),:));
    % Add the Raster to matched categories
    a2fStd(aiCat,:) = a2fStd(aiCat,:) + (repmat( double(a2bRaster(iIter,:)), length(aiCat),1) - a2fAvg(aiCat,:)).^2;
end;
% Average trials
a2fStd(aiCount>1,:) = sqrt(  a2fStd(aiCount>1,:) ./ (repmat(aiCount(aiCount>1)', 1, iRaster_Length)-1) );
a2fStd(aiCount<=1,:) = NaN;

if ~exist('bGaussian','var')
    bGaussian = false;
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
