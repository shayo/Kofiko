function fnParadigmForcedChoiceGUI() 
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm   
    
[hParadigmPanel, iPanelHeight, iPanelWidth] = fnCreateParadigmPanel();
strctControllers.m_hPanel = hParadigmPanel;
strctControllers.m_iPanelHeight = iPanelHeight;
strctControllers.m_iPanelWidth = iPanelWidth;

strctControllers = fnAddTextSliderEditComboSmallWithCallback(strctControllers, 40+30*0, ...
     'Juice Pulse (ms):', 'JuiceTimeMS',  0, 100, [1 5], fnTsGetVar(g_strctParadigm,'JuiceTimeMS'));

 strctControllers = fnAddTextSliderEditComboSmallWithCallback(strctControllers, 60+30*2, ...
     'ITI minimum (sec):', 'InterTrialIntervalMinSec',  0, 60, [1 5], fnTsGetVar(g_strctParadigm,'InterTrialIntervalMinSec'));
strctControllers = fnAddTextSliderEditComboSmallWithCallback(strctControllers, 60+30*3, ...
     'ITI maximum (sec):', 'InterTrialIntervalMaxSec',  0, 60, [1 5], fnTsGetVar(g_strctParadigm,'InterTrialIntervalMaxSec'));

strctControllers = fnAddTextSliderEditComboSmallWithCallback(strctControllers, 60+30*4, ...
     'Hold To Start(ms):', 'HoldFixationToStartTrialMS',  0, 100, [1 5], fnTsGetVar(g_strctParadigm,'HoldFixationToStartTrialMS'));

strctControllers = fnAddTextSliderEditComboSmallWithCallback(strctControllers, 60+30*5, ...
     'Delay Before Choice (ms):', 'DelayBeforeChoicesMS',  0, 1000, [1 5], fnTsGetVar(g_strctParadigm,'DelayBeforeChoicesMS'));
 
strctControllers = fnAddTextSliderEditComboSmallWithCallback(strctControllers, 60+30*6, ...
     'Memory Interval (ms):', 'MemoryIntervalMS',  0, 1000, [1 5], fnTsGetVar(g_strctParadigm,'MemoryIntervalMS'));
 
 
 strctControllers = fnAddTextSliderEditComboSmallWithCallback(strctControllers, 60+30*7, ...
     'Trial Timeout (ms):', 'TimeoutMS',  0, 4000, [1 5], fnTsGetVar(g_strctParadigm,'TimeoutMS'));

  strctControllers = fnAddTextSliderEditComboSmallWithCallback(strctControllers, 60+30*8, ...
     'Incorrect Delay (ms):', 'IncorrectTrialDelayMS',  0, 2000, [1 5], fnTsGetVar(g_strctParadigm,'IncorrectTrialDelayMS'));

   strctControllers = fnAddTextSliderEditComboSmallWithCallback(strctControllers, 60+30*9, ...
     'Persist Objects (ms):', 'ShowObjectsAfterSaccadeMS',  0, 3000, [1 5], fnTsGetVar(g_strctParadigm,'ShowObjectsAfterSaccadeMS'));

 strctControllers = fnAddTextSliderEditComboSmallWithCallback(strctControllers, 80+30*10, ...
     'Fixation Radius (pix):', 'FixationRadiusPix',  0, 100, [1 5], fnTsGetVar(g_strctParadigm,'FixationRadiusPix'));
strctControllers = fnAddTextSliderEditComboSmallWithCallback(strctControllers, 80+30*11, ...
     'Target Hit Radius (pix):', 'HitRadius',  0, 100, [1 5], fnTsGetVar(g_strctParadigm,'HitRadius'));
  
strctControllers = fnAddTextSliderEditComboSmallWithCallback(strctControllers, 80+30*12, ...
     'Image Size (pix):', 'ImageHalfSizePix',  0, 100, [1 5], fnTsGetVar(g_strctParadigm,'ImageHalfSizePix'));

strctControllers = fnAddTextSliderEditComboSmallWithCallback(strctControllers, 80+30*13, ...
     'Choices Size (pix):', 'ChoicesHalfSizePix',  0, 100, [1 5], fnTsGetVar(g_strctParadigm,'ChoicesHalfSizePix'));
 
 

if ~isempty(g_strctParadigm.m_strctNoise)
    iMaxNoiseIndex = size(g_strctParadigm.m_strctNoise.a2fRand,3);
else
    iMaxNoiseIndex = 1;
end

strctControllers = fnAddTextSliderEditComboSmallWithCallback(strctControllers, 80+30*14, ...
     'Noise Index:', 'NoiseIndex',  1, iMaxNoiseIndex, [1 5], fnTsGetVar(g_strctParadigm,'NoiseIndex'));
 
strctControllers = fnAddTextSliderEditComboSmallWithCallback(strctControllers, 80+30*15, ...
     'Noise Level (%):', 'NoiseLevel',  0, 100, [1 5], fnTsGetVar(g_strctParadigm,'NoiseLevel'));
 
 
strctControllers = fnAddTextSliderEditComboSmallWithCallback(strctControllers, 80+30*16, ...
     'Staircase Up:', 'StairCaseUp',  1, 5, [1 1], fnTsGetVar(g_strctParadigm,'StairCaseUp'));
 
strctControllers = fnAddTextSliderEditComboSmallWithCallback(strctControllers, 80+30*17, ...
     'Staircase Down:', 'StairCaseDown',  1, 5, [1 1], fnTsGetVar(g_strctParadigm,'StairCaseDown'));
 
strctControllers = fnAddTextSliderEditComboSmallWithCallback(strctControllers, 80+30*18, ...
     'Staircase Step (%):', 'StairCaseStepPerc',  0, 100, [1 5], fnTsGetVar(g_strctParadigm,'StairCaseStepPerc'));
 
strctControllers.m_hLoadNoiseFile = uicontrol('Parent',hParadigmPanel,'Style', 'pushbutton', 'String', 'Load Noise File',...
     'Position', [5 iPanelHeight-660 130 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''LoadNoiseFile'');']);
 
 
strctControllers.m_hResetStat = uicontrol('Parent',hParadigmPanel,'Style', 'pushbutton', 'String', 'Reset Stat',...
     'Position', [160 iPanelHeight-660 130 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''ResetStat'');']);
 
 
 strctControllers.m_hLoadDesign = uicontrol('Parent',hParadigmPanel,'Style', 'pushbutton', 'String', 'Load Design',...
     'Position', [5 iPanelHeight-80 130 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''LoadDesign'');']);
 
 
 strctControllers.m_hMouseEmulator = uicontrol('Style','checkbox','String','Mouse Emulator',...
     'Position',[10 100 200 15],'HorizontalAlignment','Left','Parent',...
    hParadigmPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''ToggleEmulator'');'],'value',...
      g_strctParadigm.m_bEmulatorON );

 strctControllers.m_hExtinguish = uicontrol('Style','checkbox','String','Extinguish Objects After Saccade',...
     'Position',[10 80 200 15],'HorizontalAlignment','Left','Parent',...
    hParadigmPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''ToggleExtinguish'');'],'value',...
      g_strctParadigm.m_bExtinguishObjectsAfterSaccade );

 
 

  strctControllers.m_hFavroiteLists = uicontrol('Style', 'listbox', 'String', fnCellToCharShort(g_strctParadigm.m_acFavroiteLists),...
    'Position', [strctControllers.m_iPanelWidth-180 10 170 100], 'parent',hParadigmPanel, 'Callback',[g_strctParadigm.m_strCallbacks,'(''LoadFavoriteList'');'],...
    'value',max(1,g_strctParadigm.m_iInitialIndexInFavroiteList));









g_strctParadigm.m_strctControllers = strctControllers;
return;
