function fnParadigmFiveDotGUI() 
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm g_strctEyeCalib  
    
[hParadigmPanel, iPanelHeight, iPanelWidth] = fnCreateParadigmPanel();
strctControllers.m_hPanel = hParadigmPanel;
strctControllers.m_iPanelHeight = iPanelHeight;
strctControllers.m_iPanelWidth = iPanelWidth;

iNumButtonsInRow = 3;
iButtonWidth = iPanelWidth / iNumButtonsInRow - 20;


strctControllers = fnAddTextSliderEditComboSmall(strctControllers, 40+30*0, ...
    'Fixation Size (pix):', 'FixationSize',  0, 300, [1 5], fnTsGetVar(g_strctParadigm.m_strctStimulusParams,'FixationSizePix'));
strctControllers = fnAddTextSliderEditComboSmall(strctControllers,40+30*1, ...
    'Stimulus ON Time (ms):', 'StimulusON',10, 10000, [1 50], fnTsGetVar(g_strctParadigm.m_strctStimulusParams,'StimulusON_MS'));
strctControllers = fnAddTextSliderEditComboSmall(strctControllers, 40+30*2, ...
    'Spread (pix):', 'Spread', 0, 300, [1 50], fnTsGetVar(g_strctParadigm.m_strctStimulusParams,'SpreadPix'));




strctControllers = fnAddTextSliderEditComboSmall(strctControllers, 40+30*3, ...
    'Eye Gain X:', 'EyeXGain', -3, 3,  [0.1 0.5], fnTsGetVar(g_strctEyeCalib,'GainX'));
strctControllers = fnAddTextSliderEditComboSmall(strctControllers, 40+30*4, ...
    'Eye Gain Y:', 'EyeYGain', -3, 3,  [0.1 0.5], fnTsGetVar(g_strctEyeCalib,'GainY'));




strctControllers = fnAddTextSliderEditComboSmall(strctControllers, 40+30*6, ...
    'Gaze Time(ms):', 'Gaze', 30, 10000, [1, 50], fnTsGetVar(g_strctParadigm,'GazeTimeMS'));
strctControllers = fnAddTextSliderEditComboSmall(strctControllers, 40+30*7, ...
    'Gaze Time (Low):', 'GazeLow',30, 10000, [1, 50], fnTsGetVar(g_strctParadigm,'GazeTimeLowMS'));

strctControllers = fnAddTextSliderEditComboSmall(strctControllers, 40+30*8, ...
    'Gaze area (pix):', 'GazeRect', 0, 300, [1, 50], fnTsGetVar(g_strctParadigm.m_strctStimulusParams,'GazeBoxPix'));
strctControllers = fnAddTextSliderEditComboSmall(strctControllers, 40+30*9, ...
    'Juice Time (ms):', 'Juice',25, 100, [1, 5], fnTsGetVar(g_strctParadigm,'JuiceTimeMS'));
strctControllers = fnAddTextSliderEditComboSmall(strctControllers, 40+30*10, ...
    'Juice Time (High):', 'JuiceHigh',25, 100, [1, 5], fnTsGetVar(g_strctParadigm,'JuiceTimeHighMS'));

strctControllers = fnAddTextSliderEditComboSmall(strctControllers, 40+30*11, ...
    'Blink Time (ms):', 'BlinkTime',0, 500, [1, 50], fnTsGetVar(g_strctParadigm,'BlinkTimeMS'));
strctControllers = fnAddTextSliderEditComboSmall(strctControllers, 40+30*12, ...
    'Positive Increment (%):', 'PositiveInc',5, 100, [1, 5], fnTsGetVar(g_strctParadigm,'PositiveIncrement'));



strctControllers.m_hDiscoButton = uicontrol('Parent',hParadigmPanel,'Style', 'pushbutton', 'String', 'DISCO Button',...
    'Position', [5 iPanelHeight-600 iButtonWidth 40 ], 'Callback', [g_strctParadigm.m_strCallbacks,'(''DrawAttention'');']);

strctControllers.m_hFixationSpotChange = uicontrol('Parent',hParadigmPanel,'Parent',hParadigmPanel,'Style', 'pushbutton', 'String', 'Free Point',...
    'Position',  [iButtonWidth+20 iPanelHeight-600 iButtonWidth 40 ], 'Callback', [g_strctParadigm.m_strCallbacks,'(''FreePoint'');']);

strctControllers.m_hBackgroundButton = uicontrol('Parent',hParadigmPanel,'Parent',hParadigmPanel,'Style', 'pushbutton', 'String', 'Background Color',...
    'Position',  [2*iButtonWidth+40 iPanelHeight-600 iButtonWidth 40 ], 'Callback', [g_strctParadigm.m_strCallbacks,'(''BackgroundColor'');']);

if g_strctParadigm.m_strctStimulusParams.m_bShowEyeTraces
    strFontWeight = 'bold';
else
    strFontWeight = 'normal';
end;

strctControllers.m_hEyeTraceButton = uicontrol('Parent',hParadigmPanel,'Style', 'pushbutton', 'String', 'Eye Trace',...
    'Position', [5 iPanelHeight-550 iButtonWidth 40 ], 'Callback', [g_strctParadigm.m_strCallbacks,'(''EyeTrace'');'],'fontweight',strFontWeight);

g_strctParadigm.m_strctControllers = strctControllers;
return;
