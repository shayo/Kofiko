function strctStimulusParams = fnParadigmFiveDotStripBuffer()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
global g_strctParadigm

strctStimulusParams.m_afBackgroundColor = ...
squeeze(g_strctParadigm.m_strctStimulusParams.BackgroundColor.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.BackgroundColor.BufferIdx));

strctStimulusParams.m_iCurrStimulusIndex = ...
    g_strctParadigm.m_strctStimulusParams.CurrStimulusIndex.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.CurrStimulusIndex.BufferIdx);

strctStimulusParams.m_fFixationSizePix = ...
    g_strctParadigm.m_strctStimulusParams.FixationSizePix.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.FixationSizePix.BufferIdx);

strctStimulusParams.m_pt2fFixationSpotPix = ...
    g_strctParadigm.m_strctStimulusParams.FixationSpotPix.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.FixationSpotPix.BufferIdx);

strctStimulusParams.m_fSpreadPix = ...
    g_strctParadigm.m_strctStimulusParams.SpreadPix.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.SpreadPix.BufferIdx);

strctStimulusParams.m_fGazeBoxPix = ...
    g_strctParadigm.m_strctStimulusParams.GazeBoxPix.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.GazeBoxPix.BufferIdx);

strctStimulusParams.m_bShowEyeTraces = g_strctParadigm.m_strctStimulusParams.m_bShowEyeTraces;
strctStimulusParams.m_apt2fPreviousFixations = g_strctParadigm.m_strctStimulusParams.m_apt2fPreviousFixations;
strctStimulusParams.m_iPrevFixationIndex = g_strctParadigm.m_strctStimulusParams.m_iPrevFixationIndex;
strctStimulusParams.m_iPrevFixationTimer = g_strctParadigm.m_strctStimulusParams.m_iPrevFixationTimer;
strctStimulusParams.m_iPrevFixationUpdateMS = g_strctParadigm.m_strctStimulusParams.m_iPrevFixationUpdateMS;


return;

