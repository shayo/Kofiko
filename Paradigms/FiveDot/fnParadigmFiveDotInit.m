function bSuccessful = fnParadigmFiveDotInit()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm g_strctStimulusServer 

g_strctParadigm.m_fStartTime = GetSecs;

% Default initializations...
g_strctParadigm.m_iMachineState = 0; % Always initialize first state to zero.

g_strctParadigm.m_bUpdateFixationSpot = false;
g_strctParadigm.m_fMouseTimer = 0;
iSmallBuffer = 500;
% Finite State Machine related parameters
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'JuiceTimeMS', g_strctParadigm.m_fInitial_JuiceTimeMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'JuiceTimeHighMS', g_strctParadigm.m_fInitial_JuiceTimeHighMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'GazeTimeMS', g_strctParadigm.m_fInitial_GazeTimeMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'GazeTimeLowMS', g_strctParadigm.m_fInitial_GazeTimeLowMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'BlinkTimeMS', g_strctParadigm.m_fInitial_BlinkTimeMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'PositiveIncrement', g_strctParadigm.m_fInitial_PositiveIncrementPercent, iSmallBuffer);

g_strctParadigm.m_fInsideGazeRectTimer = 0; 

% Stimulus related parameters. These will be sent to the stimulus server,
% so make sure all required stimulus parameters (that can change) are
% represented in this structure.

iBufferLen = 30000;
strctStimulusParams = fnTsAddVar([], 'FixationSpotPix', g_strctStimulusServer.m_aiScreenSize(3:4)/2, iBufferLen);
strctStimulusParams = fnTsAddVar(strctStimulusParams, 'FixationSizePix', g_strctParadigm.m_fInitial_FixationSizePix, 100);
strctStimulusParams = fnTsAddVar(strctStimulusParams, 'SpreadPix', g_strctParadigm.m_fInitial_SpreadPix, 100);
strctStimulusParams = fnTsAddVar(strctStimulusParams, 'GazeBoxPix', g_strctParadigm.m_fInitial_GazeBoxPix, 100);
strctStimulusParams = fnTsAddVar(strctStimulusParams, 'BackgroundColor', g_strctParadigm.m_afInitial_BackgroundColor, 100);
strctStimulusParams = fnTsAddVar(strctStimulusParams, 'StimulusON_MS', g_strctParadigm.m_fInitial_StimulusON_MS, iSmallBuffer);
 
strctStimulusParams.m_bShowEyeTraces = 1;

% Initialize Dynamic Juice Reward System
g_strctParadigm.m_strctDynamicJuice.m_fTotalFixationTime = 0;
g_strctParadigm.m_strctDynamicJuice.m_fTotalNonFixationTime = 0;
g_strctParadigm.m_strctDynamicJuice.m_iState = 1;
g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = 0;

%g_strctParadigm.m_afCorrectTrial = [];
g_strctParadigm.m_strctStimulusParams = strctStimulusParams;


g_strctParadigm.m_strState = 'Doing Nothing';
bSuccessful = true;
return;



