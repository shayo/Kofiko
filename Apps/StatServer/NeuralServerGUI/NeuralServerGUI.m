function varargout = NeuralServerGUI(varargin)
% NEURALSERVERGUI M-file for NeuralServerGUI.fig
%      NEURALSERVERGUI, by itself, creates a new NEURALSERVERGUI or raises the existing
%      singleton*.
%
%      H = NEURALSERVERGUI returns the handle to a new NEURALSERVERGUI or the handle to
%      the existing singleton*.
%
%      NEURALSERVERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEURALSERVERGUI.M with the given input arguments.
%
%      NEURALSERVERGUI('Property','Value',...) creates a new NEURALSERVERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NeuralServerGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NeuralServerGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NeuralServerGUI

% Last Modified by GUIDE v2.5 05-May-2011 18:06:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NeuralServerGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @NeuralServerGUI_OutputFcn, ...
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


% --- Executes just before NeuralServerGUI is made visible.
function NeuralServerGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NeuralServerGUI (see VARARGIN)

% Choose default command line output for NeuralServerGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NeuralServerGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = NeuralServerGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in hOK.
function hOK_Callback(hObject, eventdata, handles)
% hObject    handle to hOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
