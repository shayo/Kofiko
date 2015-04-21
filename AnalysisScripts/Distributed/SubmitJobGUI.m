function varargout = SubmitJobGUI(varargin)
% SUBMITJOBGUI M-file for SubmitJobGUI.fig
%      SUBMITJOBGUI, by itself, creates a new SUBMITJOBGUI or raises the existing
%      singleton*.
%
%      H = SUBMITJOBGUI returns the handle to a new SUBMITJOBGUI or the handle to
%      the existing singleton*.
%
%      SUBMITJOBGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SUBMITJOBGUI.M with the given input arguments.
%
%      SUBMITJOBGUI('Property','Value',...) creates a new SUBMITJOBGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SubmitJobGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SubmitJobGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SubmitJobGUI

% Last Modified by GUIDE v2.5 17-Aug-2010 09:17:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SubmitJobGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SubmitJobGUI_OutputFcn, ...
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


% --- Executes just before SubmitJobGUI is made visible.
function SubmitJobGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SubmitJobGUI (see VARARGIN)

% Choose default command line output for SubmitJobGUI
handles.output = hObject;
strctConfig = varargin{1};
setappdata(handles.figure1,'strctConfig',strctConfig);
setappdata(handles.figure1,'acSessions',varargin{2});


fNow = now;
strTmp = datestr(fNow,25);
strDate = strTmp([1,2,4,5,7,8]);
strTmp = datestr(fNow,13);
strTime =  strTmp([1,2,4,5,7,8]);
strUniqueTimeDate = [strDate,'_',strTime];


set(handles.hJobNameEdit,'String',strUniqueTimeDate);

fnPopulateMachineList(handles);
fnPopulateAnalysisList(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SubmitJobGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

return;

function fnPopulateAnalysisList(handles)
strctConfig = getappdata(handles.figure1,'strctConfig');

iNumParadigms = length(strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis);
iCounter = 1;
clear astrctOptions
for iIter=1:iNumParadigms
   astrctOptions(iCounter).m_strName = [strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{iIter}.m_strctGeneral.m_strAnalysisDescription,' of Neural Data'];
   astrctOptions(iCounter).m_strEval = ['strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{',num2str(iIter),'}.m_strctGeneral.m_bActiveBehaviorAnalysis'];
   astrctOptions(iCounter).m_bValue = strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{iIter}.m_strctGeneral.m_bActiveNeuralAnalysis;
   iCounter = iCounter + 1;

   astrctOptions(iCounter).m_strName = [strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{iIter}.m_strctGeneral.m_strAnalysisDescription,' of Behavioral Data'];
   astrctOptions(iCounter).m_strEval = ['strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{',num2str(iIter),'}.m_strctGeneral.m_bActiveBehaviorAnalysis'];
   astrctOptions(iCounter).m_bValue = strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{iIter}.m_strctGeneral.m_bActiveBehaviorAnalysis;
   iCounter = iCounter + 1;
   
   if isfield(strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{iIter},'m_acSpecificAnalysis')
       iNumSubAnalysis = length(strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{iIter}.m_acSpecificAnalysis);
        if ~iscell(strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{iIter}.m_acSpecificAnalysis)
               strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{iIter}.m_acSpecificAnalysis = {strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{iIter}.m_acSpecificAnalysis};
        end
             
       for k=1:iNumSubAnalysis
            
           if isfield(strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{iIter}.m_acSpecificAnalysis{k},'m_strAnalysisDescription')
               astrctOptions(iCounter).m_strName = ['           ',strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{iIter}.m_acSpecificAnalysis{k}.m_strAnalysisDescription];
               astrctOptions(iCounter).m_strEval = ['strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{',num2str(iIter),'}.m_acSpecificAnalysis{',num2str(k),'}.m_strAnalysisDescription'];
               astrctOptions(iCounter).m_bValue = strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{iIter}.m_acSpecificAnalysis{k}.m_bActive;
               iCounter = iCounter + 1;
           else
               astrctOptions(iCounter).m_strName =  ['           ',strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{iIter}.m_acSpecificAnalysis{k}.m_strctParams.m_strAnalysisDescription];
               astrctOptions(iCounter).m_strEval = ['strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{',num2str(iIter),'}.m_acSpecificAnalysis{',num2str(k),'}.m_strctParams.m_strAnalysisDescription'];
               astrctOptions(iCounter).m_bValue = strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{iIter}.m_acSpecificAnalysis{k}.m_strctParams.m_bActive;
               iCounter = iCounter + 1;               
           end
           
       end
   end
end

aiSelectedAnalysis = find(cat(1,astrctOptions.m_bValue));
set(handles.hAnalysisListBox,'String',{astrctOptions.m_strName},'min',1,'max',iCounter-1,'value',aiSelectedAnalysis)
setappdata(handles.figure1,'strctConfig',strctConfig);
setappdata(handles.figure1,'astrctOptions',astrctOptions);
return;


function fnPopulateMachineList(handles)
astrctMachines = fnCondorStatus();
iNumMachines = length(astrctMachines);
if iNumMachines == 0
    setappdata(handles.figure1,'astrctMachines',[]);
    set(handles.hMachinesList,'String',[]);
    return;
end;

acMachines = cell(1,iNumMachines);
for iIter=1:iNumMachines
    acMachines{iIter} = sprintf('%15s %15s %15d MB',...
        astrctMachines(iIter).m_strName,...
        astrctMachines(iIter).m_strState,...
        astrctMachines(iIter).m_iMemory);
end
set(handles.hMachinesList,'String',acMachines,'value',1:iNumMachines,'min',1,'max',iNumMachines);
setappdata(handles.figure1,'astrctMachines',astrctMachines);
return;



% --- Outputs from this function are returned to the command line.
function varargout = SubmitJobGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in hMachinesList.
function hMachinesList_Callback(hObject, eventdata, handles)
% hObject    handle to hMachinesList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns hMachinesList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hMachinesList


% --- Executes during object creation, after setting all properties.
function hMachinesList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hMachinesList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in hAnalysisListBox.
function hAnalysisListBox_Callback(hObject, eventdata, handles)
astrctOptions = getappdata(handles.figure1,'astrctOptions');
strctConfig = getappdata(handles.figure1,'strctConfig');
aiSelectedOptions = get(hObject,'value');

for k=1:length(astrctOptions)
    if sum(k == aiSelectedOptions) > 0
        eval([astrctOptions(k).m_strEval,' = true;']);
    else
        eval([astrctOptions(k).m_strEval,' = false;']);
    end
end
setappdata(handles.figure1,'strctConfig',strctConfig);
return;

% --- Executes during object creation, after setting all properties.
function hAnalysisListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hAnalysisListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% 
% clear strctAnalysisCollectUnitStats
% strctAnalysisCollectUnitStats.m_strAnalysisScript = 'fnCollectBehaviorStatsWorker';
% strctAnalysisCollectUnitStats.m_acParams{1} = '100719_174953_Rocco.mat';
% strctAnalysisCollectUnitStats.m_acParams{2} = strctConfig;
% strctJob.m_strOutputFolder = '\\kofiko-23B\Units_From_Cluster\';
% strctJob.m_acAnalysis{2} = strctAnalysisCollectUnitStats;
% 
% 
% 
% save('.\CompiledWorker\Jobargin0.mat','strctJob');
%     
    



function hJobNameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to hJobNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hJobNameEdit as text
%        str2double(get(hObject,'String')) returns contents of hJobNameEdit as a double


% --- Executes during object creation, after setting all properties.
function hJobNameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hJobNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hCompileBeforeSubmit.
function hCompileBeforeSubmit_Callback(hObject, eventdata, handles)
% hObject    handle to hCompileBeforeSubmit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hCompileBeforeSubmit


% --- Executes on button press in hRunLocally.
function hRunLocally_Callback(hObject, eventdata, handles)
% hObject    handle to hRunLocally (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in hSubmitJobs.
function hSubmitJobs_Callback(hObject, eventdata, handles)
astrctMachines = getappdata(handles.figure1,'astrctMachines');
acSessions = getappdata(handles.figure1,'acSessions');
strctConfig = getappdata(handles.figure1,'strctConfig');

iNumSessions=length(acSessions);

% Generate a unique folder for this submission
strUniqueJobName = get(handles.hJobNameEdit,'String');
strSubmitFolder = [strctConfig.m_strctDistributedAnalysis.m_strJobsFolder, strUniqueJobName,'\'];
if ~exist(strSubmitFolder,'dir')
    mkdir(strSubmitFolder)
end

bRunLocal = get(handles.hRunLocally,'value');
astrctMachines = getappdata(handles.figure1,'astrctMachines');
aiSelectedMachines = get(handles.hMachinesList,'value');
acMachinesToUse = {astrctMachines(aiSelectedMachines).m_strName};
% 
% for k=1:length(acMachinesToUse)
%     eval(['!net session \\',acMachinesToUse{k},' /delete']);
% end

strJobOutputFolder = [strctConfig.m_strctDistributedAnalysis.m_strJobsFolder,strUniqueJobName];
try
    if ~exist(strJobOutputFolder,'dir')
        mkdir(strJobOutputFolder)
    end
catch
    h=msgbox(sprintf('Could not generate folder %s - Maybe you forgot to set the permissions?',strJobOutputFolder),'Critical Error');
    return;
end
bCompile = get(handles.hCompileBeforeSubmit,'value');
if  ~exist('.\CompiledWorker\Worker.exe','file') || bCompile
        fnCompileWorker();
end

try
    copyfile('.\CompiledWorker\Worker.exe',strSubmitFolder,'f')
    copyfile('.\CompiledWorker\Worker.ctf',strSubmitFolder,'f')
catch
    h=msgbox('Could not copy exeuctables to submit folder');
    waitfor(h);
    return;
end

bAtLeastOneBehavioralAnalysisIsActive = false;

acMachinesToUse = [];
for iSessionIter=1:iNumSessions
    
    if acSessions{iSessionIter}.m_iNumPlexonFiles > 0
        % Generate a "task" per recorded experiment
        iNumPlexonFiles = length(acSessions{iSessionIter}.m_acstrPlexonFileNames);
        acJobInputFileNames = cell(1,iNumPlexonFiles );
        for iPlexonFileIter=1:iNumPlexonFiles 
            acJobInputFileNames{iPlexonFileIter} = fnGenerateJobInputFileForNeuralAnalysis(strSubmitFolder,strJobOutputFolder,strctConfig,...
                acSessions{iSessionIter},iPlexonFileIter);
        end
        % Generate the submit file for this "job"
        strSubmitFileName = [strSubmitFolder,'submit_',acSessions{iSessionIter}.m_strUID,'.txt'];
        fnCreateCondorJob(strSubmitFileName, acSessions{iSessionIter}, iNumPlexonFiles,acMachinesToUse)
        
        if bRunLocal
            for iPlexonFileIter=1:iNumPlexonFiles 
                % copy files to job directory
                
                fnWorker(acJobInputFileNames{iPlexonFileIter},tempname,tempname);
                % copy output files to job directory
                
            end
        else
            % Submit the job to the cluster
            strPwd = pwd();
            try
                cd(strSubmitFolder);
                eval(sprintf('!condor_submit %s',['submit_',acSessions{iSessionIter}.m_strUID,'.txt']))
            catch
                hMsg = msgbox('Failed to submit jobs');
                waitfor(hMsg);
            end
            cd(strPwd);
        end
    end
    
    % Generate additional behavioral Job
    if bAtLeastOneBehavioralAnalysisIsActive
            fnGenerateJobInputFileForBehaviorAnalysis(strSubmitFolder,strctConfig,...
                strJobUniqueID, acSessions{iSessionIter});
    end
    
    
end

return;
