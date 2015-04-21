function bSuccessful = fnParadigmDefaultInit()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm  g_strctPTB
g_strctParadigm.m_fStartTime = GetSecs;
g_strctParadigm.m_strctStimulusParams.m_iCurrStimulusIndex = 0;
g_strctParadigm.m_iMachineState = 0;
g_strctParadigm.m_iJuiceTimeMS = 0;


g_strctParadigm.m_fJuiceDrainTimeSec = 90;
g_strctParadigm.m_fJuiceDrainTimer = 0;
g_strctParadigm.m_strctStimulusParams.m_fTimeDisplay = 0;
g_strctParadigm.m_a3fKofikoLogo = imread('KofikoLogo.jpg');

g_strctParadigm.m_hTexture = Screen('MakeTexture', g_strctPTB.m_hWindow,  g_strctParadigm.m_a3fKofikoLogo);

g_strctParadigm.m_strState = 'Doing Nothing';
bSuccessful = true;

return;
