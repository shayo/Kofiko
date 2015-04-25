function fnParadigmPassiveFixationGUINew()
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


[strctDesignControllers.m_hPanel, strctDesignControllers.m_iPanelHeight,strctDesignControllers.m_iPanelWidth] = ...
    fnCreateParadigmSubPanel(hParadigmPanel,50,iPanelHeight-5,'Design');


[strctStimulusControllers.m_hPanel, strctStimulusControllers.m_iPanelHeight,strctStimulusControllers.m_iPanelWidth] = ...
    fnCreateParadigmSubPanel(hParadigmPanel,50,iPanelHeight-5,'Stimulus Parameters');


[strctJuiceControllers.m_hPanel, strctJuiceControllers.m_iPanelHeight,strctJuiceControllers.m_iPanelWidth] = ...
    fnCreateParadigmSubPanel(hParadigmPanel,50,iPanelHeight-5,'Juice Parameters');


[strctMicroStimControllers.m_hPanel, strctMicroStimControllers.m_iPanelHeight,strctMicroStimControllers.m_iPanelWidth] = ...
    fnCreateParadigmSubPanel(hParadigmPanel,50,iPanelHeight-5,'Microstim Parameters');


strctControllers.m_hSubPanels = [strctDesignControllers.m_hPanel;strctStimulusControllers.m_hPanel;strctJuiceControllers.m_hPanel;strctMicroStimControllers.m_hPanel];

 strctControllers.m_hSetSDesignPanel = uicontrol('Parent',hParadigmPanel, 'Style', 'pushbutton', 'String', 'Design',...
      'Position', [5 iPanelHeight-40 50 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''DesignPanel'');']);

 strctControllers.m_hSetStimulusPanel = uicontrol('Parent',hParadigmPanel, 'Style', 'pushbutton', 'String', 'Stimulus',...
      'Position', [60 iPanelHeight-40 50 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''StimulusPanel'');']);
    
 strctControllers.m_hSetJuicePanel = uicontrol('Parent',hParadigmPanel, 'Style', 'pushbutton', 'String', 'Juice',...
      'Position', [110+5 iPanelHeight-40 50 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''JuicePanel'');']);

 strctControllers.m_hSetMicrostimPanel = uicontrol('Parent',hParadigmPanel, 'Style', 'pushbutton', 'String', 'Microstim',...
      'Position', [165 iPanelHeight-40 55 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''MicrostimPanel'');']);
  
  %% Juice Controllers
strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctJuiceControllers.m_hPanel, 40+30*0, ...
    'Gaze Time(ms):', 'GazeTimeMS',30, 10000, [1, 50], fnTsGetVar('g_strctParadigm','GazeTimeMS'));

strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctJuiceControllers.m_hPanel, 40+30*1, ...
    'Gaze Time (Low):', 'GazeTimeLowMS', 30, 10000, [1, 50], fnTsGetVar('g_strctParadigm','GazeTimeLowMS'));

strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers, strctJuiceControllers.m_hPanel,40+30*2, ...
    'Gaze area (pix):', 'GazeBoxPix', 0, 300, [1, 50], fnTsGetVar('g_strctParadigm','GazeBoxPix'));

strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctJuiceControllers.m_hPanel, 40+30*3, ...
    'Juice Time (ms):', 'JuiceTimeMS',25, 100, [1, 5], fnTsGetVar('g_strctParadigm','JuiceTimeMS'));

strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctJuiceControllers.m_hPanel, 40+30*4, ...
    'Juice Time (High):', 'JuiceTimeHighMS', 25, 100, [1, 5], fnTsGetVar('g_strctParadigm','JuiceTimeHighMS'));

strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctJuiceControllers.m_hPanel, 40+30*5, ...
    'Blink Time (ms):', 'BlinkTimeMS', 10, 500, [1, 50], fnTsGetVar('g_strctParadigm','BlinkTimeMS'));

strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers, strctJuiceControllers.m_hPanel,40+30*6, ...
    'Positive Increment (%):', 'PositiveIncrement', 0, 100, [1, 5], fnTsGetVar('g_strctParadigm','PositiveIncrement'));


  
set(strctJuiceControllers.m_hPanel,'visible','off');
%% Stimulus Controllers
strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctStimulusControllers.m_hPanel, 40+30*0, ...
    'Fixation Size (pix):', 'FixationSizePix',0, 300, [1, 50], fnTsGetVar('g_strctParadigm','FixationSizePix'));

strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctStimulusControllers.m_hPanel, 40+30*1, ...
    'Stimulus ON Time (ms):', 'StimulusON_MS',g_strctStimulusServer.m_fRefreshRateMS, ...
    500*g_strctStimulusServer.m_fRefreshRateMS, ...
    [g_strctStimulusServer.m_fRefreshRateMS, g_strctStimulusServer.m_fRefreshRateMS*5],...
    fnTsGetVar('g_strctParadigm','StimulusON_MS'));

strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctStimulusControllers.m_hPanel, 40+30*2, ...
    'Stimulus OFF Time (ms):', 'StimulusOFF_MS',g_strctStimulusServer.m_fRefreshRateMS, ...
    500*g_strctStimulusServer.m_fRefreshRateMS, [g_strctStimulusServer.m_fRefreshRateMS, g_strctStimulusServer.m_fRefreshRateMS*5], ...
    fnTsGetVar('g_strctParadigm' ,'StimulusOFF_MS'));

strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctStimulusControllers.m_hPanel, 40+30*3, ...
    'Stimulus size (pix):', 'StimulusSizePix',0, 700,  [1, 50], fnTsGetVar('g_strctParadigm','StimulusSizePix'));

strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctStimulusControllers.m_hPanel, 40+30*4, ...
    'Rotation Angle (Deg):', 'RotationAngle', -180, 180, [1, 5], fnTsGetVar('g_strctParadigm','RotationAngle'));


 strctControllers.m_hSetNewBackground = uicontrol('Parent',strctStimulusControllers.m_hPanel,'Style', 'pushbutton', 'String', 'Back Color',...
     'Position', [2*iButtonWidth+40 iPanelHeight-250 iButtonWidth 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''BackgroundColor'');']);


strctControllers.m_hFixationSpotChange = uicontrol('Parent',strctStimulusControllers.m_hPanel,'Style', 'pushbutton', 'String', 'Free Fix Pos',...
     'Position',  [iButtonWidth+20 iPanelHeight-250 iButtonWidth 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''FixationSpot'');']);

strctControllers.m_hStimulusPosChange = uicontrol('Parent',strctStimulusControllers.m_hPanel,'Style', 'pushbutton', 'String', 'Free Stimulus Pos',...
     'Position', [5 iPanelHeight-250 iButtonWidth 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''StimulusPos'');']);

 
 set(strctStimulusControllers.m_hPanel,'visible','off');
%% Design options
 strctControllers.hImageListContextMenu = uicontextmenu;
uimenu(strctControllers.hImageListContextMenu, 'Label', 'Load List', 'Callback', [g_strctParadigm.m_strCallbacks,'(''LoadList'');']);


strctControllers.m_hFavroiteLists = uicontrol('Style', 'listbox', 'String', fnCellToCharShort(g_strctParadigm.m_acFavroiteLists),...
    'Position', [5 iPanelHeight-200 ,strctDesignControllers.m_iPanelWidth-10 120], 'parent',strctDesignControllers.m_hPanel, 'Callback',[g_strctParadigm.m_strCallbacks,'(''LoadFavoriteList'');'],...
    'value',max(1,g_strctParadigm.m_iInitialIndexInFavroiteList),'UIContextMenu',strctControllers.hImageListContextMenu);

strctControllers.m_hBlockText= uicontrol('Style', 'text', 'String', 'Stimuli Blocks:',...
    'Position', [5 iPanelHeight-225 ,130 15], 'parent',strctDesignControllers.m_hPanel,'HorizontalAlignment','left');


if ~isempty(g_strctParadigm.m_strctDesign)
    acBlockNames = {g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlocks.m_strBlockName};
    acBlockNames = acBlockNames(g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder(1).m_aiBlockIndexOrder);
else
    acBlockNames = {};
end

if ~isempty(g_strctParadigm.m_strctDesign)
    acOrderNames = {g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder.m_strOrderName};
else
    acOrderNames = {};
end

 strctControllers.m_hBlockOrderPopup = uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'popupmenu', 'String', ...
     acOrderNames,'value', 1,...
     'Position', [90 iPanelHeight-265 160 60], 'Callback', [g_strctParadigm.m_strCallbacks,'(''ChangeBlockOrder'');']);



strctControllers.m_hBlockLists = uicontrol('Style', 'listbox', 'String', acBlockNames,...
    'Position', [5 iPanelHeight-330 ,strctDesignControllers.m_iPanelWidth-10 100], 'parent',strctDesignControllers.m_hPanel, 'Callback',[g_strctParadigm.m_strCallbacks,'(''JumpToBlock'');'],...
    'value',1);



if g_strctParadigm.m_bRandFixPos
strctControllers.m_hRandomPosition = uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'pushbutton', 'String', 'Rnd Fix Pos',...
     'Position', [5 iPanelHeight-365 iButtonWidth 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''RandFixationSpot'');'],'FontWeight','bold');
else
strctControllers.m_hRandomPosition = uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'pushbutton', 'String', 'Rnd Fix Pos',...
     'Position', [5 iPanelHeight-365 iButtonWidth 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''RandFixationSpot'');'],'FontWeight','normal');
end;
 
strctControllers.m_hRandomPositionMinEdit = uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'edit', 'String', num2str(g_strctParadigm.m_fRandFixPosMin),...
     'Position', [iButtonWidth+15 iPanelHeight-365 25 20], 'Callback', [g_strctParadigm.m_strCallbacks,'(''RandFixationSpotMinEdit'');']);

strctControllers.m_hRandomPositionMaxEdit = uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'edit', 'String', num2str(g_strctParadigm.m_fRandFixPosMax),...
     'Position', [iButtonWidth+50 iPanelHeight-365 25 20], 'Callback', [g_strctParadigm.m_strCallbacks,'(''RandFixationSpotMaxEdit'');']);

strctControllers.m_hRandomPositionRadiusEdit = uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'edit', 'String', num2str(g_strctParadigm.m_fRandFixRadius),...
     'Position', [iButtonWidth+90 iPanelHeight-365 25 20], 'Callback', [g_strctParadigm.m_strCallbacks,'(''RandFixationSpotRadiusEdit'');']);



 iOffset = 400;
strctControllers.m_hRandomPositionRadiusEditCheck = uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'checkbox', 'String', 'Sync To Stimulus','value',g_strctParadigm.m_bRandFixSyncStimulus,...
     'Position', [5 iPanelHeight-iOffset 120 20], 'Callback', [g_strctParadigm.m_strCallbacks,'(''RandFixationSync'');']);

strctControllers.m_hHideWhenNotLooking = uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'checkbox', 'String', 'Do not display images when monkey is not looking','value', g_strctParadigm.m_bHideStimulusWhenNotLooking,...
     'Position', [5 iPanelHeight-iOffset-20 280 20], 'Callback', [g_strctParadigm.m_strCallbacks,'(''HideNotLookingToggle'');']);
 
strctControllers.m_hPhotoDiodeRect = uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'checkbox', 'String', 'Photodiode Rect','value', g_strctParadigm.m_bShowPhotodiodeRect,...
     'Position', [5 iPanelHeight-iOffset-40 220 20], 'Callback', [g_strctParadigm.m_strCallbacks,'(''PhotoDiodeRectToggle'');']);

strctControllers.m_hRandomImageIndex = uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'checkbox', 'String', 'Randomize Order','value', g_strctParadigm.m_bRandom,...
     'Position', [5 iPanelHeight-iOffset-60 220 20], 'Callback', [g_strctParadigm.m_strCallbacks,'(''Random'');']);

strctControllers.m_hParameterSweep = uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'checkbox', 'String', 'Parameter Sweep','value', g_strctParadigm.m_bParameterSweep,...
     'Position', [5 iPanelHeight-iOffset-80 220 20], 'Callback', [g_strctParadigm.m_strCallbacks,'(''ParameterSweep'');']);
 
 % changelog 10/21/13 josh - adding 'fit to screen' button to GUI panel -------------------------------
 
 
 strctControllers.m_hFitToScreen = uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'checkbox', 'String', 'Fit stimulus to server-screen','value', g_strctParadigm.m_bFitToScreen,...
     'Position', [5 iPanelHeight-iOffset-100 220 20], 'Callback', [g_strctParadigm.m_strCallbacks,'(''FitToScreen'');']);
 
 
 % end changelog --------------------------------------------------------------------------------------
 
 if ~isempty(g_strctParadigm.m_acNoisePatternsFiles)
     strctControllers.m_hNoiseOverlay = uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'checkbox', 'String', 'Noise Overlay','value', ...
         fnTsGetVar('g_strctParadigm','NoiseOverlayActive'),...
         'Position', [5 iPanelHeight-iOffset-100 220 20], 'Callback', [g_strctParadigm.m_strCallbacks,'(''NoiseOverlayToggle'');']);
     strctControllers.m_hNoisePatternPopup = uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'popupmenu', 'String', ...
         g_strctParadigm.m_acNoisePatternsFiles,'value', 1,...
         'Position', [130 iPanelHeight-iOffset-140 160 60], 'Callback', [g_strctParadigm.m_strCallbacks,'(''NoisePatternSwitch'');']);
end
 

strctControllers.m_hParameterSweepPopup = uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'popupmenu', 'String', ...
    {g_strctParadigm.m_astrctParameterSweepModes.m_strName},'value', 1,...
     'Position', [130 iPanelHeight-iOffset-115 160 60], 'Callback', [g_strctParadigm.m_strCallbacks,'(''ParameterSweepMode'');']);
 
strctControllers.m_hDisplayStimuliLocally = uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'checkbox', 'String', 'Play Stimuli Locally','value', g_strctParadigm.m_bDisplayStimuliLocally,...
     'Position', [5 iPanelHeight-iOffset-120 120 20], 'Callback', [g_strctParadigm.m_strCallbacks,'(''PlayStimuliLocally'');']);
 
strctControllers.m_hShowWhileLoading = uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'checkbox', 'String', 'Show While Loading','value',  g_strctParadigm.m_bShowWhileLoading,...
     'Position', [5 iPanelHeight-iOffset-140 220 20], 'Callback', [g_strctParadigm.m_strCallbacks,'(''ShowWhileLoading'');']);
 
 
strctControllers.m_hRepeatNonFixated= uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'checkbox', 'String', 'Repeat Non Fixated','value',  g_strctParadigm.m_bRepeatNonFixatedImages,...
     'Position', [5 iPanelHeight-iOffset-160 220 20], 'Callback', [g_strctParadigm.m_strCallbacks,'(''RepatNonFixatedToggle'');']);

 bForceStereo = fnTsGetVar('g_strctParadigm','ForceStereoOnMonocularLists') > 0;
 strctControllers.m_hForceStereoOnMonocularLists= uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'checkbox', 'String', 'Force Stereo in Monocular Designs','value',  bForceStereo,...
     'Position', [5 iPanelHeight-iOffset-180 220 20], 'Callback', [g_strctParadigm.m_strCallbacks,'(''ForceStereoToggle'');']);

 acLocalStereoMode = {'Left Eye Only','Right Eye Only','Left & Side by Side (Small)','Side by Side (Large)','Left: Red, Right: Blue','Left: Blue, Right: Red'};
 if isfield(g_strctParadigm,'m_strLocalStereoMode')
    iIndex=find(ismember(acLocalStereoMode,g_strctParadigm.m_strLocalStereoMode));
    if ~isempty(iIndex)
        iInitialMode = iIndex;
    else
     iInitialMode = 1;
    end
 else
     iInitialMode = 1;
 end
  strctControllers.m_hLocalStereoModeText = uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'text', 'String', ...
     'Local Stereo Mode','Position', [5 iPanelHeight-iOffset-205 130 20],'HorizontalAlignment','left');

 
 strctControllers.m_hLocalStereoModePopup = uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'popupmenu', 'String', ...
     acLocalStereoMode,'value', iInitialMode,...
     'Position', [130 iPanelHeight-iOffset-240 160 60], 'Callback', [g_strctParadigm.m_strCallbacks,'(''LocalStereoMode'');']);

  strctControllers.m_hBlocksDoneText = uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'text', 'String', ...
     'After blocks action:','Position', [5 iPanelHeight-iOffset-235 100 20],'HorizontalAlignment','left');
 
acBlocksDoneAction = {'Reset And Stop',  'Set Next Order But Do not Start',   'Repeat Same Order',    'Set Next Order and Start'};

iIndex = fnFindString(acBlocksDoneAction, g_strctParadigm.m_strBlockDoneAction);
if iIndex == -1
    g_strctParadigm.m_strBlockDoneAction = acBlocksDoneAction{1};
    iIndex = 1;
end
 
 strctControllers.m_hBlocksDoneActionPopup = uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'popupmenu', 'String', ...
     acBlocksDoneAction,'value', iIndex,...
     'Position', [130 iPanelHeight-iOffset-270 160 60], 'Callback', [g_strctParadigm.m_strCallbacks,'(''BlocksDoneAction'');']);


strctControllers.m_hLoopCurrentBlock = uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'checkbox', 'String', 'Loop Current Block','value',  g_strctParadigm.m_bBlockLooping,...
     'Position', [5 iPanelHeight-iOffset-255 180 20], 'Callback', [g_strctParadigm.m_strCallbacks,'(''BlockLoopingToggle'');']);
 
 
 
%% Micro Stimulation 
strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctMicroStimControllers.m_hPanel, 40+30*0, ...
    'Delay To Trig(ms):', 'MicrostimDelayMS',0, 200, [0.5, 5], fnTsGetVar('g_strctParadigm','MicrostimDelayMS'));

strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctMicroStimControllers.m_hPanel, 40+30*1, ...
    'Amplitude (uA/mW):', 'MicroStimulationCurrentMicroAmp',0, 1500, [50, 100], fnTsGetVar('g_strctParadigm','MicroStimulationAmplitude'));

strctControllers.m_hMicroStim = uicontrol('Parent',strctMicroStimControllers.m_hPanel,'Style', 'pushbutton', 'String', 'Microstimulate!',...
     'Position', [5 iPanelHeight-220 iButtonWidth 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''MicroStim'');']);


strctControllers.m_hMicroStimFixedRate = uicontrol('Parent',strctMicroStimControllers.m_hPanel,'Style', 'Checkbox', 'String', 'Fixed Stimulation Rate (Hz)',...
     'Position', [5 iPanelHeight-250 iButtonWidth 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''MicroStimFixedRateToggle'');'],'value',0);

strctControllers.m_hMicroStimPoissonRate = uicontrol('Parent',strctMicroStimControllers.m_hPanel,'Style', 'Checkbox', 'String', 'Poisson Stimulation (Hz)',...
     'Position', [5 iPanelHeight-280 iButtonWidth 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''MicroStimPoissonRateToggle'');'],'value',0);
 
set(strctMicroStimControllers.m_hPanel,'visible','off');

g_strctParadigm.m_strctControllers = strctControllers;
return;
