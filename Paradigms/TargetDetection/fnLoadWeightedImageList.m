function [ahPTBHandles, a2iImageSize, aiGroup, afWeights, acFileNamesNoPath] = fnLoadWeightedImageList(strImageList)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
global g_strctPTB
[aiGroup, afWeights, acFileNames, acFileNamesNoPath] = fnReadWeightedImageList(strImageList);

iNumImages = length(acFileNames);
ahPTBHandles = zeros(1,iNumImages);

a2iImageSize = zeros(2, iNumImages);
for iFileIter=1:iNumImages
    I = imread(acFileNames{iFileIter});
    a2iImageSize(1,iFileIter) = size(I,2);
    a2iImageSize(2,iFileIter) = size(I,1);    
    ahPTBHandles(iFileIter) = Screen('MakeTexture', g_strctPTB.m_hWindow,  I);
end;

% Load all textures into VRAM
[bSuccess, abInVRAM] = Screen('PreloadTextures', g_strctPTB.m_hWindow);
if (bSuccess)
    fnLog('All textures were loaded to VRAM');
else
    fnLog('Warning, only %d out of %d textures were loaded to VRAM', sum(abInVRAM>0), length(abInVRAM) );
end

return