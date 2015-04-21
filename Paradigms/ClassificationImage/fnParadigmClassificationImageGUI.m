function fnParadigmClassificationImageGUI()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm g_strctPTB g_handles g_strctStimulusServer g_strctGUIParams


% Note, always add controllers as fields to g_strctParadigm.m_strctControllers
% This way, they are automatically removed once we switch to another
% paradigm

[hParadigmPanel, iPanelHeight, iPanelWidth] = fnCreateParadigmPanel();
strctControllers.m_hPanel = hParadigmPanel;
strctControllers.m_iPanelHeight = iPanelHeight;
strctControllers.m_iPanelWidth = iPanelWidth;

iNumButtonsInRow = 3;
iButtonWidth = iPanelWidth / iNumButtonsInRow - 20;


strctControllers = fnAddTextSliderEditComboSmall(strctControllers, 40+30*0, ...
    'Gaze Time(ms):', 'Gaze', 30, 10000, [1, 50], fnTsGetVar(g_strctParadigm,'GazeTimeMS'));
strctControllers = fnAddTextSliderEditComboSmall(strctControllers, 40+30*1, ...
    'Fixation Size (pix):', 'FixationSize',0, 300, [1, 50], fnTsGetVar(g_strctParadigm.m_strctStimulusParams,'FixationSizePix'));

strctControllers = fnAddTextSliderEditComboSmall(strctControllers, 40+30*2, ...
    'Stimulus ON (ms):', 'StimulusON',g_strctStimulusServer.m_fRefreshRateMS, ...
    500*g_strctStimulusServer.m_fRefreshRateMS, ...
    [g_strctStimulusServer.m_fRefreshRateMS, g_strctStimulusServer.m_fRefreshRateMS*5],...
    fnTsGetVar(g_strctParadigm.m_strctStimulusParams,'StimulusON_MS'));

strctControllers = fnAddTextSliderEditComboSmall(strctControllers, 40+30*3, ...
    'Stimulus OFF (ms):', 'StimulusOFF',g_strctStimulusServer.m_fRefreshRateMS, ...
    500*g_strctStimulusServer.m_fRefreshRateMS, [g_strctStimulusServer.m_fRefreshRateMS, g_strctStimulusServer.m_fRefreshRateMS*5], ...
    fnTsGetVar(g_strctParadigm.m_strctStimulusParams ,'StimulusOFF_MS'));

strctControllers = fnAddTextSliderEditComboSmall(strctControllers,40+30*4, ...
    'Gaze area (pix):', 'GazeRect', 0, 300, [1, 50], fnTsGetVar(g_strctParadigm.m_strctStimulusParams,'GazeBoxPix'));
strctControllers = fnAddTextSliderEditComboSmall(strctControllers, 40+30*5, ...
    'Stimulus size (pix):', 'StimulusSize',0, 700,  [1, 50], fnTsGetVar(g_strctParadigm.m_strctStimulusParams,'StimulusSizePix'));
strctControllers = fnAddTextSliderEditComboSmall(strctControllers, 40+30*6, ...
    'Juice Time (ms):', 'JuiceTime', 25, 100, [1, 5], fnTsGetVar(g_strctParadigm,'JuiceTimeMS'));

strctControllers = fnAddTextSliderEditComboSmall(strctControllers, 40+30*7, ...
    'Rotation Angle (Deg):', 'RotationAngle', -180, 180, [1, 5], fnTsGetVar(g_strctParadigm.m_strctStimulusParams,'RotationAngle'));

strctControllers = fnAddTextSliderEditComboSmall(strctControllers, 40+30*8, ...
    'Noise Level :', 'NoiseLevel', 0, 100, [1, 5], fnTsGetVar(g_strctParadigm.m_strctStimulusParams,'NoiseLevel'));


strctControllers = fnAddTextSliderEditComboSmall(strctControllers, 40+30*9, ...
    'Image Offset X:', 'ImageOffsetX', -100, 100, [1, 5], fnTsGetVar(g_strctParadigm.m_strctStimulusParams,'ImageOffsetX'));
strctControllers = fnAddTextSliderEditComboSmall(strctControllers, 40+30*10, ...
    'Image Offset Y:', 'ImageOffsetY', -100, 100, [1, 5], fnTsGetVar(g_strctParadigm.m_strctStimulusParams,'ImageOffsetY'));
strctControllers = fnAddTextSliderEditComboSmall(strctControllers, 40+30*11, ...
    'Image Size (pix):', 'ImageSizePix', 0, 256, [1, 5], fnTsGetVar(g_strctParadigm.m_strctStimulusParams,'ImageSizePix'));

if g_strctParadigm.m_bRandFixPos
strctControllers.m_hRandomPosition = uicontrol('Parent',hParadigmPanel,'Style', 'pushbutton', 'String', 'Rnd Fix Pos',...
     'Position', [5 iPanelHeight-400 iButtonWidth 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''RandFixationSpot'');'],'FontWeight','bold');
else
strctControllers.m_hRandomPosition = uicontrol('Parent',hParadigmPanel,'Style', 'pushbutton', 'String', 'Rnd Fix Pos',...
     'Position', [5 iPanelHeight-150 iButtonWidth 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''RandFixationSpot'');'],'FontWeight','normal');
end;


strctControllers.m_hNoiseFile = uicontrol('Parent',hParadigmPanel,'Style', 'pushbutton', 'String', 'Noise File',...
     'Position', [125 iPanelHeight-400 iButtonWidth 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''NoiseFile'');']);



strOptions = 'Scan images|Fit neurometric curve|Classification Image';

strctControllers.m_hParadigmMode = uicontrol('Style', 'popup',...
       'String', strOptions,...
       'Position',[150 iPanelHeight-450 2*iButtonWidth-20 30],...
       'Callback', [g_strctParadigm.m_strCallbacks,'(''ChangeParadigmMode'');'],'parent',hParadigmPanel);

strAllImages = '';
for k=1:length(g_strctParadigm.m_acFileNames)
    [strP,strF]=fileparts(g_strctParadigm.m_acFileNames{k});
    strAllImages = [strAllImages,'|',strF];
end;
strctControllers.hImageList = uicontrol('Style', 'listbox', 'String', strAllImages(2:end),...
    'Position', [10 80 130 150], 'parent',hParadigmPanel, 'Callback',[g_strctParadigm.m_strCallbacks,'(''SelectImages'');'],...
    'min', 1,'max',length(strAllImages),'value',g_strctParadigm.m_aiSelectedImageList);


g_strctParadigm.m_strctControllers = strctControllers;
return;
