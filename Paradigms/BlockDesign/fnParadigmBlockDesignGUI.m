function fnParadigmBlockDesignGUI()
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



[strctMicroStimControllers.m_hPanel, strctMicroStimControllers.m_iPanelHeight,strctMicroStimControllers.m_iPanelWidth] = ...
    fnCreateParadigmSubPanel(hParadigmPanel, 50, 300,'MicroStim Control');

strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers, strctMicroStimControllers.m_hPanel, 40+30*0, ...
    'MicroStim Cycle (ms):', 'MicroStimCycleMS', 1, 3000, [1, 50], fnTsGetVar(g_strctParadigm,'MicroStimCycleMS'));

strctMicroStimControllers.hBlockRunList = uicontrol('Style', 'listbox', 'String','',...
    'Position', [10 60 250 150], 'parent',strctMicroStimControllers.m_hPanel, 'Callback',[g_strctParadigm.m_strCallbacks,'(''SelectMicroStimBlocks'');']);

BlockRunOrder = fnTsGetVar(g_strctParadigm, 'BlockRunOrder');
if ~isempty(BlockRunOrder)
    fnUpdateListController(strctMicroStimControllers.hBlockRunList, BlockRunOrder,1:2:size(BlockRunOrder,1),true);
end

set(strctMicroStimControllers.m_hPanel,'visible','off');



[strctJuiceControllers.m_hPanel, strctJuiceControllers.m_iPanelHeight,strctJuiceControllers.m_iPanelWidth] = ...
    fnCreateParadigmSubPanel(hParadigmPanel, 50, 300,'Juice Control');

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

strctControllers.m_strctJuiceControllers = strctJuiceControllers;
strctControllers.m_strctMicroStimControllers = strctMicroStimControllers;


[strctStimulusControllers.m_hPanel, strctStimulusControllers.m_iPanelHeight,strctStimulusControllers.m_iPanelWidth] = ...
    fnCreateParadigmSubPanel(hParadigmPanel,50,300,'Stimulus');

strctControllers.m_hSubPanels = [strctStimulusControllers.m_hPanel;strctJuiceControllers.m_hPanel;strctMicroStimControllers.m_hPanel];


strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctStimulusControllers.m_hPanel, 40+30*0, ...
    'Fixation Size (pix):', 'FixationSizePix',0, 300, [1, 50], ...
    fnTsGetVar(g_strctParadigm,'FixationSizePix'));
strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctStimulusControllers.m_hPanel, 40+30*1, ...
    'Stimulus size (pix):', 'StimulusSizePix',0, 700,  [1, 50], fnTsGetVar(g_strctParadigm,'StimulusSizePix'));
strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctStimulusControllers.m_hPanel, 40+30*2, ...
    'Rotation Angle (Deg):', 'RotationAngle', -180, 180, [1, 5], ...
    fnTsGetVar(g_strctParadigm,'RotationAngle'));
strctControllers.m_hChangeBackgroundColor = uicontrol('style','pushbutton','parent', strctStimulusControllers.m_hPanel,'position',...
    [10 120 100 25],'String','Change background color','callback',  [g_strctParadigm.m_strCallbacks,'(''ChangeBackgroundColor'');']);

strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctStimulusControllers.m_hPanel, 40+30*4, ...
    'TR (ms):', 'TR', 500, 4000, [500, 1000], fnTsGetVar(g_strctParadigm,'TR'));

strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctStimulusControllers.m_hPanel, 40+30*5, ...
    '# TRs per block:', 'NumTRsPerBlock', 1, 20, [1 5], fnTsGetVar(g_strctParadigm,'NumTRsPerBlock'));

fRefreshRateMS = fnParadigmToKofikoComm('GetRefreshRate');
strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctStimulusControllers.m_hPanel, 40+30*6, ...
    'Stimulus Time (ms):', 'StimulusTimeMS',fRefreshRateMS, ...
    500*fRefreshRateMS, [fRefreshRateMS, fRefreshRateMS*5], ...
    fnTsGetVar(g_strctParadigm ,'StimulusTimeMS'));


strctControllers.m_strctStimulusControllers = strctStimulusControllers;




[strctMRIControllers.m_hPanel, strctMRIControllers.m_iPanelHeight,strctMRIControllers.m_iPanelWidth] = ...
    fnCreateParadigmSubPanel(hParadigmPanel,300,640,'Block Design Control');


strctControllers.hImageListContextMenu = uicontextmenu;
uimenu(strctControllers.hImageListContextMenu, 'Label', 'Load List', 'Callback', [g_strctParadigm.m_strCallbacks,'(''LoadList'');']);

strctControllers.hImageList = uicontrol('Style', 'listbox', 'String','',...
    'Position', [10 230 140 80], 'parent',strctMRIControllers.m_hPanel, 'Callback',[g_strctParadigm.m_strCallbacks,'(''SelectImages'');'],...
    'min', 1,'max',1,'value',1,'UIContextMenu',strctControllers.hImageListContextMenu);

acFileNamesNoPath = fnRemovePath(fnTsGetVar(g_strctParadigm, 'ImageFileList'));
fnUpdateListController(strctControllers.hImageList, acFileNamesNoPath,[],true);

strctControllers.hBlockContextMenu = uicontextmenu;
uimenu(strctControllers.hBlockContextMenu , 'Label', 'Add To Run', 'Callback', [g_strctParadigm.m_strCallbacks,'(''AddBlockToRun'');']);
uimenu(strctControllers.hBlockContextMenu , 'Label', 'Load Block List', 'Callback', [g_strctParadigm.m_strCallbacks,'(''LoadBlockList'');'],'separator','on');

strctControllers.hBlockList = uicontrol('Style', 'listbox', 'String','',...
    'Position', [10 140 140 80], 'parent',strctMRIControllers.m_hPanel, 'Callback',[g_strctParadigm.m_strCallbacks,'(''SelectBlocks'');'],...
    'min', 1,'max',1,'value',1,'UIContextMenu',strctControllers.hBlockContextMenu);

acBlockNameList = fnTsGetVar(g_strctParadigm, 'BlockNameList');
if ~isempty(acBlockNameList)
    acBlockImageIndicesList = fnTsGetVar(g_strctParadigm, 'BlockImageIndicesList');
    fnUpdateListController(strctControllers.hBlockList, acBlockNameList,1,false);
    set(strctControllers.hImageList,'value',acBlockImageIndicesList{1});
end

strctControllers.hRunContextMenu = uicontextmenu;
uimenu(strctControllers.hRunContextMenu , 'Label', 'Move Up', 'Callback', [g_strctParadigm.m_strCallbacks,'(''MoveBlockUp'');']);
uimenu(strctControllers.hRunContextMenu , 'Label', 'Move Down', 'Callback', [g_strctParadigm.m_strCallbacks,'(''MoveBlockDown'');']);
uimenu(strctControllers.hRunContextMenu , 'Label', 'Remove', 'Callback', [g_strctParadigm.m_strCallbacks,'(''RemoveBlocksFromRun'');']);
uimenu(strctControllers.hRunContextMenu , 'Label', 'Save Run', 'Callback', [g_strctParadigm.m_strCallbacks,'(''SaveRun'');']);
uimenu(strctControllers.hRunContextMenu , 'Label', 'Load Run', 'Callback', [g_strctParadigm.m_strCallbacks,'(''LoadRun'');'],'separator','on');
uimenu(strctControllers.hRunContextMenu , 'Label', 'Load Experiment', 'Callback', [g_strctParadigm.m_strCallbacks,'(''LoadExperiment'');'],'separator','on');

strctControllers.hBlockRunList = uicontrol('Style', 'listbox', 'String', '',...
    'Position', [160 180 140 140], 'parent',strctMRIControllers.m_hPanel, 'Callback',[g_strctParadigm.m_strCallbacks,'(''SelectBlockRun'');'],...
    'min', 1,'max',1,'value',1,'UIContextMenu',strctControllers.hRunContextMenu);

%iSelectedMode = get(g_strctParadigm.m_strctControllers.m_hRunOptions,'value');

strctControllers.m_hNumTR = uicontrol('Style','text','String',sprintf('Num TR = %d', g_strctParadigm.m_iTotalTRs),...
    'Position',[10 100 140 30],'HorizontalAlignment','Left','Parent',strctMRIControllers.m_hPanel);

if ~isempty(BlockRunOrder)
    fnUpdateListController(strctControllers.hBlockRunList, BlockRunOrder,1,false);
end

strOptions = {'Block TR With Repeats','Block TR','Stimulus Time'};
iInitialRunType = find(ismember(strOptions, g_strctParadigm.m_strInitial_Default_RunType));

strctControllers.m_hRunOptions = uicontrol('Style', 'popup',...
    'String', char(strOptions),...
    'Position',[160 30 140 140],...
    'Callback', [g_strctParadigm.m_strCallbacks,'(''ChangeRunMode'');'],'parent',strctMRIControllers.m_hPanel,'value',iInitialRunType);



strctControllers.m_hImageListText= uicontrol('Style','text','String','Image List','Position',[10 335 80 15],'HorizontalAlignment','Left','Parent',strctMRIControllers.m_hPanel);
%strctControllers.m_hBlockListText= uicontrol('Style','text','String','Block List','Position',[10 230 80 15],'HorizontalAlignment','Left','Parent',strctMRIControllers.m_hPanel);

strctControllers.m_hRunListText= uicontrol('Style','text','String','Current Run','Position',[190 335 80 15],'HorizontalAlignment','Left','Parent',strctMRIControllers.m_hPanel);

strctControllers.m_hAfterRun = uicontrol('Style','checkbox','String','Show fixation spot',...
    'Position',[10 80 150 15],'HorizontalAlignment','Left','Parent',...
    strctMRIControllers.m_hPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''ToggleFixatioinAfterRun'');'],'value',...
    g_strctParadigm.m_bFixationWhileNotScanning);


strctControllers.m_hUseMicroStim = uicontrol('Style','checkbox','String','MicroStim',...
    'Position',[10 100 160 15],'HorizontalAlignment','Left','Parent',...
    strctMRIControllers.m_hPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''ToggleMicroStim'');'],'value',...
    g_strctParadigm.m_bMicroStim);


strctControllers.m_hUseTrig = uicontrol('Style','checkbox','String','Use TR Trigger To Start',...
    'Position',[10 60 160 15],'HorizontalAlignment','Left','Parent',...
    strctMRIControllers.m_hPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''ToggleUseTrigger'');'],'value',...
    g_strctParadigm.m_bUseTriggerToStart);

strctControllers.m_hAbortRun = uicontrol('Style','pushbutton','String','Abort Run',...
    'Position',[10 20 iButtonWidth 30],'HorizontalAlignment','center','Parent',strctMRIControllers.m_hPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''AbortRun'');']);

strctControllers.m_hSimulateTrigger = uicontrol('Style','pushbutton','String','SimTrig',...
    'Position',[10+iButtonWidth 20 60 30],'HorizontalAlignment','center','Parent',strctMRIControllers.m_hPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''SimulateTrigger'');']);


strctControllers.hExpName = uicontrol('Style', 'listbox', 'String','',...
    'Position', [170 40 120 100], 'parent',strctMRIControllers.m_hPanel, 'Callback',[g_strctParadigm.m_strCallbacks,'(''SelectExperiment'');'],...
    'min', 1,'max',1,'value',1);

strctControllers.m_hExpNameEdit = fnMyUIControlEdit('Style','edit','String','',...
    'Position',[250 15 60 20],'HorizontalAlignment','left','Parent',strctMRIControllers.m_hPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''ExperimentNameEdit'');']);

strctControllers.m_hExpNameText = uicontrol('Style','text','String','Exp Name',...
    'Position',[160 10 50 20],'HorizontalAlignment','left','Parent',strctMRIControllers.m_hPanel);



strctControllers.m_hJuicePanelPushButton = uicontrol('Style','pushbutton','String','Juice Controls',...
    'Position',[10 iPanelHeight-50 90 30],'HorizontalAlignment','center','Parent',hParadigmPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''JuicePanel'');']);

strctControllers.m_hStimulusPanelPushButton = uicontrol('Style','pushbutton','String','Stimulus Controls',...
    'Position',[110 iPanelHeight-50 100 30],'HorizontalAlignment','center','Parent',hParadigmPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''StimulusPanel'');']);


strctControllers.m_hStimulusPanelPushButton = uicontrol('Style','pushbutton','String','MicroStim',...
    'Position',[220 iPanelHeight-50 60 30],'HorizontalAlignment','center','Parent',hParadigmPanel,'Callback',[g_strctParadigm.m_strCallbacks,'(''MicroStimPanel'');']);

g_strctParadigm.m_strctControllers = strctControllers;

return;
