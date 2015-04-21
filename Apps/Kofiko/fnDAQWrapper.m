function Out = fnDAQWrapper(strCommand, varargin)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctDAQParams   g_strctAppConfig g_strctPTB g_strctAcquisitionServer
if strcmp(g_strctAppConfig.m_strctDAQ.m_strAcqusitionCard,'mc')
    
    fCurrTime = GetSecs();
    if ~g_strctAppConfig.m_strctDAQ.m_fVirtualDAQ
        Out = fnDAQ(strCommand, varargin{:});
    else 
        Out = 1;
    end
    
    if g_strctDAQParams.m_bMouseGazeEmulator && strcmp(strCommand,'GetAnalog')
        try
            [x,y] = GetMouse(g_strctPTB.m_iScreenIndex);  % This takes 0.06 ms
        catch
            x = NaN;
            y= NaN;
        end
            aiRequiredValues = varargin{1};
            Out = zeros(1,max(aiRequiredValues));
            Out(aiRequiredValues == g_strctDAQParams.m_fEyePortX) = x/g_strctPTB.m_fScale;
            Out(aiRequiredValues == g_strctDAQParams.m_fEyePortY) = y/g_strctPTB.m_fScale;% Simulate eye position using the mouse
    end;
    
    
    
   if strcmpi(strCommand,'TTL')
        if ~isfield(g_strctDAQParams,'TTLlog')
            iTTLBuffer = 2^18;
            g_strctDAQParams = fnTsAddVar(g_strctDAQParams,'TTLlog',varargin{1} , iTTLBuffer);
        else
            
            iLastEntry = g_strctDAQParams.TTLlog.BufferIdx;
            if iLastEntry+1 > g_strctDAQParams.TTLlog.BufferSize
                g_strctDAQParams.TTLlog = fnIncreaseBufferSize(g_strctDAQParams.TTLlog);
            end;
            iDuration = varargin{1};
            
            g_strctDAQParams.TTLlog.Buffer(:,:,iLastEntry+1) = iDuration;
            g_strctDAQParams.TTLlog.TimeStamp(iLastEntry+1) = fCurrTime;
            g_strctDAQParams.TTLlog.BufferIdx = iLastEntry+1;
        end;
    end;    
    
    if strcmpi(strCommand,'StrobeWord')
        if ~isfield(g_strctDAQParams,'LastStrobe')
            iStrobeWordBuffer = 2^18;
            g_strctDAQParams = fnTsAddVar(g_strctDAQParams,'LastStrobe',varargin{1} , iStrobeWordBuffer);
        else
            
            iLastEntry = g_strctDAQParams.LastStrobe.BufferIdx;
            if iLastEntry+1 > g_strctDAQParams.LastStrobe.BufferSize
                g_strctDAQParams.LastStrobe = fnIncreaseBufferSize(g_strctDAQParams.LastStrobe);
            end;
            iValueToSend = varargin{1};
            
            g_strctDAQParams.LastStrobe.Buffer(:,:,iLastEntry+1) = iValueToSend;
            g_strctDAQParams.LastStrobe.TimeStamp(iLastEntry+1) = fCurrTime;
            g_strctDAQParams.LastStrobe.BufferIdx = iLastEntry+1;
        end;
    end;
elseif strcmpi(g_strctAppConfig.m_strctDAQ.m_strAcqusitionCard,'arduino')     
    fCurrTime = GetSecs();
    switch strCommand
        case 'Init'
            Out= fnInitializeSerialPortforArduino();
        case 'StrobeWord'
            % Strobe word needs to be send over the network to Kofiko - Intan
                iValueToSend = varargin{1};
            if g_strctAcquisitionServer.m_bConnected
                       fndllZeroMQ_Wrapper('Send',g_strctAcquisitionServer.m_iSocket,['Strobe ',num2str(iValueToSend)]);
            end
            if ~isfield(g_strctDAQParams,'LastStrobe')
                iStrobeWordBuffer = 2^18;
                g_strctDAQParams = fnTsAddVar(g_strctDAQParams,'LastStrobe',varargin{1} , iStrobeWordBuffer);
            else
                iLastEntry = g_strctDAQParams.LastStrobe.BufferIdx;
                if iLastEntry+1 > g_strctDAQParams.LastStrobe.BufferSize
                    g_strctDAQParams.LastStrobe = fnIncreaseBufferSize(g_strctDAQParams.LastStrobe);
                end;
                g_strctDAQParams.LastStrobe.Buffer(:,:,iLastEntry+1) = iValueToSend;
                g_strctDAQParams.LastStrobe.TimeStamp(iLastEntry+1) = fCurrTime;
                g_strctDAQParams.LastStrobe.BufferIdx = iLastEntry+1;
            end;
        case 'SetBit'
            iPort =  varargin{1};
            iBitValue = varargin{2};
            IOPort('Write',  g_strctDAQParams.m_hArduino , [sprintf('setbit %d %d',iPort, iBitValue),10]);
        case 'TTL'
           iPort =  varargin{1};
           fLengthSec = varargin{2};
            IOPort('Write',  g_strctDAQParams.m_hArduino , [sprintf('pulse %d %d',iPort, round(1e6*fLengthSec)),10]); % Value passed in Microsec
        case 'GetAnalog'
            
        otherwise
            assert(false);
    end
    
%     if g_strctDAQParams.m_bMouseGazeEmulator && strcmp(strCommand,'GetAnalog')
%         try
%             [x,y] = GetMouse(g_strctPTB.m_iScreenIndex);  % This takes 0.06 ms
%         catch
%             x = NaN;
%             y= NaN;
%         end
%             aiRequiredValues = varargin{1};
%             Out = zeros(1,max(aiRequiredValues));
%             Out(aiRequiredValues == g_strctDAQParams.m_fEyePortX) = x/g_strctPTB.m_fScale;
%             Out(aiRequiredValues == g_strctDAQParams.m_fEyePortY) = y/g_strctPTB.m_fScale;% Simulate eye position using the mouse
%     end;
%     
%     if strcmpi(strCommand,'StrobeWord')
%     

    
    
elseif strcmp(g_strctAppConfig.m_strctDAQ.m_strAcqusitionCard,'redbox')
   
  if strcmpi(strCommand,'StrobeWord')
        if ~isfield(g_strctDAQParams,'LastStrobe')
            iStrobeWordBuffer = 100000;
            g_strctDAQParams = fnTsAddVar(g_strctDAQParams,'LastStrobe',varargin{1} , iStrobeWordBuffer);
        else
             fCurrTime = GetSecs();
            iLastEntry = g_strctDAQParams.LastStrobe.BufferIdx;
            if iLastEntry+1 > g_strctDAQParams.LastStrobe.BufferSize
                g_strctDAQParams.LastStrobe = fnIncreaseBufferSize(g_strctDAQParams.LastStrobe);
            end;
            g_strctDAQParams.LastStrobe.Buffer(:,:,iLastEntry+1) = varargin{1};
            g_strctDAQParams.LastStrobe.TimeStamp(iLastEntry+1) = fCurrTime;
            g_strctDAQParams.LastStrobe.BufferIdx = iLastEntry+1;
        end; 
  else
    Out = fnDAQRedBox(strCommand, varargin{:});
  end
  
end

return;
