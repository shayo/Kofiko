function varargout = fMRI(varargin)
% FMRI MATLAB code for fMRI.fig
%      FMRI, by itself, creates a new FMRI or raises the existing
%      singleton*.
%
%      H = FMRI returns the handle to a new FMRI or the handle to
%      the existing singleton*.
%
%      FMRI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FMRI.M with the given input arguments.
%
%      FMRI('Property','Value',...) creates a new FMRI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fMRI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fMRI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fMRI

% Last Modified by GUIDE v2.5 07-Oct-2011 11:12:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fMRI_OpeningFcn, ...
                   'gui_OutputFcn',  @fMRI_OutputFcn, ...
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


% --- Executes just before fMRI is made visible.
function fMRI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fMRI (see VARARGIN)

% Choose default command line output for fMRI
handles.output = hObject;
dbstop if error
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fMRI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fMRI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in hUnpack.
function hUnpack_Callback(hObject, eventdata, handles)
UnpackGUI();

% --- Executes on button press in hPreprocessing.
function hPreprocessing_Callback(hObject, eventdata, handles)
FuncPreprocGUI();

% --- Executes on button press in hFuncAnal.
function hFuncAnal_Callback(hObject, eventdata, handles)
FuncAnalWrapper();

% --- Executes on button press in hMergeSessions.
function hMergeSessions_Callback(hObject, eventdata, handles)
% hObject    handle to hMergeSessions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hRegisterSessions.
function hRegisterSessions_Callback(hObject, eventdata, handles)
RegSessionsWrapper();
