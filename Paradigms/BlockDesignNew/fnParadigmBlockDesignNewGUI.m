function fnParadigmBlockDesignNewGUI()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm   

% Note, always add controllers as fields to g_strctParadigm.m_strctControllers
% This way, they are automatically removed once we switch to another
% paradigm

   
[hParadigmPanel, iPanelHeight, iPanelWidth] = fnCreateParadigmPanel();
strctControllers.m_hPanel = hParadigmPanel;
strctControllers.m_iPanelHeight = iPanelHeight;
strctControllers.m_iPanelWidth = iPanelWidth;
iNumButtonsInRow = 3;
iButtonWidth = iPanelWidth / iNumButtonsInRow - 20;


%%

[strctJuiceControllers.m_hPanel, strctJuiceControllers.m_iPanelHeight,strctJuiceControllers.m_iPanelWidth] = ...
    fnCreateParadigmSubPanel(hParadigmPanel, 50, 600,'Reward');

[strctStimulusControllers.m_hPanel, strctStimulusControllers.m_iPanelHeight,strctStimulusControllers.m_iPanelWidth] = ...
    fnCreateParadigmSubPanel(hParadigmPanel,50,600,'Stimulus');

[strctDesignControllers.m_hPanel, strctDesignControllers.m_iPanelHeight,strctDesignControllers.m_iPanelWidth] = ...
    fnCreateParadigmSubPanel(hParadigmPanel,50,600,'Design');

[strctTimingControllers.m_hPanel, strctTimingControllers.m_iPanelHeight,strctTimingControllers.m_iPanelWidth] = ...
    fnCreateParadigmSubPanel(hParadigmPanel,50,600,'Timing');


%% Panel selections
strctControllers.m_hDesignPanelPushButton = uicontrol('Style','pushbutton','String','Design',...
    'Position',[10 iPanelHeight-40 70 30],'HorizontalAlignment','center','Parent',hParadigmPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''DesignPanel'');']);

strctControllers.m_hJuicePanelPushButton = uicontrol('Style','pushbutton','String','Reward',...
    'Position',[90 iPanelHeight-40 70 30],'HorizontalAlignment','center','Parent',hParadigmPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''JuicePanel'');']);

strctControllers.m_hStimulusPanelPushButton = uicontrol('Style','pushbutton','String','Stimuli',...
    'Position',[170 iPanelHeight-40 70 30],'HorizontalAlignment','center','Parent',hParadigmPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''StimulusPanel'');']);

strctControllers.m_hTimingPanelPushButton = uicontrol('Style','pushbutton','String','Timing',...
    'Position',[250 iPanelHeight-40 60 30],'HorizontalAlignment','center','Parent',hParadigmPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''TimingPanel'');']);

%% Reward panel
strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctJuiceControllers.m_hPanel, 40+30*0, ...
    'Gaze Time(ms):', 'GazeTimeMS', 30, 10000, [1, 50], fnTsGetVar(g_strctParadigm,'GazeTimeMS'));
strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctJuiceControllers.m_hPanel, 40+30*1, ...
    'Gaze Time (Low):', 'GazeTimeLowMS', 30, 10000, [1, 50], fnTsGetVar(g_strctParadigm,'GazeTimeLowMS'));
strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctJuiceControllers.m_hPanel, 40+30*2, ...
    'Gaze area (pix):', 'GazeBoxPix', 0, 300, [1, 50], fnTsGetVar(g_strctParadigm,'GazeBoxPix'));
strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctJuiceControllers.m_hPanel, 40+30*3, ...
    'Juice Time (ms):', 'JuiceTimeMS', 25, 100, [1, 5], fnTsGetVar(g_strctParadigm,'JuiceTimeMS'));
strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctJuiceControllers.m_hPanel, 40+30*4, ...
    'Juice Time (High):', 'JuiceTimeHighMS', 25, 100, [1, 5], fnTsGetVar(g_strctParadigm,'JuiceTimeHighMS'));
strctControllers= fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctJuiceControllers.m_hPanel, 40+30*5, ...
    'Blink Time (ms):', 'BlinkTimeMS',10, 500, [1, 50], fnTsGetVar(g_strctParadigm,'BlinkTimeMS'));
strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctJuiceControllers.m_hPanel, 40+30*6, ...
    'Positive Increment (%):', 'PositiveIncrement',0, 100, [1, 5], fnTsGetVar(g_strctParadigm,'PositiveIncrement'));

set(strctJuiceControllers.m_hPanel,'visible','off');
%% Stimuli panel
strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctStimulusControllers.m_hPanel, 40+30*0, ...
    'Fixation Size (pix):', 'FixationSizePix',0, 300, [1, 50], ...
    fnTsGetVar(g_strctParadigm,'FixationSizePix'));
strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctStimulusControllers.m_hPanel, 40+30*1, ...
    'Stimulus size (pix):', 'StimulusSizePix',0, 700,  [1, 50], fnTsGetVar(g_strctParadigm,'StimulusSizePix'));
strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctStimulusControllers.m_hPanel, 40+30*2, ...
    'Rotation Angle (Deg):', 'RotationAngle', -180, 180, [1, 5], ...
    fnTsGetVar(g_strctParadigm,'RotationAngle'));
strctControllers.m_hChangeBackgroundColor = uicontrol('style','pushbutton','parent', strctStimulusControllers.m_hPanel,'position',...
    [10 strctStimulusControllers.m_iPanelHeight-150 180 25],'String','Background color','callback',  [g_strctParadigm.m_strCallbacks,'(''ChangeBackgroundColor'');']);

strctControllers.m_hChangeFixationColor = uicontrol('style','pushbutton','parent', strctStimulusControllers.m_hPanel,'position',...
    [200 strctStimulusControllers.m_iPanelHeight-150 80 25],'String','Fixation color','callback',  [g_strctParadigm.m_strCallbacks,'(''ChangeFixationColor'');']);

set(strctStimulusControllers.m_hPanel,'visible','off');
%% Design Panel

strctDesignControllers.m_hLoadDesign= uicontrol('Style','pushbutton','String','Load Design',...
    'Position',[10 strctDesignControllers.m_iPanelHeight-50 100 30],'HorizontalAlignment','center','Parent',strctDesignControllers.m_hPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''LoadDesign'');']);

strctDesignControllers.m_hEditDesign= uicontrol('Style','pushbutton','String','Edit Design',...
    'Position',[120 strctDesignControllers.m_iPanelHeight-50 100 30],'HorizontalAlignment','center','Parent',strctDesignControllers.m_hPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''EditDesign'');']);

strctDesignControllers.m_hFavoriteDesigns= uicontrol('Style','listbox','String',g_strctParadigm.m_acFavroiteLists,...
    'Position',[10 strctDesignControllers.m_iPanelHeight-160 strctDesignControllers.m_iPanelWidth-20 100],'Parent',strctDesignControllers.m_hPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''FavoriteDesign'');']);

strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctDesignControllers.m_hPanel, 40+30*5, ...
    'TR (ms):', 'TR', 500, 4000, [500, 1000], fnTsGetVar(g_strctParadigm,'TR'));

if isempty(g_strctParadigm.m_strctDesign)
    acOrderNames = 'None';
else
    acOrderNames = fnCellStructToArray(g_strctParadigm.m_strctDesign.m_acBlockOrders,'m_strName');
end
strctDesignControllers.m_hDesignOrder= uicontrol('Style','popup','String',acOrderNames,...
    'Position',[10 strctDesignControllers.m_iPanelHeight-220 150 30],'Parent',strctDesignControllers.m_hPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''SelectBlockOrder'');']);

strctDesignControllers.m_hBlockOrder= uicontrol('Style','listbox','String','',...
    'Position',[10 strctDesignControllers.m_iPanelHeight-320 strctDesignControllers.m_iPanelWidth-20 100],'Parent',strctDesignControllers.m_hPanel);




strctDesignControllers.m_hNumTR = uicontrol('Style','text','String',sprintf('Num TR = %d', g_strctParadigm.m_iTotalTRs),...
    'Position',[170 strctDesignControllers.m_iPanelHeight-215 120 20],'HorizontalAlignment','Left','Parent',strctDesignControllers.m_hPanel);

strctDesignControllers.m_hAfterRun = uicontrol('Style','checkbox','String','Show fixation spot',...
    'Position',[10 strctDesignControllers.m_iPanelHeight-350 150 15],'HorizontalAlignment','Left','Parent',...
    strctDesignControllers.m_hPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''ToggleFixatioinAfterRun'');'],'value',...
    g_strctParadigm.m_bFixationWhileNotScanning);

strctDesignControllers.m_hUseTrig = uicontrol('Style','checkbox','String','Use TR Trigger To Start',...
    'Position',[10 strctDesignControllers.m_iPanelHeight-370 160 15],'HorizontalAlignment','Left','Parent',...
    strctDesignControllers.m_hPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''ToggleUseTrigger'');'],'value',...
    g_strctParadigm.m_bUseTriggerToStart);

strctDesignControllers.m_hAbortRun = uicontrol('Style','pushbutton','String','Abort Run',...
    'Position',[170 strctDesignControllers.m_iPanelHeight-350 95 25],'HorizontalAlignment','center','Parent',strctDesignControllers.m_hPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''AbortRun'');']);

strctDesignControllers.m_hSimulateTrigger = uicontrol('Style','pushbutton','String','Simulate Trigger',...
    'Position',[170 strctDesignControllers.m_iPanelHeight-380 95 25],'HorizontalAlignment','center','Parent',strctDesignControllers.m_hPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''SimulateTrigger'');']);


strctDesignControllers.hExpName = uicontrol('Style', 'listbox', 'String','',...
    'Position', [10 strctDesignControllers.m_iPanelHeight-480 180 100], 'parent',strctDesignControllers.m_hPanel, 'Callback',[g_strctParadigm.m_strCallbacks,'(''SelectExperiment'');'],...
    'min', 1,'max',1,'value',1);

strctDesignControllers.m_hExpNameEdit = fnMyUIControlEdit('Style','edit','String','',...
    'Position',[200  strctDesignControllers.m_iPanelHeight-480 60 30],'HorizontalAlignment','left','Parent',strctDesignControllers.m_hPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''ExperimentNameEdit'');']);


g_strctParadigm.m_strctStimulusControllers = strctStimulusControllers;
g_strctParadigm.m_strctJuiceControllers = strctJuiceControllers;
g_strctParadigm.m_strctDesignControllers = strctDesignControllers;
g_strctParadigm.m_strctTimingControllers = strctTimingControllers;
set(g_strctParadigm.m_strctTimingControllers.m_hPanel,'visible','off');

strctControllers.m_ahSubPanels = [strctStimulusControllers.m_hPanel;strctJuiceControllers.m_hPanel;strctDesignControllers.m_hPanel;strctTimingControllers.m_hPanel];

g_strctParadigm.m_strctControllers = strctControllers;


%%
if ~isempty(g_strctParadigm.m_strctDesign)
    fnClearDesignGlobalVarControllers();
    fnAddTimeStampedVariablesFromDesignToParadigmStructure(g_strctParadigm.m_strctDesign, true);

    % Generate the run-time list from the design
    g_strctParadigm.m_strctCurrentRun = fnPrepareStimuliTimingFromBlockDesign();
    % update number of TRs
    set(g_strctParadigm.m_strctDesignControllers.m_hNumTR,'string',sprintf('Num TRs : %d',sum(g_strctParadigm.m_strctCurrentRun.m_aiNumTRperBlock)));
    
    % Setup the block list according to the selected order.
    
    set(g_strctParadigm.m_strctDesignControllers.m_hBlockOrder,'string',g_strctParadigm.m_strctCurrentRun.m_acBlockNamesWithMicroStim);
else
     g_strctParadigm.m_strctCurrentRun = [];
end

% Favirote designs



return;
