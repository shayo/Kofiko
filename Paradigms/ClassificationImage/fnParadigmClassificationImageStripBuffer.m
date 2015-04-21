function strctStimulusParams = fnParadigmClassificationImageStripBuffer()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
global g_strctParadigm

strctStimulusParams.m_iPhotoDiodeWindowPix = ...
    g_strctParadigm.m_strctStimulusParams.m_iPhotoDiodeWindowPix;

strctStimulusParams.m_afBackgroundColor = ...
squeeze(g_strctParadigm.m_strctStimulusParams.BackgroundColor.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.BackgroundColor.BufferIdx));

strctStimulusParams.m_fFixationSizePix = ...
    g_strctParadigm.m_strctStimulusParams.FixationSizePix.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.FixationSizePix.BufferIdx);

strctStimulusParams.m_pt2fFixationSpotPix = ...
    g_strctParadigm.m_strctStimulusParams.FixationSpotPix.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.FixationSpotPix.BufferIdx);

strctStimulusParams.m_fGazeBoxPix = ...
    g_strctParadigm.m_strctStimulusParams.GazeBoxPix.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.GazeBoxPix.BufferIdx);

strctStimulusParams.m_pt2fStimulusPos = ...
    g_strctParadigm.m_strctStimulusParams.StimulusPos.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.StimulusPos.BufferIdx);

strctStimulusParams.m_fStimulusSizePix = ...
    g_strctParadigm.m_strctStimulusParams.StimulusSizePix.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.StimulusSizePix.BufferIdx);

strctStimulusParams.m_fStimulusON_MS = ...
    g_strctParadigm.m_strctStimulusParams.StimulusON_MS.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.StimulusON_MS.BufferIdx);

strctStimulusParams.m_fStimulusOFF_MS = ...
    g_strctParadigm.m_strctStimulusParams.StimulusOFF_MS.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.StimulusOFF_MS.BufferIdx);

%strctStimulusParams.m_strImageList = ...
%    g_strctParadigm.m_strctStimulusParams.ImageList.Buffer{g_strctParadigm.m_strctStimulusParams.ImageList.BufferIdx};

strctStimulusParams.m_fRotationAngle = ...
    g_strctParadigm.m_strctStimulusParams.RotationAngle.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.RotationAngle.BufferIdx);

strctStimulusParams.m_fNoiseLevel = ...
    g_strctParadigm.m_strctStimulusParams.NoiseLevel.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.NoiseLevel.BufferIdx);

strctStimulusParams.m_iCurrNoiseIndex = ...
    g_strctParadigm.m_strctStimulusParams.CurrNoiseIndex.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.CurrNoiseIndex.BufferIdx);

strctStimulusParams.m_iImageSizePix = ...
    g_strctParadigm.m_strctStimulusParams.ImageSizePix.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.ImageSizePix.BufferIdx);

strctStimulusParams.m_iImageOffsetX = ...
    g_strctParadigm.m_strctStimulusParams.ImageOffsetX.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.ImageOffsetX.BufferIdx);

strctStimulusParams.m_iImageOffsetY = ...
    g_strctParadigm.m_strctStimulusParams.ImageOffsetY.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.ImageOffsetY.BufferIdx);

return;

