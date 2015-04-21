function varargout = InteractiveBrainMask(varargin)
% INTERACTIVEBRAINMASK MATLAB code for InteractiveBrainMask.fig
%      INTERACTIVEBRAINMASK, by itself, creates a new INTERACTIVEBRAINMASK or raises the existing
%      singleton*.
%
%      H = INTERACTIVEBRAINMASK returns the handle to a new INTERACTIVEBRAINMASK or the handle to
%      the existing singleton*.
%
%      INTERACTIVEBRAINMASK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INTERACTIVEBRAINMASK.M with the given input arguments.
%
%      INTERACTIVEBRAINMASK('Property','Value',...) creates a new INTERACTIVEBRAINMASK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before InteractiveBrainMask_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to InteractiveBrainMask_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help InteractiveBrainMask

% Last Modified by GUIDE v2.5 15-Dec-2011 14:30:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @InteractiveBrainMask_OpeningFcn, ...
                   'gui_OutputFcn',  @InteractiveBrainMask_OutputFcn, ...
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


% --- Executes just before InteractiveBrainMask is made visible.
function InteractiveBrainMask_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to InteractiveBrainMask (see VARARGIN)

% Choose default command line output for InteractiveBrainMask
handles.output = hObject;
strBoldFolder = varargin{1};

strMaskFile = [strBoldFolder,'/masks/brain_mask.nii'];
setappdata(handles.figure1,'strMaskFile',strMaskFile);
strIntensityVolumeFile = [strBoldFolder,'/MOCOVOL/mocovolu.nii'];

% Read the two files.
set(handles.hOverlayMask,'value',1);

strctMask = MRIread(strMaskFile);
strctIntensity= MRIread(strIntensityVolumeFile);
a3fDistOut = bwdist(strctMask.vol);
a3fDistIn = bwdist(~strctMask.vol);
a3fDist = a3fDistOut;
a3fDist(strctMask.vol>0) = -a3fDistIn(strctMask.vol>0);
setappdata(handles.figure1,'a3fDist',a3fDist);

setappdata(handles.figure1,'iDilationErosion',0);

setappdata(handles.figure1,'strctMask',strctMask);
setappdata(handles.figure1,'strctIntensity',strctIntensity);


iNumSlices = strctIntensity.volsize(3);
iWidth = strctIntensity.volsize(2);
iHeight = strctIntensity.volsize(1);
iNumHoriz = ceil(sqrt(iNumSlices));
iNumVert = ceil(iNumSlices/iNumHoriz);
I = zeros(iHeight * iNumVert,iWidth *iNumHoriz,3);
hImage = image([],[],I,'parent',handles.axes1);
setappdata(handles.figure1,'hImage',hImage);

Is = zeros(iHeight,iWidth,3);
hImage2 = image([],[],Is,'parent',handles.axes2);

setappdata(handles.figure1,'hImage2',hImage2);

setappdata(handles.figure1,'iCurrentSlice',1);

set(handles.hSlices,'min',1,'max',iNumSlices,'value',1);

set(handles.axes1,'visible','off');
set(handles.axes2,'visible','off');
fnInvalidate(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes InteractiveBrainMask wait for user response (see UIRESUME)
uiwait(handles.figure1);
if ishandle(handles.figure1)
    delete(handles.figure1);
end
return;


function fnInvalidate(handles)
% Draw everything....
strctMask = getappdata(handles.figure1,'strctMask');
strctIntensity = getappdata(handles.figure1,'strctIntensity');
hImage = getappdata(handles.figure1,'hImage');
hImage2 = getappdata(handles.figure1,'hImage2');

iNumSlices = strctIntensity.volsize(3);
iWidth = strctIntensity.volsize(2);
iHeight = strctIntensity.volsize(1);
iNumHoriz = ceil(sqrt(iNumSlices));
iNumVert = ceil(iNumSlices/iNumHoriz);

iCurrentSlice = getappdata(handles.figure1,'iCurrentSlice');
bOverlay = get(handles.hOverlayMask,'value');

fScale = 1/max(strctIntensity.vol(:));
I = zeros(iHeight * iNumVert,iWidth *iNumHoriz,3);
for i=1:iNumVert
    for j=1:iNumHoriz
        %[i,j]
        iSlice = (i-1)*iNumHoriz + j;
        if iSlice> iNumSlices
            break;
        end
        Fuse = strctIntensity.vol(:,:,iSlice)*fScale;
        a2bMask = strctMask.vol(:,:,iSlice);
        I( (i-1)*iHeight+1:(i)*iHeight, (j-1)*iWidth+1:(j)*iWidth,1) = Fuse;
        I( (i-1)*iHeight+1:(i)*iHeight, (j-1)*iWidth+1:(j)*iWidth,2) = Fuse;
        if bOverlay
            I( (i-1)*iHeight+1:(i)*iHeight, (j-1)*iWidth+1:(j)*iWidth,3) = a2bMask;
        else
            I( (i-1)*iHeight+1:(i)*iHeight, (j-1)*iWidth+1:(j)*iWidth,3) = Fuse;
        end
        if iSlice == iCurrentSlice
        I( (i-1)*iHeight+1:(i)*iHeight, (j-1)*iWidth+1:(j-1)*iWidth+3,1) = 1;
        I( (i-1)*iHeight+1:(i-1)*iHeight+3, (j-1)*iWidth+1:(j)*iWidth,1) = 1;

        I( (i)*iHeight-2:(i)*iHeight, (j-1)*iWidth+1:(j)*iWidth,1) = 1;
        
        I( (i-1)*iHeight+1:(i)*iHeight, (j)*iWidth-2:(j)*iWidth,1) = 1;
        
            
            Is(:,:,1) = Fuse;
            Is(:,:,2) = Fuse;
            Is(:,:,3) = a2bMask;
        end
        
    end
end

set(hImage,'cdata',I);
set(hImage2,'cdata',Is);

return;


% --- Outputs from this function are returned to the command line.
function varargout = InteractiveBrainMask_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;



% --- Executes on button press in hOverlayMask.
function hOverlayMask_Callback(hObject, eventdata, handles)
 fnInvalidate(handles)

% --- Executes on button press in hExit.
function hExit_Callback(hObject, eventdata, handles)
uiresume(gcbf);

% --- Executes on slider movement.
function hSlices_Callback(hObject, eventdata, handles)
iIndex = get(hObject,'value');
setappdata(handles.figure1,'iCurrentSlice',round(iIndex));
fnInvalidate(handles);
return;

% --- Executes during object creation, after setting all properties.
function hSlices_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hSlices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in hSave.
function hSave_Callback(hObject, eventdata, handles)
strctMask = getappdata(handles.figure1,'strctMask');
strMaskFile=getappdata(handles.figure1,'strMaskFile');
fprintf('Writing new mask to %s\n',strMaskFile);
MRIwrite(strctMask,strMaskFile);
uiresume(gcbf);
return;

% --- Executes on button press in hDilate.
function hDilate_Callback(hObject, eventdata, handles)
strctMask = getappdata(handles.figure1,'strctMask');
a3fDist= getappdata(handles.figure1,'a3fDist');
iDilationErosion=getappdata(handles.figure1,'iDilationErosion');
iDilationErosion=iDilationErosion+1;
strctMask.vol = a3fDist < iDilationErosion;
setappdata(handles.figure1,'iDilationErosion',iDilationErosion);
setappdata(handles.figure1,'strctMask',strctMask);
fnInvalidate(handles)

return;

% --- Executes on button press in hErode.
function hErode_Callback(hObject, eventdata, handles)
strctMask = getappdata(handles.figure1,'strctMask');
a3fDist= getappdata(handles.figure1,'a3fDist');
iDilationErosion=getappdata(handles.figure1,'iDilationErosion');
iDilationErosion=iDilationErosion-1;
setappdata(handles.figure1,'iDilationErosion',iDilationErosion);
strctMask.vol = a3fDist < iDilationErosion;
setappdata(handles.figure1,'strctMask',strctMask);
fnInvalidate(handles);
return;


% --- Executes on button press in hMoveUp.
function hMoveUp_Callback(hObject, eventdata, handles)
strctMask = getappdata(handles.figure1,'strctMask');
a3fDist = getappdata(handles.figure1,'a3fDist');
for k=1:size(strctMask.vol,3)
    a2bMoved = strctMask.vol(:,:,k);
    a2bMoved = [a2bMoved(2:end,:); a2bMoved(1,:)];
    strctMask.vol(:,:,k) = a2bMoved;
    
    a2bMoved = a3fDist(:,:,k);
    a2bMoved = [a2bMoved(2:end,:); a2bMoved(1,:)];
    a3fDist(:,:,k) = a2bMoved;
end
setappdata(handles.figure1,'strctMask',strctMask);
setappdata(handles.figure1,'a3fDist',a3fDist);

fnInvalidate(handles);
return;


% --- Executes on button press in hMoveRight.
function hMoveRight_Callback(hObject, eventdata, handles)
strctMask = getappdata(handles.figure1,'strctMask');
a3fDist = getappdata(handles.figure1,'a3fDist');

for k=1:size(strctMask.vol,3)
    a2bMoved = strctMask.vol(:,:,k);
    a2bMoved = [a2bMoved(:,end), a2bMoved(:,1:end-1)];
    strctMask.vol(:,:,k) = a2bMoved;


    a2bMoved = a3fDist(:,:,k);
    a2bMoved = [a2bMoved(:,end), a2bMoved(:,1:end-1)];
    a3fDist(:,:,k) = a2bMoved;

end
setappdata(handles.figure1,'strctMask',strctMask);
setappdata(handles.figure1,'a3fDist',a3fDist);


fnInvalidate(handles);
return;

% --- Executes on button press in hMoveDown.
function hMoveDown_Callback(hObject, eventdata, handles)
strctMask = getappdata(handles.figure1,'strctMask');
a3fDist = getappdata(handles.figure1,'a3fDist');

for k=1:size(strctMask.vol,3)
    a2bMoved = strctMask.vol(:,:,k);
    a2bMoved = [a2bMoved(end,:);a2bMoved(1:end-1,:)];
    strctMask.vol(:,:,k) = a2bMoved;
    
    a2bMoved = a3fDist(:,:,k);
    a2bMoved = [a2bMoved(end,:);a2bMoved(1:end-1,:)];
    a3fDist(:,:,k) = a2bMoved;
    
end
setappdata(handles.figure1,'strctMask',strctMask);
setappdata(handles.figure1,'a3fDist',a3fDist);


fnInvalidate(handles);
return;


% --- Executes on button press in hMoveLeft.
function hMoveLeft_Callback(hObject, eventdata, handles)
strctMask = getappdata(handles.figure1,'strctMask');
a3fDist = getappdata(handles.figure1,'a3fDist');

for k=1:size(strctMask.vol,3)
    a2bMoved = strctMask.vol(:,:,k);
    a2bMoved = [a2bMoved(:,2:end-1), a2bMoved(1,:)];
    strctMask.vol(:,:,k) = a2bMoved;
    
    a2bMoved = a3fDistl(:,:,k);
    a2bMoved = [a2bMoved(:,2:end-1), a2bMoved(1,:)];
    a3fDist(:,:,k) = a2bMoved;
    
end
setappdata(handles.figure1,'strctMask',strctMask);
setappdata(handles.figure1,'a3fDist',a3fDist);


fnInvalidate(handles);
return;
