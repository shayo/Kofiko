function varargout = BlockDesign(varargin)
% BLOCKDESIGN M-file for BlockDesign.fig
%      BLOCKDESIGN, by itself, creates a new BLOCKDESIGN or raises the existing
%      singleton*.
%
%      H = BLOCKDESIGN returns the handle to a new BLOCKDESIGN or the handle to
%      the existing singleton*.
%
%      BLOCKDESIGN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BLOCKDESIGN.M with the given input arguments.
%
%      BLOCKDESIGN('Property','Value',...) creates a new BLOCKDESIGN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BlockDesign_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BlockDesign_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BlockDesign

% Last Modified by GUIDE v2.5 29-Dec-2010 14:42:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @BlockDesign_OpeningFcn, ...
    'gui_OutputFcn',  @BlockDesign_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before BlockDesign is made visible.
function BlockDesign_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BlockDesign (see VARARGIN)

% Choose default command line output for BlockDesign
dbstop if error
handles.output = hObject;
strctParams.m_fImageTimeMS = 500;
strctParams.m_iNumTRsPerBlock = 12;
strctParams.m_fTR_MS = 2000;
strctParams.m_iImageSizePix = 200;
strctParams.m_iFixationRadius = 3;
strctParams.m_iTriggerKey = 49;


setappdata(handles.figure1,'strctParams',strctParams);
set(handles.hTREdit,'String',num2str(strctParams.m_fTR_MS));
set(handles.hNumTREdit,'String',num2str(strctParams.m_iNumTRsPerBlock));
set(handles.hImageTimeEdit,'String',num2str(strctParams.m_fImageTimeMS));
set(handles.hFixationSpotRadiusEdit,'string',num2str(strctParams.m_iFixationRadius));
set(handles.hImageSizePixEdit,'string',num2str(strctParams.m_iImageSizePix));
set(handles.hTriggerKey,'string',num2str(strctParams.m_iTriggerKey));

try
    iNumScreens=Screen('Screens');
catch
    % PTB path is not set ?
    fprintf('PTB Folder is not in matlab path!\n');
    R = input('Do you want to try and load it from the default.xml file [y/n]:','s');
    if ~isempty(R) && (R(1) == 'y' || R(1) == 'Y')
           strXMLConfigFileName = '.\Config\Default.xml';
           [g_strctAppConfig,g_astrctAllParadigms, g_strctSystemCodes] = ...
               fnLoadKofikoConfigXML(strXMLConfigFileName);
           
           addpath([g_strctAppConfig.m_strctDirectories.m_strPTB_Folder,'PsychBasic']);
           addpath([g_strctAppConfig.m_strctDirectories.m_strPTB_Folder,'PsychBasic\MatlabWindowsFilesR2007a']);
           addpath([g_strctAppConfig.m_strctDirectories.m_strPTB_Folder,'PsychOneliners']);
           addpath([g_strctAppConfig.m_strctDirectories.m_strPTB_Folder,'PsychRects']);
           addpath([g_strctAppConfig.m_strctDirectories.m_strPTB_Folder,'PsychTests']);
           addpath([g_strctAppConfig.m_strctDirectories.m_strPTB_Folder,'PsychPriority']);
           addpath([g_strctAppConfig.m_strctDirectories.m_strPTB_Folder,'PsychAlphaBlending']);
           addpath([g_strctAppConfig.m_strctDirectories.m_strPTB_Folder,'PsychOpenGL\MOGL\core']);
           addpath([g_strctAppConfig.m_strctDirectories.m_strPTB_Folder,'PsychOpenGL\MOGL\wrap']);
           addpath([g_strctAppConfig.m_strctDirectories.m_strPTB_Folder,'PsychGLImageProcessing']);
           addpath([g_strctAppConfig.m_strctDirectories.m_strPTB_Folder,'PsychOpenGL']);
           iNumScreens=Screen('Screens');
    else
        fprintf('Please properly install PTB and try again!\n');
        fprintf('Aborting...\n');
        delete(handles.figure1);
        return;
    end
    
end

acNames = cell(1,length(iNumScreens));
for iScreenIter=1:length(iNumScreens)
    strctTmp = Screen('Resolution', iScreenIter-1);
    acNames{iScreenIter} = sprintf('%d : [%dx%d]',iScreenIter,strctTmp.width,strctTmp.height);
end
set(handles.hPTBScreenID,'string',acNames,'value',1);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BlockDesign wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BlockDesign_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = []; %handles.output;


% --- Executes on selection change in hBlockList.
function hBlockList_Callback(hObject, eventdata, handles)
% hObject    handle to hBlockList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hBlockList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hBlockList


% --- Executes during object creation, after setting all properties.
function hBlockList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hBlockList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hTREdit_Callback(hObject, eventdata, handles)
strctParams = getappdata(handles.figure1,'strctParams');
strctParams.m_fTR_MS = str2num(get(hObject,'string'));
fnUpdateNumberOfTRS(handles);
setappdata(handles.figure1,'strctParams',strctParams);


% --- Executes during object creation, after setting all properties.
function hTREdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hTREdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function hNumTREdit_Callback(hObject, eventdata, handles)
strctParams = getappdata(handles.figure1,'strctParams');
strctParams.m_iNumTRsPerBlock = str2num(get(hObject,'string'));
fnUpdateNumberOfTRS(handles);
setappdata(handles.figure1,'strctParams',strctParams);


% --- Executes during object creation, after setting all properties.
function hNumTREdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hNumTREdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hImageTimeEdit_Callback(hObject, eventdata, handles)
strctParams = getappdata(handles.figure1,'strctParams');
strctParams.m_fImageTimeMS = str2num(get(hObject,'string'));
fnUpdateNumberOfTRS(handles);
setappdata(handles.figure1,'strctParams',strctParams);



% --- Executes during object creation, after setting all properties.
function hImageTimeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hImageTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hNumTRs_Callback(hObject, eventdata, handles)
% hObject    handle to hNumTRs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hNumTRs as text
%        str2double(get(hObject,'String')) returns contents of hNumTRs as a double


% --- Executes during object creation, after setting all properties.
function hNumTRs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hNumTRs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%



function hPTBScreenID_Callback(hObject, eventdata, handles)


function hPTBScreenID_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

 

function fnLoadTextures(handles)
global g_strctDraw
strctExperiment = getappdata(handles.figure1,'strctExperiment');
set(handles.hStatus,'String','Loading textures...');
drawnow
[g_strctDraw.m_ahHandles,g_strctDraw.m_a2iTextureSize,...
    g_strctDraw.m_abIsMovie,g_strctDraw.m_aiApproxNumFrames, g_strctDraw.m_afMovieLengthSec] = ...
    fnInitializeTexturesAux(strctExperiment.m_acFileNames);
return;


function [aiImageList,afDisplayTimeMS]= fnPrepareRunList(handles)
global g_strctDraw
strctExperiment = getappdata(handles.figure1,'strctExperiment');
strctParams = getappdata(handles.figure1,'strctParams');

aiImageList = [];

afDisplayTimeMS = [];
%iTotalTRs = length(strctExperiment.m_acBlocks) * strctParams.m_iNumTRsPerBlock;
iNumBlocks = length(strctExperiment.m_acBlocks);
for k=1:iNumBlocks
    iBlockIndex = find(ismember(lower(strctExperiment.m_acBlockNames), lower(strctExperiment.m_acBlocks{k})));
    aiIndices = strctExperiment.m_acImageIndices{iBlockIndex};
    
    fTimePerBlockMS = strctParams.m_iNumTRsPerBlock* strctParams.m_fTR_MS;
    iNumImagesToDisplay = floor(fTimePerBlockMS / strctParams.m_fImageTimeMS);
    
    fTime = 0;
    iImageCounter = 1;
    iAllImagesInBlockCounter = 0;
    while fTime < fTimePerBlockMS
        aiImageList = [aiImageList, aiIndices(iImageCounter)];
        if g_strctDraw.m_abIsMovie(aiIndices(iImageCounter))
            fDisplayTime = g_strctPTB.m_afMovieLengthSec(aiIndices(iImageCounter))*1e3;
        else
            fDisplayTime = strctParams.m_fImageTimeMS;
        end
        
        afDisplayTimeMS = [afDisplayTimeMS,fDisplayTime ];
        iImageCounter = iImageCounter + 1;
        iAllImagesInBlockCounter = iAllImagesInBlockCounter + 1;
        if iImageCounter > length(aiIndices)
            iImageCounter = 1;
        end
        fTime = fTime + fDisplayTime;
    end
    if fTime > fTimePerBlockMS
        fDiff = fTimePerBlockMS-fTime;
        afDisplayTimeMS(end) = afDisplayTimeMS(end) + fDiff;
    end
%     if iAllImagesInBlockCounter < length(aiIndices)
%         fprintf('Warning, not all images can be displayed with these parameters...\n');
%     end
end

return;


function hRunTime_Callback(hObject, eventdata, handles)
function hRunTime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%

function hLoadExperiment_Callback(hObject, eventdata, handles)
[strFile, strPath] = uigetfile('*.txt');
if strFile(1) == 0
    return;
end;

strExperimentFile = [strPath,strFile];
[acNames] = textread(strExperimentFile,'%s');
strImageList = acNames{1};
strBlockList = acNames{2};
strRunList = acNames{3};

[acFileNames, acFileNamesNoPath] = fnLoadMRIStyleImageList(strImageList);

[acImageIndices,acBlockNames] = fnLoadMRIStyleBlockList(strBlockList);
acBlocks = fnLoadBlockOrderListTextFile(strRunList);

strctExperiment.m_acFileNamesNoPath = acFileNamesNoPath;
strctExperiment.m_acFileNames = acFileNames;
strctExperiment.m_acImageIndices = acImageIndices;
strctExperiment.m_acBlockNames= acBlockNames;
strctExperiment.m_acBlocks= acBlocks;

setappdata(handles.figure1,'strctExperiment',strctExperiment);
set(handles.hBlockList,'string',acBlocks,'value',1);
set(handles.hStatus,'String',sprintf('%s loaded!',strFile),'fontsize',9);

fnUpdateNumberOfTRS(handles);
return;

function fnUpdateNumberOfTRS(handles)
strctExperiment = getappdata(handles.figure1,'strctExperiment');
strctParams = getappdata(handles.figure1,'strctParams');

iNumBlocks = length(strctExperiment.m_acBlocks);
iNumTRsPerBlock = strctParams.m_iNumTRsPerBlock;
iTotalNumTRs = iNumTRsPerBlock*iNumBlocks;
fTotalTimeSec = strctParams.m_fTR_MS * iTotalNumTRs / 1e3;
iNumMinutes = floor(fTotalTimeSec/60);
iNumSeconds =  round(fTotalTimeSec-iNumMinutes*60);
set(handles.hNumTRs,'string',num2str(iTotalNumTRs));
set(handles.hRunTime,'string',sprintf('%d Min, %d Sec', iNumMinutes,iNumSeconds));
return;




function fnClosePTB(handles)
global g_strctPTB g_strctDraw
if ~isempty(g_strctDraw)
    aiMovieHandles = find(g_strctDraw.m_abIsMovie);
    for k=1:length(aiMovieHandles)
        Screen('CloseMovie', g_strctDraw.m_ahHandles(aiMovieHandles(k)));
    end
    Screen('Close',g_strctDraw.m_ahHandles(~g_strctDraw.m_abIsMovie));
end
Screen('CloseAll');
g_strctPTB= [];
return;


function fnInitializePTB(handles)
global g_strctPTB
g_strctPTB.m_iScreenIndex = get(handles.hPTBScreenID,'value') - 1;
g_strctPTB.m_bNonRectMakeTexture = true;
set(handles.hStatus,'String','Opening PTB Window...');
drawnow
[g_strctPTB.m_hWindow, g_strctPTB.m_aiScreenRect] = Screen('OpenWindow',g_strctPTB.m_iScreenIndex,[0 0 0]);
g_strctPTB.m_iRefreshRate =Screen('FrameRate', g_strctPTB.m_iScreenIndex);

return;

function hStartExp_Callback(hObject, eventdata, handles)
global g_strctServerCycle
strctExperiment = getappdata(handles.figure1,'strctExperiment');
if isempty(strctExperiment)
    h=errordlg('Please load an experiment!');
    waitfor(h);
    return;
end;

strctParams = getappdata(handles.figure1,'strctParams');

g_strctServerCycle.m_iMachineState = 0;
ESC = 27;
fnInitializePTB(handles);
fnLoadTextures(handles);
[aiImageList,afDisplayTimeMS]= fnPrepareRunList(handles);
set(handles.hStatus,'String','Waiting for MRI trigger...');
drawnow

fTimer = GetSecs();
while (1)
    fnParadigmBlockDesignDrawCycle([]);

    [keyIsDown, secs, keyCode] = KbCheck; % 0.15 ms (!)
    if keyIsDown
        if keyCode(strctParams.m_iTriggerKey) && g_strctServerCycle.m_iMachineState == 0
           set(handles.hStatus,'String','trigger detected. Starting experiment!');
           fnParadigmBlockDesignDrawCycle({'DisplayList',aiImageList,afDisplayTimeMS, strctParams.m_iFixationRadius, strctParams.m_iImageSizePix/2 - 1,0 })
        end
        
        if keyCode(ESC)
            break;
        end
        if g_strctServerCycle.m_iMachineState  == 0 && GetSecs()-fTimer > 1
            fTimer  = GetSecs();
            drawnow
        end
    end
end
fnClosePTB(handles);
set(handles.hStatus,'String','Experiment Stopped!');
return;



function hImageSizePixEdit_Callback(hObject, eventdata, handles)
strctParams = getappdata(handles.figure1,'strctParams');
strctParams.m_iImageSizePix = str2num(get(hObject,'string'));
setappdata(handles.figure1,'strctParams',strctParams);


% --- Executes during object creation, after setting all properties.
function hImageSizePixEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hImageSizePixEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hFixationSpotRadiusEdit_Callback(hObject, eventdata, handles)
strctParams = getappdata(handles.figure1,'strctParams');
strctParams.m_iFixationRadius = str2num(get(hObject,'string'));
setappdata(handles.figure1,'strctParams',strctParams);

% --- Executes during object creation, after setting all properties.
function hFixationSpotRadiusEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hFixationSpotRadiusEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hTriggerKey_Callback(hObject, eventdata, handles)
strctParams = getappdata(handles.figure1,'strctParams');
strctParams.m_iTriggerKey = str2num(get(hObject,'string'));
setappdata(handles.figure1,'strctParams',strctParams);


% --- Executes during object creation, after setting all properties.
function hTriggerKey_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hTriggerKey (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
