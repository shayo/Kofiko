function [ahTextures,a2iTextureSize,abIsMovie,aiApproxNumFrames, afMovieLengthSec,acImages] = fnInitializeTexturesAuxPing(acFileNames)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctPTB 
iNumImages = length(acFileNames);

ahTextures = zeros(1,iNumImages);
a2iTextureSize = zeros(2,iNumImages); %[x;y]
abIsMovie = zeros(1,iNumImages) > 0;
aiApproxNumFrames = zeros(1,iNumImages);
afMovieLengthSec= zeros(1,iNumImages);
acImages = cell(1,iNumImages);
for iFileIter=1:iNumImages
    abIsMovie(iFileIter) = fnIsMovie(acFileNames{iFileIter});
    if abIsMovie(iFileIter) 
        % Load movie
       [hMovie,fDuration,fFramesPerSeconds,iWidth,iHeight]=Screen('OpenMovie', g_strctPTB.m_hWindow, acFileNames{iFileIter});
       aiApproxNumFrames(iFileIter) = ceil(fDuration*fFramesPerSeconds);
       afMovieLengthSec(iFileIter) = fDuration;
       ahTextures(iFileIter) = hMovie;
       a2iTextureSize(1,iFileIter) = iWidth;
       a2iTextureSize(2,iFileIter) = iHeight;
    else
        % Image
        [I,C] = imread(acFileNames{iFileIter});
        if strcmp(class(I),'uint16')
            % Rescale to uint8
            warning off;
            I = uint8(double(I) / 65535 * 255);
            warning on;
        end
        
        
        if g_strctPTB.m_bNonRectMakeTexture == false
            I = imresize(I,[128 128],'bilinear');
        end
        
        acImages{iFileIter} = I;
        a2iTextureSize(1,iFileIter) = size(I,2);
        a2iTextureSize(2,iFileIter) = size(I,1);
        ahTextures(iFileIter) = Screen('MakeTexture', g_strctPTB.m_hWindow,  I);
    end
    
    fnStimulusServerToKofikoParadigm('LoadedImage',iFileIter );
end;
% Load all textures into VRAM
[bSuccess, abInVRAM] = Screen('PreloadTextures', g_strctPTB.m_hWindow);
if (bSuccess)
    fnLog('All textures were loaded to VRAM');
else
    fnLog('Warning, only %d out of %d textures were loaded to VRAM', sum(abInVRAM>0), length(abInVRAM) );
end

if g_strctPTB.m_bNonRectMakeTexture == false
    fnParadigmToKofikoComm('DisplayMessage','WARNING. Images rescaled. Non nViDIA Card!');
end

return

function bMovie = fnIsMovie(strFileName)
[strPath,strFile,strExt]=fileparts(strFileName);
bMovie = strcmpi(strExt,'.mov') || strcmpi(strExt,'.avi') || strcmpi(strExt,'.mp4') ;
return;
