function StatServer
global g_bAppIsRunning g_strctConfig  g_strctCycle g_DebugDataLog g_counter g_strctNeuralServer g_strctWindows
dbstop if error
addpath('.\MEX\win32;.\PublicLib\Plexon\Realtime;.\PublicLib\Msocket;');
% addpath(genpath('.\StatServer'));

g_strctConfig.m_strctDirectories.m_strDataFolder = 'C:\Shay\Data\Logs';
if ~exist(g_strctConfig.m_strctDirectories.m_strDataFolder,'dir')
    mkdir(g_strctConfig.m_strctDirectories.m_strDataFolder);
end;

%%
fNow = now;
strTmp = datestr(fNow,25);
strDate = strTmp([1,2,4,5,7,8]);
strTmp = datestr(fNow,13);
strTime =  strTmp([1,2,4,5,7,8]);
g_strctCycle.m_strTmpSessionName = [strDate,'_',strTime,'_Unknown'];

%%
g_strctConfig.m_strctServer.m_fListenTimeOutSec = 1;
g_strctConfig.m_strctServer.m_fPort = 4003;
g_strctConfig.m_strctGUIParams.m_iSystemMouse = 3;
g_strctConfig.m_strctAdvancers.m_fMouseWheelToMM = 115;
  
g_strctConfig.m_strctServer.m_fAdvancerSampleHz= 5;
g_strctConfig.m_strctServer.m_fPingPongSec = 1;

g_strctConfig.m_strctConsistencyChecks.m_bLostUnits = true;
g_strctConfig.m_strctConsistencyChecks.m_fLostUnitCheckSec = 10; % Check every one minute
g_strctConfig.m_strctConsistencyChecks.m_fDeclareUnitThresSec = 20;

g_strctConfig.m_strctGUIParams.m_fBarGraphFrom = 50;
g_strctConfig.m_strctGUIParams.m_fBarGraphTo = 200;


g_strctConfig.m_strctGUIParams.m_iChannelDisplayStart = 1;
g_strctConfig.m_strctGUIParams.m_fRefreshHz = 1;
g_strctConfig.m_strctGUIParams.m_fSmoothingWindowMS = 15;
g_strctConfig.m_strctGUIParams.m_strViewMode = 'PSTH';
g_strctConfig.m_strctGUIParams.m_bAutoRescale = false;
g_strctConfig.m_strctGUIParams.m_bSmoothPSTH = true;
g_strctConfig.m_strctGUIParams.m_iMaxChannelsOnScreen = 4;
g_strctConfig.m_strctNeuralServer.m_strType = 'PLEXON';

fndllMiceHook('Init');
g_strctCycle.m_iNumAdvancers = fndllMiceHook('GetNumMice');
if g_strctCycle.m_iNumAdvancers <= 0 || isempty(g_strctCycle.m_iNumAdvancers);
    % Try again ?
    fndllMiceHook('Init');
    g_strctCycle.m_iNumAdvancers = fndllMiceHook('GetNumMice');
    if g_strctCycle.m_iNumAdvancers <= 0 || isempty(g_strctCycle.m_iNumAdvancers);
        fprintf('***Critical Error connecting to advancers!\n');
        return;
    end
end


g_strctCycle.m_strSafeCallback = [];
g_strctCycle.m_acSafeCallbackParams = {};
g_strctCycle.m_strctPlexonFrame.m_fMAPClockAtFrameStart = NaN;
g_strctCycle.m_strctPlexonFrame.m_fStatServerTS = NaN;
g_strctCycle.m_strctPlexonFrame.m_iCurrentPlexonFrame = NaN;
g_strctCycle.m_strctPlexonFrame.m_fKofiko_TS = NaN;

% Local time, Kofiko Time
g_strctCycle.m_strctSync = fnTsAddVar([], 'PlexonSync', [0 0 0 0], 500);
g_strctCycle.m_strctSync = fnTsAddVar(g_strctCycle.m_strctSync, 'KofikoSync', [GetSecs(), NaN], 8 * 60 * 60); % 8 hours... more than enough...
g_strctCycle.m_strctSync = fnTsAddVar(g_strctCycle.m_strctSync, 'KofikoSyncPingPong', [GetSecs(), NaN, 0], 8 * 60 * 60); % 8 hours... more than enough...
g_strctCycle.m_fSyncTimer = 0;


g_strctCycle.m_strSessionName = [];
g_strctCycle.m_strctWarnings.m_bUnidentifiedChannel = false;
g_strctCycle.m_bShutDownDone = false;
g_strctCycle.m_afAdvancerPrevReadOut = zeros(1,g_strctCycle.m_iNumAdvancers);
g_strctCycle.m_fAdvancerTimer  = 0;
g_strctCycle.m_fConsistencyTimerUnits = 0;
g_strctCycle.m_bClientConnected = false;
g_strctCycle.m_fRefreshTimer = 0;
g_strctCycle.m_bConditionInfoAvail = false;
g_strctCycle.m_bPlexonIsRecording = false;
g_strctCycle.m_iTrialCounter = 0;
g_strctCycle.m_iGlobalUnitCounter = 0;

hWarning = msgbox('Please make sure PlexNet is running and connected to the server!','Important Message');
waitfor(hWarning);
drawnow

if (~fnSetWindowAndButtons())
    return;
end;

bSuccess = fnConnectToNeuralServer();
if  ~bSuccess
       fprintf('***Critical Error connecting to Plexnet!\n');
       fnCloseStatServerFig([],[]);
        return;
end;

if g_strctNeuralServer.m_bConnected == false
       fprintf('***Critical Error connecting to Plexnet!\n');
       return;
end
fnSetActiveChannelsTable();

fnSetAxesForPlotting();
fnSetupListeningPort();

% Register channels to electrodes
g_strctNeuralServer.m_acGrids = [];
g_strctNeuralServer.m_acAdvancerNames=fndllMiceHook('GetMiceName');
[g_strctNeuralServer.m_acGrids, g_strctNeuralServer.m_a2iChannelToGridHoleAdvancer,g_strctNeuralServer.m_afAdvancerOffsetMM] = ElectrophysGUI(...
    g_strctNeuralServer.m_acSpikeChannelNames,g_strctNeuralServer.m_acGrids,g_strctNeuralServer.m_acAdvancerNames,...
    g_strctConfig.m_strctDirectories.m_strDataFolder);

fnSaveStatServerMatData();

aiUsedAdvancers = unique(g_strctNeuralServer.m_a2iChannelToGridHoleAdvancer(:,3));
g_strctNeuralServer.m_aiUsedAdvancers = aiUsedAdvancers(~isnan(aiUsedAdvancers));

fnUpdateAdvancerText();
%

% Write advancer file (in case values are never changed...
for k=1:g_strctCycle.m_iNumAdvancers
    iAdvancerIndex = k;
    % Only register advancers that are used.....
    if sum(g_strctNeuralServer.m_aiUsedAdvancers == iAdvancerIndex) > 0
        fnStatServerCallbacks('UpdateAdvancer',iAdvancerIndex,g_strctNeuralServer.m_afAdvancerOffsetMM(iAdvancerIndex));
    end
end

%
g_counter=0;
set(g_strctWindows.m_hFigure,'Visible','on');
drawnow
g_bAppIsRunning = true;
while (g_bAppIsRunning)
    fnStatServerCycle();
end;

fnCloseStatServer();
return;


function fnSetActiveChannelsTable()
global g_strctNeuralServer g_strctWindows
iNumActive = length(g_strctNeuralServer.m_aiActiveSpikeChannels);
acActiveNames = g_strctNeuralServer.m_acSpikeChannelNames(g_strctNeuralServer.m_aiActiveSpikeChannels);
a2cData = cell(iNumActive, 3);
for k=1:iNumActive
    a2cData{k,1} = g_strctNeuralServer.m_aiActiveSpikeChannels(k);
    a2cData{k,2} = acActiveNames{k};
    a2cData{k,3} = g_strctNeuralServer.m_abChannelsDisplayed( k);
end
set(g_strctWindows.m_strctSettingsPanel.m_hChannelTable,'Data',a2cData,'CellEditCallback',@fnToggleChannelDisplay);

return;

function fnSetupListeningPort()
global g_strctNet g_strctConfig
 g_strctNet.m_iCommSocket = 0;
g_strctNet.m_iServerSocket = mslisten(g_strctConfig.m_strctServer.m_fPort);

return;



function bOK = fnSetWindowAndButtons()
global g_strctWindows
bOK = true;
a2iMonitors = get(0,'MonitorPositions');
iNumMonitors = size(a2iMonitors,1);
if iNumMonitors > 1
    % Multiple monitors. ASk user which one to use
    acOptions = cell(1,iNumMonitors);
    for k=1:iNumMonitors
        acOptions{k} = sprintf('Screen %d, [%dx%d]',k,a2iMonitors(k,3)-a2iMonitors(k,1)+1,a2iMonitors(k,4)-a2iMonitors(k,2)+1);
    end
    [iSelectedMonitor] = listdlg('PromptString','Select a monitor:',...
        'SelectionMode','single',...
        'ListString',acOptions);
   if isempty(iSelectedMonitor)
       bOK = false;
       return;
   end;   
else
    iSelectedMonitor = 1;
end

iStartX = a2iMonitors(iSelectedMonitor,1);
iStartY = a2iMonitors(iSelectedMonitor,4);

if ishandle(1)
    delete(1)
end;
    
g_strctWindows.m_hFigure = figure(1);
drawnow
set(g_strctWindows.m_hFigure,'Position',  [ iStartX+50 0         150         120])
clf;
set(g_strctWindows.m_hFigure,'Units','Pixels',...
    'Name','Real Time Statistics Server','Visible','on','Menubar','none','Toolbar','figure','DockControls','off',...
    'NumberTitle','off','CloseRequestFcn',@fnCloseStatServerFig,...
    'KeyPressFcn',@fnKeyDown,'KeyReleaseFcn',@fnKeyUp,'WindowScrollWheelFcn',@fnMouseWheel,...
    'WindowButtonMotionFcn',@fnMouseMove,'WindowButtonUpFcn',@MouseUp,'WindowButtonDownFcn',@MouseDown);


colordef(g_strctWindows.m_hFigure, 'black');
fnMaximizeWindow(g_strctWindows.m_hFigure);
drawnow


aiWindowSize = get(g_strctWindows.m_hFigure,'Position');

%%

iOffset = 2;
iHeight = aiWindowSize(4);
iFigureWidth = aiWindowSize(3);

iRightPanelWidth = 400;

strctSettingsPanel.m_aiPos = [iFigureWidth-iRightPanelWidth-iOffset 1 iRightPanelWidth iHeight];
strctSettingsPanel.m_hPanel= uipanel('Units','Pixels','Position',strctSettingsPanel.m_aiPos,'parent',g_strctWindows.m_hFigure);

aiPos = [10 10 iRightPanelWidth-20 200]; 
acLines = {'Starging the real time statistical server...'};
aiBack = get(strctSettingsPanel.m_hPanel,'BackgroundColor') * 0.7;
strctSettingsPanel.m_hLogTextBox = uicontrol('style', 'text','Unit','pixels','Position', aiPos,'parent',strctSettingsPanel.m_hPanel,'string',acLines,'BackgroundColor',aiBack,'HorizontalAlignment','left');

strctSettingsPanel.m_hNeuralServerConnect = uicontrol('style', 'pushbutton','Unit','pixels','Position', [10 iHeight-50 150 30],'parent',strctSettingsPanel.m_hPanel,'string','Connect to Neural Server','callback',@fnReconnectNeuralServer);

strctSettingsPanel.m_hSettings = uicontrol('style', 'pushbutton','Unit','pixels','Position', [170 iHeight-50 90 30],'parent',strctSettingsPanel.m_hPanel,'string','Settings');

strctSettingsPanel.m_hElectroPhys = uicontrol('style', 'pushbutton','Unit','pixels','Position', [280 iHeight-50 110 30],'parent',strctSettingsPanel.m_hPanel,'string','Electrophsyiology','callback',@fnCallElecytrophysGUI);

strctSettingsPanel.m_hClearCritical = uicontrol('style', 'pushbutton','Unit','pixels','Position', [280 iHeight-90 110 30],'parent',strctSettingsPanel.m_hPanel,'string','Clear Log','callback',@fnClearCriticalLog);

strctSettingsPanel.m_hExit = uicontrol('style', 'pushbutton','Unit','pixels','Position', [170 iHeight-90 110 30],'parent',strctSettingsPanel.m_hPanel,'string','Exit','callback',@fnExit);

strctSettingsPanel.m_hCriticalLog = uicontrol('style', 'listbox',...
    'Unit','pixels','Position', [10 iHeight-200 iRightPanelWidth-20 100],...
    'parent',strctSettingsPanel.m_hPanel,'string',{'Critical Messages'},'FontSize',14,'ForegroundColor',[1 0 0]);
     
acColNames = {'Name','PSTH','Raster','Color'};
acColEdit = [false true true false];
acColFormat = {'char','logical','logical','char'};
strctSettingsPanel.m_hConditionTable = uitable('Position', [10 iHeight-400 iRightPanelWidth-20 180],'parent',strctSettingsPanel.m_hPanel,...
            'ColumnName', acColNames,...
            'ColumnFormat', acColFormat,...
            'ColumnEditable', acColEdit,'CellSelectionCallback',@fnConditionCellSelectCallback,'CellEditCallback',@fnConditionCellEditCallback);
        
acColNames = {'Num','Name','Display'};
acColEdit = [false false true];
acColFormat = {'numeric','char','logical'};
strctSettingsPanel.m_hChannelTable = uitable('Position', [10  iHeight-600 iRightPanelWidth-20 150],'parent',strctSettingsPanel.m_hPanel,...
            'ColumnName', acColNames,...
            'ColumnFormat', acColFormat,...
            'ColumnEditable', acColEdit);        

strctSettingsPanel.m_hPrevChannelButton = uicontrol('style', 'pushbutton','Unit','pixels','Position', ...
    [5 670 100 25],'parent',strctSettingsPanel.m_hPanel,'string','Prev Channels','callback',@fnPrevChannels);

strctSettingsPanel.m_hNextChannelButton = uicontrol('style', 'pushbutton','Unit','pixels','Position', ...
    [120 670 100 25],'parent',strctSettingsPanel.m_hPanel,'string','Next Channels','callback',@fnNextChannels);


strctStatPanel.m_aiPos = [2 1 iFigureWidth-iRightPanelWidth-10 iHeight];
strctStatPanel.m_hPanel = uipanel('Units','Pixels','Position',strctStatPanel.m_aiPos,'parent',g_strctWindows.m_hFigure);
set(strctStatPanel.m_hPanel,'BackgroundColor',[0 0 0]);

strctSettingsPanel.m_hGUIPanel = uibuttongroup('Units','Pixels','parent',strctSettingsPanel.m_hPanel,'position',[10  iHeight-710 iRightPanelWidth-20 100],'SelectionChangeFcn',@fnStatServerCallbacksRadioWrapper);

strctSettingsPanel.m_hRadioPSTH = uicontrol('Style','Radio','String','PSTH',...
    'pos',[10 10 100 30],'parent',strctSettingsPanel.m_hGUIPanel,'HandleVisibility','off','UserData','PSTH');%,,{@fnStatServerCallbacksWrapper,'SetVisualization','PSTH'});

strctSettingsPanel.m_hRadioRaster = uicontrol('Style','Radio','String','Raster',...
    'pos',[10 30 100 30],'parent',strctSettingsPanel.m_hGUIPanel,'HandleVisibility','off','UserData','Raster');%,'SelectionChangeFcn',{@fnStatServerCallbacksWrapper,'SetVisualization','Raster'});

strctSettingsPanel.m_hRadioBarGraph = uicontrol('Style','Radio','String','Bar Graph: From ',...
    'pos',[10 50 130 30],'parent',strctSettingsPanel.m_hGUIPanel,'HandleVisibility','off','UserData','BarGraph');%,'SelectionChangeFcn',{@fnStatServerCallbacksWrapper,'SetVisualization','BarGraph'});


strctSettingsPanel.m_hEditFrom = uicontrol('Style','edit','String','50',...
    'pos',[120 55 40 20],'parent',strctSettingsPanel.m_hGUIPanel,'callback',{@fnStatServerCallbacksEditWrapper,'SetBarGraphRange','Start'},'backgroundcolor',[1 1 1],'foregroundcolor',[0 0 0]);

strctSettingsPanel.m_hText1 = uicontrol('Style','text','String','ms to ','position',[160 50 40 20],'parent',strctSettingsPanel.m_hGUIPanel);

strctSettingsPanel.m_hEditTo = uicontrol('Style','edit','String','200',...
    'pos',[200 55 40 20],'parent',strctSettingsPanel.m_hGUIPanel,'callback',{@fnStatServerCallbacksEditWrapper,'SetBarGraphRange','Finish'},'backgroundcolor',[1 1 1],'foregroundcolor',[0 0 0]);

strctSettingsPanel.m_hLinkAxes = uicontrol('Style','CheckBox','String','Link Axes',...
    'pos',[100 10 100 25],'parent',strctSettingsPanel.m_hGUIPanel,'HandleVisibility','off','callback',{@fnStatServerCallbacksWrapper,'SetVisualization','LinkAxes'});

strctSettingsPanel.m_hSmoothCurves = uicontrol('Style','CheckBox','String','Smooth Curves',...
    'pos',[100 30 100 25],'parent',strctSettingsPanel.m_hGUIPanel,'HandleVisibility','off','callback',{@fnStatServerCallbacksWrapper,'SetVisualization','SmoothCurves'});

strctSettingsPanel.m_hAutoRescale = uicontrol('Style','Checkbox','String','Auto Rescale',...
    'pos',[200 10 100 25],'parent',strctSettingsPanel.m_hGUIPanel,'HandleVisibility','off','callback',{@fnStatServerCallbacksWrapper,'SetVisualization','ToggleAutoRescale'},'value',0);

strctSettingsPanel.m_hClearAll = uicontrol('style', 'pushbutton','Unit','pixels','Position', ...
    [250 55 100 25],'parent',strctSettingsPanel.m_hGUIPanel,'string','Clear All','callback',@fnClearAll);

%%
% Crate fake axes
strctSettingsPanel.m_hLFPImageAxes=axes('parent',strctSettingsPanel.m_hPanel,'units',...
    'pixels','position',[5 220 iRightPanelWidth-20 170]);
Z = zeros(13, 1862); % Dummy size, corresponding to FOB & Axial Array.
strctSettingsPanel.m_hLFPImage = image([],[], Z,'parent',strctSettingsPanel.m_hLFPImageAxes);
colormap jet
g_strctWindows.m_strctSettingsPanel = strctSettingsPanel;
g_strctWindows.m_strctStatPanel = strctStatPanel;

set(g_strctWindows.m_hFigure,'Visible','off');

return;

function fnClearAll(a,b) 
global g_strctNeuralServer
for iChannel=1:g_strctNeuralServer.m_iNumActiveSpikeChannels
    % Reset analog form
    TrialCircularBuffer('ResetConditionAnalog',iChannel,0); % Reset all conditions
    % Reset units
    for iUnitIter=1:g_strctNeuralServer.m_iNumberUnitsPerChannel
        TrialCircularBuffer('ResetConditionSpikes',iChannel,iUnitIter,0); % Reset all conditions
        TrialCircularBuffer('ResetWaveForm',iChannel,iUnitIter); % Reset all conditions
    end
end
return;


function fnMouseWheel(a,b)
return;

function fnMouseMove(a,b)
return;

function MouseUp(a,b)
return;

function MouseDown(a,b)
global g_strctWindows g_strctNeuralServer g_strctConfig
strctMouseOp.m_strButton = fnGetClickType(a);
hAxes=get(a,'CurrentAxes');
if ~isempty(hAxes)
    iIndex = find(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes == hAxes);
    if ~isempty(iIndex)
        Tmp = get(hAxes,'CurrentPoint');
        pt2fMouseDownPosition = [Tmp(1,1), Tmp(1,2)];
        bInside = 1;
        if bInside
            [i,j]=ind2sub(size(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes),iIndex);
            
            iNumChannelsOnScreen = size(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes,1);
            aiChIndInTrialBuf = find(g_strctNeuralServer.m_abChannelsDisplayed);
            
            % aiChannelsToDisplay represents the indices in trial buffer !!!!
            if length(aiChIndInTrialBuf) <= iNumChannelsOnScreen
                aiChannelsToDisplay = aiChIndInTrialBuf;
            else
                aiChannelsToDisplay = aiChIndInTrialBuf(g_strctConfig.m_strctGUIParams.m_iChannelDisplayStart:min(length(aiChIndInTrialBuf), g_strctConfig.m_strctGUIParams.m_iChannelDisplayStart+iNumChannelsOnScreen-1));
            end
            
            iChannel = aiChannelsToDisplay(i);
            iUnit = j-1;
            
            switch strctMouseOp.m_strButton
                case 'Right'
                    if iUnit == 0
                        fnStatLog('Resetting statistics for LFP Channel %d',iChannel);
                        TrialCircularBuffer('ResetConditionAnalog',iChannel,0); % Reset all conditions
                        fnDisplayOverview();
                    else
                        fnStatLog('Resetting statistics for Unit [%d : %d]',iChannel,iUnit);
                        TrialCircularBuffer('ResetConditionSpikes',iChannel,iUnit,0); % Reset all conditions
                        TrialCircularBuffer('ResetWaveForm',iChannel,iUnit); % Reset all conditions
                        fnDisplayOverview();
                    end
            end
        end
    end
end

return;


function fnKeyDown(a,b)


return;

function fnKeyUp(a,b)
return;



function fnCloseStatServerFig(a,b)
global g_bAppIsRunning g_strctWindows
if g_bAppIsRunning == false
    try
        delete(g_strctWindows.m_hFigure)
    catch
    end
end

g_bAppIsRunning = false;
return

function fnConditionCellSelectCallback(hTable,Tmp)
global g_strctCycle
aiIndices=Tmp.Indices;
if size(aiIndices,1) == 1 && aiIndices(2) == 4
    iCondition = aiIndices(1);
     RGB=uisetcolor();
     if length(RGB) == 3
        g_strctCycle.m_a2fConditionColors(iCondition,:) = RGB;
         fnUpdateConditionList();
         fnDisplayOverview();
         
     end
end
return;

function fnConditionCellEditCallback(hTable,Tmp)
global g_strctCycle
aiIndices=Tmp.Indices;
if size(aiIndices,1) == 1 && aiIndices(2) == 2
    iCondition = aiIndices(1);
    if ~isempty( Tmp.NewData )
        g_strctCycle.m_abDisplayConditions(iCondition) = Tmp.NewData > 0;
        fnDisplayOverview();
    end
end

if size(aiIndices,1) == 1 && aiIndices(2) == 3
    iCondition = aiIndices(1);
   if ~isempty( Tmp.NewData )
       g_strctCycle.m_abDisplayConditionsRaster(iCondition) = Tmp.NewData > 0;
        fnDisplayOverview();        
   end
end
return;

function fnStatServerCallbacksWrapper(h,b,varargin)
fnStatServerCallbacks(varargin{:});
return;

function fnStatServerCallbacksRadioWrapper(a,b)
fnStatServerCallbacks('SetVisualization', get(b.NewValue,'UserData'));
return;

function fnStatServerCallbacksEditWrapper(a,b,c,d)
fnStatServerCallbacks(c,d,get(a,'string'));
return;

function fnClearCriticalLog(a,b)
global g_strctWindows g_strctCycle
g_strctCycle.m_strctWarnings.m_bUnidentifiedChannel = false;
set(g_strctWindows.m_strctSettingsPanel.m_hCriticalLog,'string',{'Critical Messages'},'value',1);
return;


%if 

function strMouseClick = fnGetClickType(hFigure)
strMouseType = get(hFigure,'selectiontype');
if (strcmp( strMouseType,'alt'))
    strMouseClick = 'Right';
end;
if (strcmp( strMouseType,'normal'))
    strMouseClick = 'Left';
end;
if (strcmp( strMouseType,'extend'))
    strMouseClick = 'Both';
end;
if (strcmp( strMouseType,'open'))
    strMouseClick = 'DoubleClick';
end;
return;


function fnCallElecytrophysGUI(a,b)
global g_strctNeuralServer  g_strctConfig

% [g_strctNeuralServer.m_acGrids, g_strctNeuralServer.m_a2iChannelToGridHoleAdvancer,g_strctNeuralServer.m_afAdvancerOffsetMM] = ElectrophysGUI(...
%     g_strctNeuralServer.m_acChannelNames,g_strctNeuralServer.m_acGrids,g_strctNeuralServer.m_acAdvancerNames,...
%     g_strctConfig.m_strctDirectories.m_strDataFolder);
% 
% fnSaveStatServerMatData();


function fnExit(a,b)
global g_bAppIsRunning
g_bAppIsRunning = false;
return;


function fnToggleChannelDisplay(hTable,Tmp)
global g_strctNeuralServer  g_strctCycle
aiIndices=Tmp.Indices;
if size(aiIndices,1) == 1 && aiIndices(2) == 3
    iChannel = aiIndices(1);
    g_strctNeuralServer.m_abChannelsDisplayed(iChannel) =  Tmp.NewData>0;
    g_strctCycle.m_strSafeCallback = 'UpdateAxes';
end
return;

function fnUpdateScreenChannelsAux(iDeltaScroll)
global g_strctNeuralServer g_strctWindows g_strctConfig
iNumVisibleChannels = sum(g_strctNeuralServer.m_abChannelsDisplayed);
iNumChannelsOnScreen = size(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes,1);
g_strctConfig.m_strctGUIParams.m_iChannelDisplayStart = min(iNumVisibleChannels-iNumChannelsOnScreen+1,max(1,g_strctConfig.m_strctGUIParams.m_iChannelDisplayStart + iDeltaScroll));
fnUpdatePushButtonsTitle();
fnUpdateAdvancerText();

     
function fnPrevChannels(a,b)
     fnUpdateScreenChannelsAux(-1);
     return;
     
function fnNextChannels(a,b)
fnUpdateScreenChannelsAux(1);
return;
function fnReconnectNeuralServer(a,b)
