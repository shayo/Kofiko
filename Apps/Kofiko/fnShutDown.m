function fnShutDown()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctDAQParams g_strctPTB g_strctStimulusServer g_hLogFileID  g_strctAppConfig g_abParadigmInitialized g_astrctAllParadigms  
global g_strctParadigm g_strctRealTimeStatServer g_bRecording g_strctAcquisitionServer

if  g_bRecording
    fnStopRecording(0);
end

if ~isempty(g_strctDAQParams) && strcmpi(g_strctDAQParams.m_strEyeSignalInput,'Serial')
    fnCloseSerialPortforISCAN();
end
if ~isempty(g_strctAppConfig) && strcmpi(g_strctAppConfig.m_strctDAQ.m_strAcqusitionCard,'arduino')     
    fnCloseSerialPortforArduino();
end


% Call "Close Function" for all initialized paradigms.
for k=find(g_abParadigmInitialized)
    g_strctParadigm = g_astrctAllParadigms{k};
    feval(g_strctParadigm.m_strClose);
    g_astrctAllParadigms{k} = g_strctParadigm;
end

fnLog('Closing local PTB Screen');
try
    PsychPortAudio('Close', g_strctPTB.m_hAudioDevice);
catch
end

if ~isempty(g_strctPTB)
    try
        Screen('CloseAll');%,g_strctPTB.m_hWindow);
    catch
        fnLog('Failed to close PTB Screen');
    end;
end;

if ~isempty(g_strctAppConfig) && g_strctAppConfig.m_strctVarSave.m_fWaterLevelUponExit
    
    prompt={'How much water was left in the bottle?'};
    name='Last question before exit';
    numlines=1;
    defaultanswer={'0'};
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    if ~isempty(answer)
        g_strctAppConfig.m_strctOtherInfo.m_fFinalLiquidLevel = answer{1};
    else
        g_strctAppConfig.m_strctOtherInfo.m_fFinalLiquidLevel = 0;
    end
else
    g_strctAppConfig.m_strctOtherInfo.m_fFinalLiquidLevel = [];
end


fnLog('Writing information to disk...');
fnSaveParadigmsToDisk(true);

fnLog('Closing connection to stimulus server');
if ~isempty(g_strctStimulusServer) && isfield(g_strctStimulusServer,'m_iSocket');
    fnParadigmToStimulusServer('CloseConnection');
    msclose(g_strctStimulusServer.m_iSocket);
end;

fnLog('Closing connection to real time stat server');
if isfield(g_strctRealTimeStatServer,'m_bConnected') && g_strctRealTimeStatServer.m_bConnected 
    fnParadigmToStatServerComm('CloseConnection');
    msclose(g_strctRealTimeStatServer.m_iSocket);
end

if ~isempty(g_strctAcquisitionServer) && (g_strctAcquisitionServer.m_bConnected)
  fndllZeroMQ_Wrapper('CloseThread',g_strctAcquisitionServer.m_iSocket);
end

ahHandles = get(0,'Children');
for k=1:length(ahHandles)
    if strncmpi(get(ahHandles(k),'Name'),'Kofiko',6)
        delete(ahHandles(k));
    end;
end

% Close Nano Stimulator
try
   ChipKitStimGUI_Serial('Shutdown');
catch
end

if ~isempty(g_hLogFileID)
    fclose(g_hLogFileID);
    g_hLogFileID = [];
end;

%clear mex % this will close all ports....
%fnUnRegisterAdvancers();
return;



function fnUnRegisterAdvancers()
global g_strctDAQParams 
if ~isempty(g_strctDAQParams)
    iNumAdvancers = length(g_strctDAQParams.m_a2iAdvancerMappingToChamberHole);
    %if iNumAdvancers > 0
        fndllMiceHook('Release');
    %end
end
return;