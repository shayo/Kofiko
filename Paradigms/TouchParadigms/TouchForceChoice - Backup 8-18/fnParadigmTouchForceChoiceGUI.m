function fnParadigmTouchForceChoiceGUI() 
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

iNumButtonsInRow = 3;
iButtonWidth = iPanelWidth / iNumButtonsInRow - 20;


[strctTimingControllers.m_hPanel, strctTimingControllers.m_iPanelHeight,strctTimingControllers.m_iPanelWidth] = ...
    fnCreateParadigmSubPanel(hParadigmPanel,90,iPanelHeight-5,'Timing');


[strctStimuliControllers.m_hPanel, strctStimuliControllers.m_iPanelHeight,strctStimuliControllers.m_iPanelWidth] = ...
    fnCreateParadigmSubPanel(hParadigmPanel,90,iPanelHeight-5,'Stimuli');


[strctRewardControllers.m_hPanel, strctRewardControllers.m_iPanelHeight,strctRewardControllers.m_iPanelWidth] = ...
    fnCreateParadigmSubPanel(hParadigmPanel,90,iPanelHeight-5,'Reward');

[strctMicroStimControllers.m_hPanel, strctMicroStimControllers.m_iPanelHeight,strctMicroStimControllers.m_iPanelWidth] = ...
    fnCreateParadigmSubPanel(hParadigmPanel,90,iPanelHeight-5,'Microstim');

[strctDesignControllers.m_hPanel, strctDesignControllers.m_iPanelHeight,strctDesignControllers.m_iPanelWidth] = ...
    fnCreateParadigmSubPanel(hParadigmPanel,90,iPanelHeight-5,'Design');

[strctStatControllers.m_hPanel, strctStatControllers.m_iPanelHeight,strctStatControllers.m_iPanelWidth] = ...
    fnCreateParadigmSubPanel(hParadigmPanel,90,iPanelHeight-5,'Statistics');

strctControllers.m_hSubPanels = [strctTimingControllers.m_hPanel;strctStimuliControllers.m_hPanel;strctRewardControllers.m_hPanel;...
    strctMicroStimControllers.m_hPanel;strctDesignControllers.m_hPanel;strctStatControllers.m_hPanel];

 strctControllers.m_hSetTimingPanel = uicontrol('Parent',hParadigmPanel, 'Style', 'pushbutton', 'String', 'Timing',...
      'Position', [5 iPanelHeight-40 iButtonWidth 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''TimingPanel'');'],'enable','on');
    
 strctControllers.m_hSetStimuliPanel = uicontrol('Parent',hParadigmPanel, 'Style', 'pushbutton', 'String', 'Stimuli',...
      'Position', [iButtonWidth+10 iPanelHeight-40 iButtonWidth 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''StimuliPanel'');'],'enable','on');

 strctControllers.m_hSetRewardPanel = uicontrol('Parent',hParadigmPanel, 'Style', 'pushbutton', 'String', 'Reward',...
      'Position', [2*iButtonWidth+20 iPanelHeight-40 iButtonWidth 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''RewardPanel'');'],'enable','on');

   strctControllers.m_hSetMicroStimPanel = uicontrol('Parent',hParadigmPanel, 'Style', 'pushbutton', 'String', 'Microstim',...
      'Position', [5 iPanelHeight-80 iButtonWidth 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''MicrostimPanel'');'],'enable','on');

     strctControllers.m_hDesignPanel = uicontrol('Parent',hParadigmPanel, 'Style', 'pushbutton', 'String', 'Design',...
      'Position', [iButtonWidth+10 iPanelHeight-80 iButtonWidth 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''DesignPanel'');']);

strctControllers.m_hStatPanel = uicontrol('Parent',hParadigmPanel, 'Style', 'pushbutton', 'String', 'Statistics',...
      'Position', [2*iButtonWidth+20 iPanelHeight-80 iButtonWidth 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''StatPanel'');']);
%% Juice

strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctRewardControllers.m_hPanel, 40+30*1, ...
    'Juice Time (ms):', 'JuiceTimeMS',25, 100, [1, 5], fnTsGetVar(g_strctParadigm,'JuiceTimeMS'));

strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctRewardControllers.m_hPanel, 40+30*2, ...
    'Juice Time (High):', 'JuiceTimeHighMS', 25, 100, [1, 5], fnTsGetVar(g_strctParadigm,'JuiceTimeHighMS'));

strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctRewardControllers.m_hPanel, 40+30*3, ...
    'Blink Time (ms):', 'BlinkTimeMS', 10, 500, [1, 50], fnTsGetVar(g_strctParadigm,'BlinkTimeMS'));

strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers, strctRewardControllers.m_hPanel,40+30*4, ...
    'Positive Increment (%):', 'PositiveIncrement', 0, 100, [1, 5], fnTsGetVar(g_strctParadigm,'PositiveIncrement'));


  
set(strctRewardControllers.m_hPanel,'visible','off');

%% Timing

strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers, strctTimingControllers.m_hPanel,40+30*1, ...
    'Cue display Period (ms):', 'CuePeriodMS', 0, 100, [1, 5], fnTsGetVar(g_strctParadigm,'CuePeriodMS'));

strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers, strctTimingControllers.m_hPanel,40+30*2, ...
    'Cue Memory Period (ms):', 'CueMemoryPeriodMS', 0, 100, [1, 5], fnTsGetVar(g_strctParadigm,'CueMemoryPeriodMS'));

%% Stimuli 


strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers, strctStimuliControllers.m_hPanel,40+30*1, ...
    'Choice Eccentricity (pix):', 'ChoiceEccentricity', 0, 100, [1, 5], fnTsGetVar(g_strctParadigm,'ChoiceEccentricity'));
	
strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers, strctStimuliControllers.m_hPanel,40+30*2, ...
    'Choice Size (pix):', 'ChoiceSize', 0, 100, [1, 5], fnTsGetVar(g_strctParadigm,'ChoiceSize'));
	
strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers, strctStimuliControllers.m_hPanel,40+30*3, ...
    'Fixation Size (pix):', 'FixationRadiusPix', 0, 100, [1, 5], fnTsGetVar(g_strctParadigm,'FixationRadiusPix'));

strctControllers.m_hSetFixationCueOverride = uicontrol('Parent',strctStimuliControllers.m_hPanel,'Style', 'checkbox', 'String', 'Use Fixation As Cue','value',...
	g_strctParadigm.m_bUseFixationSpotAsCue,...
    'Position', [5 iPanelHeight-190 130 80], 'Callback', [g_strctParadigm.m_strCallbacks,'(''UseFixationAsCue'');']);

	
strctControllers.hColorListContextMenu = uicontextmenu;
[a2cCharMatrix, g_strctParadigm.m_strctMasterColorTableLookup] = fnStructToCharShort(g_strctParadigm.m_strctMasterColorTable);
strctControllers.m_hSaturationLists = uicontrol('Style', 'listbox', 'String', a2cCharMatrix,...
    'Position', [10 iPanelHeight-350 strctStimuliControllers.m_iPanelWidth-15 100], 'parent',strctStimuliControllers.m_hPanel, 'Callback',[g_strctParadigm.m_strCallbacks,'(''SelectSaturations'');'],...
    'value',max(1,g_strctParadigm.m_iInitialIndexInSaturationList),'UIContextMenu',strctControllers.hColorListContextMenu, 'max', size(a2cCharMatrix,1),'min',0);
	
% Kludgey for now, until I make a better solution
colorStr = {'color1';'color2';'color3';'color4';'color5';'color6';'color7';'color8';'color9';'color10';'color11';'color12';'color13';'color14';'color15';'color16'};
colorCell = char(colorStr);
strctControllers.m_hColorLists = uicontrol('Style', 'listbox', 'String', colorCell,...
    'Position', [10 iPanelHeight-500 ,strctStimuliControllers.m_iPanelWidth-15 100], 'parent',strctStimuliControllers.m_hPanel, 'Callback',[g_strctParadigm.m_strCallbacks,'(''SelectColors'');'],...
    'value',max(1,g_strctParadigm.m_iInitialIndexInColorList),'UIContextMenu',strctControllers.hColorListContextMenu, 'max', 16, 'min', 0);


	
	
	
strctControllers.m_hSetStimulusOverRide = uicontrol('Parent',strctStimuliControllers.m_hPanel,'Style', 'checkbox', 'String', 'OverRide Stimulus Control','value',...
	g_strctParadigm.m_bDynamicStimuli,...
    'Position', [5 iPanelHeight-800 130 80], 'Callback', [g_strctParadigm.m_strCallbacks,'(''OverRideStimulusControl'');']);
%% Microstim

strctControllers.m_hSetMicroStimActive = uicontrol('Parent',strctMicroStimControllers.m_hPanel,'Style', 'checkbox', 'String', 'MicroStim Active','value',...
	g_strctParadigm.MicroStimActive.Buffer(g_strctParadigm.MicroStimActive.BufferIdx),...
    'Position', [5 iPanelHeight-190 130 80], 'Callback', [g_strctParadigm.m_strCallbacks,'(''MicroStimActive'');']);
	
strctControllers.m_hSetBipolarStimulationActive = uicontrol('Parent',strctMicroStimControllers.m_hPanel,'Style', 'checkbox', 'String', 'BiPolar Stimulation Active','value',...
	g_strctParadigm.MicroStimBiPolar.Buffer(g_strctParadigm.MicroStimBiPolar.BufferIdx),...
    'Position', [5 iPanelHeight-240 130 80], 'Callback', [g_strctParadigm.m_strCallbacks,'(''MicroStimBiPolar'');']);
%strctMicroStimControllers.m_hMicroStimActive = uicontrol('Parent',strctMicroStimControllers.m_hPanel,'Style', 'pushbutton', 'String', 'Microstim active',...
%    'Position', [5 iPanelHeight-140 130 30],'callback', [g_strctParadigm.m_strCallbacks,'(''MicroStimActive'');']);

%strctMicroStimControllers.m_hMicroStimBiPolar = uicontrol('Parent',strctMicroStimControllers.m_hPanel,'Style', 'pushbutton', 'String', 'BiPolar stimulation',...
   % 'Position', [5 iPanelHeight-180 130 30],'callback', [g_strctParadigm.m_strCallbacks,'(''MicroStimBiPolar'');']);
	
	
strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctMicroStimControllers.m_hPanel, 40+40*3, ...
    'Amplitude', 'MicroStimAmplitude', 0, 359, [1, 2], fnTsGetVar(g_strctParadigm ,'MicroStimAmplitude'));
	
strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctMicroStimControllers.m_hPanel, 40+40*4, ...
    'Delay (MS)', 'MicroStimDelayMS', 0, 359, [1, 1000], fnTsGetVar(g_strctParadigm ,'MicroStimDelayMS'));
	
strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctMicroStimControllers.m_hPanel, 40+40*5, ...
    'Pulse Width', 'MicroStimPulseWidthMS', 0, 359, [1, 2], fnTsGetVar(g_strctParadigm ,'MicroStimPulseWidthMS'));
	
strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctMicroStimControllers.m_hPanel, 40+40*6, ...
    'Pulse Width 2', 'MicroStimSecondPulseWidthMS', 0, 359, [1, 2], fnTsGetVar(g_strctParadigm ,'MicroStimSecondPulseWidthMS'));
	
strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctMicroStimControllers.m_hPanel, 40+40*7, ...
    'IPI Delay', 'MicroStimBipolarDelayMS', 0, 359, [1, 2], fnTsGetVar(g_strctParadigm ,'MicroStimBipolarDelayMS'));
	
strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctMicroStimControllers.m_hPanel, 40+40*8, ...
    'Pulse Rate', 'MicroStimPulseRateHz', 0, 359, [1, 2], fnTsGetVar(g_strctParadigm ,'MicroStimPulseRateHz'));
	
strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctMicroStimControllers.m_hPanel, 40+40*9, ...
    'Train Rate', 'MicroStimTrainRateHz', 0, 359, [1, 2], fnTsGetVar(g_strctParadigm ,'MicroStimTrainRateHz'));
	
strctControllers = fnAddTextSliderEditComboSmallWithCallback2(strctControllers,strctMicroStimControllers.m_hPanel, 40+40*10, ...
    'Train Duration', 'MicroStimTrainDurationMS', 0, 359, [1, 2], fnTsGetVar(g_strctParadigm ,'MicroStimTrainDurationMS'));
	
%% Stat


strctStatControllers.m_hClearStat = uicontrol('Parent',strctStatControllers.m_hPanel,'Style', 'pushbutton', 'String', 'Clear All Stat',...
    'Position', [5 iPanelHeight-140 130 30],'callback', [g_strctParadigm.m_strCallbacks,'(''ResetAllDesignsStat'');']);
strctStatControllers.m_hClearCurrentStat = uicontrol('Parent',strctStatControllers.m_hPanel,'Style', 'pushbutton', 'String', 'Clear Current Stat',...
    'Position', [140 iPanelHeight-140 130 30],'callback', [g_strctParadigm.m_strCallbacks,'(''ResetDesignStat'');']);

strctStatControllers.m_hPercentCheckBox = uicontrol('Parent',strctStatControllers.m_hPanel,'Style', 'checkbox', 'String', 'Stat in %',...
    'Position', [5 iPanelHeight-160 130 20],'value',0,'callback', [g_strctParadigm.m_strCallbacks,'(''ReplotStat'');']);

strctStatControllers.m_hStatTable = uitable('ColumnName',{'Trial Name','Correct','Incorrect','Aborted','Timeout'},...
    'parent',strctStatControllers.m_hPanel,'position',[5 iPanelHeight-470 iPanelWidth-20 300]);

afDefaultColor = get(strctStatControllers.m_hClearCurrentStat,'BackgroundColor');
  strctStatControllers.m_hStatText = uicontrol('Parent',strctStatControllers.m_hPanel,'Style', 'text', 'String', '',...
      'Position', [5 iPanelHeight-680 iPanelWidth-20 200],'BackgroundColor',afDefaultColor*0.9,'HorizontalAlignment','left');

%% Design   
  strctDesignControllers.m_hLoadDesign = uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'pushbutton', 'String', 'Load Design',...
      'Position', [5 iPanelHeight-140 130 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''LoadDesign'');']);

  strctDesignControllers.m_hLoadDesign = uicontrol('Parent',strctDesignControllers.m_hPanel,'Style', 'pushbutton', 'String', 'Edit Design',...
      'Position', [150 iPanelHeight-140 130 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''EditDesign'');']);
  

strctDesignControllers.m_hTrialBlocksTable = uitable('parent',strctDesignControllers.m_hPanel,...
            'position',[10 iPanelHeight-440 strctDesignControllers.m_iPanelWidth-15  150],'ColumnName',{'Block Name','Trial Types','#Trials'},'ColumnEditable',[false true true],...
            'CellEditCallback',@fnModifyBlockOrder,'CellSelectionCallback',@fnSelectBlockOrder);

 strctDesignControllers.m_hDeleteBlock = uicontrol('Parent',strctDesignControllers.m_hPanel, 'Style', 'pushbutton', 'String', 'Delete Block(s)',...
      'Position', [5 iPanelHeight-285 iButtonWidth 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''DeleteBlockFromDesign'');'],'enable','off');
  
 strctDesignControllers.m_hAddBlock = uicontrol('Parent',strctDesignControllers.m_hPanel, 'Style', 'pushbutton', 'String', 'Add Block',...
      'Position', [iButtonWidth+15 iPanelHeight-285 iButtonWidth 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''AddBlockToDesign'');'],'enable','off');

   strctDesignControllers.m_hJumpToBlock = uicontrol('Parent',strctDesignControllers.m_hPanel, 'Style', 'pushbutton', 'String', 'Jump to Block',...
      'Position', [2*iButtonWidth+25 iPanelHeight-285 iButtonWidth 30], 'Callback', [g_strctParadigm.m_strCallbacks,'(''JumpToBlock'');']);

strctDesignControllers.m_hTrialTypeList = uicontrol('Style', 'listbox', 'String', '','enable','off',...
    'Position', [10 iPanelHeight-550 strctDesignControllers.m_iPanelWidth-15  100], 'parent',strctDesignControllers.m_hPanel);

strctDesignControllers.m_hResetGlobalVars= uicontrol('Style', 'checkbox', 'String', 'Reset global vars after design reload',...
    'Position', [10 iPanelHeight-580 strctDesignControllers.m_iPanelWidth-15  20], 'parent',strctDesignControllers.m_hPanel,'value',false);

strctDesignControllers.m_hfMRI_Mode= uicontrol('Style', 'checkbox', 'String', 'fMRI Mode',...
    'Position', [10 iPanelHeight-600 strctDesignControllers.m_iPanelWidth-15  20], 'parent',strctDesignControllers.m_hPanel,'value',false, 'Callback', [g_strctParadigm.m_strCallbacks,'(''fMRI_Mode_Toggle'');']);

 strctDesignControllers.m_hAbortRun = uicontrol('Parent',strctDesignControllers.m_hPanel, 'Style', 'pushbutton', 'String', 'Abort fMRI Run',...
      'Position', [iButtonWidth+105 iPanelHeight-600 iButtonWidth 20], 'Callback', [g_strctParadigm.m_strCallbacks,'(''Abort_fMRI_Run'');']);

   strctDesignControllers.m_hSimTrig = uicontrol('Parent',strctDesignControllers.m_hPanel, 'Style', 'pushbutton', 'String', 'Simulate Trig',...
      'Position', [iButtonWidth+105 iPanelHeight-625 iButtonWidth 20], 'Callback', [g_strctParadigm.m_strCallbacks,'(''SimulateTrig'');']);

   strctDesignControllers.m_hChangeTRValue = uicontrol('Parent',strctDesignControllers.m_hPanel, 'Style', 'edit', 'String', num2str(fnTsGetVar(g_strctParadigm, 'TR')),...
      'Position', [iButtonWidth+10 iPanelHeight-600 iButtonWidth 20], 'Callback', [g_strctParadigm.m_strCallbacks,'(''ChangeTR'');']);

strctDesignControllers.m_hTotalNumberOfTRs= uicontrol('Style', 'text', 'String', '#TRs in design: NaN',...
    'Position', [10 iPanelHeight-625 100  20], 'parent',strctDesignControllers.m_hPanel,'horizontalalignment','left');
  
%%

set(strctTimingControllers.m_hPanel,'visible','off');
set(strctStimuliControllers.m_hPanel,'visible','off');
set(strctRewardControllers.m_hPanel,'visible','off');
set(strctMicroStimControllers.m_hPanel,'visible','off');
set(strctStatControllers.m_hPanel,'visible','off');


g_strctParadigm.m_strctStimuliControllers = strctStimuliControllers;
g_strctParadigm.m_strctTimingControllers = strctTimingControllers;
g_strctParadigm.m_strctRewardControllers = strctRewardControllers;
g_strctParadigm.m_strctDesignControllers = strctDesignControllers;
g_strctParadigm.m_strctMicroStimControllers= strctMicroStimControllers;
g_strctParadigm.m_strctStatControllers= strctStatControllers;


fnLoadFavoriteDesigns();
feval(g_strctParadigm.m_strCallbacks,'ResetAllDesignsStat');

g_strctParadigm.m_strctDesignControllers.m_hFavroiteLists = uicontrol('Style', 'listbox', 'String', fnCellToCharShort(g_strctParadigm.m_acFavroiteLists),...
    'Position', [10 iPanelHeight-250 strctDesignControllers.m_iPanelWidth-15  100], 'parent',strctDesignControllers.m_hPanel, 'Callback',[g_strctParadigm.m_strCallbacks,'(''LoadFavoriteList'');'],...
    'value',max(1,g_strctParadigm.m_iInitialIndexInFavroiteList));


if ~isempty(g_strctParadigm.m_strctDesign)
      fnUpdateForceChoiceDesignTable();
end
  
g_strctParadigm.m_strctControllers = strctControllers;
return;

function fnSelectBlockOrder(a, strctWhatChanged)
global g_strctParadigm
if isempty(g_strctParadigm.m_strctDesign) || ~isfield( strctWhatChanged,'Indices') || isempty(strctWhatChanged.Indices)
    return;
end;

iBlockNumber = strctWhatChanged.Indices(1,1);
g_strctParadigm.m_iSelectedBlockInDesignTable = iBlockNumber;
return;

function fnModifyBlockOrder(a,strctWhatChanged)
global g_strctParadigm
if isempty(g_strctParadigm.m_strctDesign)
    return;
end;

iNumTrialTypes = length(g_strctParadigm.m_strctDesign.m_acTrialTypes);
iBlockNumber = strctWhatChanged.Indices(1,1);
g_strctParadigm.m_iSelectedBlockInDesignTable = iBlockNumber;

if strctWhatChanged.Indices(1,2) == 2
    % Trial type changed. Make sure it is still valid, otherwise, discard
    
    

    % change!
    aiNewTrialTypes = strctWhatChanged.NewData;
    if isempty(aiNewTrialTypes) || min(aiNewTrialTypes) <= 0 || max(aiNewTrialTypes) > iNumTrialTypes || sum(isnan(aiNewTrialTypes))> 0
        a2cData = get(g_strctParadigm.m_strctDesignControllers.m_hTrialBlocksTable,'Data');
        a2cData{iBlockNumber,1} = strctWhatChanged.PreviousData;
        set(g_strctParadigm.m_strctDesignControllers.m_hTrialBlocksTable,'Data',a2cData);
        return;
    end

    % Modify the force choice block order according to existing table (!)
    g_strctParadigm.m_strctDesign.m_strctOrder.m_acTrialTypeIndex{iBlockNumber} = aiNewTrialTypes;
end

if strctWhatChanged.Indices(1,2) == 3
    % Num trials changed
    if isnumeric(strctWhatChanged.NewData)
        iNewNumTrials = strctWhatChanged.NewData;
    else
        iNewNumTrials = str2num(strctWhatChanged.NewData);
    end
    
    if isempty(iNewNumTrials) || ~isreal(iNewNumTrials) || length(iNewNumTrials) > 1 || isnan(iNewNumTrials)
        a2cData = get(g_strctParadigm.m_strctDesignControllers.m_hTrialBlocksTable,'Data');
        a2cData{iBlockNumber,2} = strctWhatChanged.PreviousData;
        set(g_strctParadigm.m_strctDesignControllers.m_hTrialBlocksTable,'Data',a2cData);
        return;
    end
    g_strctParadigm.m_strctDesign.m_strctOrder.m_aiNumTrialsPerBlock(iBlockNumber) = iNewNumTrials;
end
return;




function fnLoadFavoriteDesigns()
global g_strctParadigm g_strctPTB
acFieldNames = fieldnames(g_strctParadigm);
acFavroiteLists = cell(1,0);
iListCounter = 1;
for k=1:length(acFieldNames)
    if strncmpi(acFieldNames{k},'m_strInitial_FavroiteList',25)
        strImageListFileName = getfield(g_strctParadigm,acFieldNames{k});
        if exist(strImageListFileName,'file')
            acFavroiteLists{iListCounter} = strImageListFileName;
            iListCounter = iListCounter + 1;
        end
    end
end
g_strctParadigm.m_bStimulusServerLoadedMedia = false;

if ~isempty(g_strctParadigm.m_strInitial_DesignFile) && exist(g_strctParadigm.m_strInitial_DesignFile,'file')
    [strPath,strFile,strExt] = fileparts(g_strctParadigm.m_strInitial_DesignFile);
    
    g_strctParadigm.m_strctDesign = fnLoadForceChoiceNewDesignFile(g_strctParadigm.m_strInitial_DesignFile);
    
    if ~isempty(g_strctParadigm.m_strctDesign) % successful load
         fnTsSetVarParadigm('ExperimentDesigns',g_strctParadigm.m_strctDesign);
         
         fnAddTimeStampedVariablesFromDesignToParadigmStructure(g_strctParadigm.m_strctDesign,true);
         
         
         % Send this information to statistics server
         if fnParadigmToStatServerComm('IsConnected')
            fnParadigmToStatServerComm('SendDesign', g_strctParadigm.m_strctDesign.m_strctStatServerDesign);
        end
         
        g_strctParadigm.m_strctTrialTypeCounter.m_iTrialCounter = 0;
         % Instruct stimulus server to load media if not on the fly
         % mode....
         if ~g_strctParadigm.m_strctDesign.m_bLoadOnTheFly 
             if fnParadigmToKofikoComm('IsTouchMode')
                 fnParadigmTouchForceChoiceDrawCycle({'LoadMedia', g_strctParadigm.m_strctDesign.m_astrctMedia});
                 g_strctParadigm.m_bStimulusServerLoadedMedia = true;
             else
                fnParadigmToStimulusServer('LoadMedia', g_strctParadigm.m_strctDesign.m_astrctMedia);  % Load media on stim server
                g_strctParadigm.m_acMedia = fnLoadMedia(g_strctPTB.m_hWindow,g_strctParadigm.m_strctDesign.m_astrctMedia,true); % Load media locally
                g_strctParadigm.m_bStimulusServerLoadedMedia = false;
             end
         else
             g_strctParadigm.m_bStimulusServerLoadedMedia = true;
         end
         
         iInitialIndex = -1;
        for k=1:length(acFavroiteLists)
            if strcmpi(acFavroiteLists{k}, g_strctParadigm.m_strInitial_DesignFile)
                iInitialIndex = k;
                break;
            end
        end
        if iInitialIndex == -1
            acFavroiteLists = [g_strctParadigm.m_strInitial_DesignFile,acFavroiteLists];
            iInitialIndex = 1;
        end
    else
        g_strctParadigm.m_strctDesign = [];
        g_strctParadigm.m_acImages = [];
        iInitialIndex = 1;
    end
else
    g_strctParadigm.m_strctDesign = [];
    g_strctParadigm.m_acImages = [];
    iInitialIndex = 1;
end


g_strctParadigm.m_acFavroiteLists = acFavroiteLists;
g_strctParadigm.m_iInitialIndexInFavroiteList = iInitialIndex;

return;