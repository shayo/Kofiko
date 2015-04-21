function bOK = fnStartRecording(fDelaySec)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
global g_strctDAQParams g_strctSystemCodes g_bRecording g_handles g_strctRecordingInfo g_strctParadigm g_strctRealTimeStatServer 
global g_strctAppConfig g_strctAcquisitionServer g_strLogFileName
bOK = false;
if isfield(g_strctAppConfig,'m_strctAcquisitionServer') && g_strctAcquisitionServer.m_bConnected
    % Recording with Intan
    % We don't use TTL triggers to start recording, but Ethernet instead.
    if g_strctAcquisitionServer.m_bConnected
        
        
         [strPath,strSession,strExt] = fileparts(g_strLogFileName);
       fndllZeroMQ_Wrapper('Send',g_strctAcquisitionServer.m_iSocket,['SetSessionName ',strSession]);
       fndllZeroMQ_Wrapper('Send',g_strctAcquisitionServer.m_iSocket,'StartRecord');
       fndllZeroMQ_Wrapper('Send',g_strctAcquisitionServer.m_iSocket,['KofikoStartRecordSession ',num2str(g_strctRecordingInfo.m_iSession+1)]);
        
    else
        return;
    end
elseif strcmpi(g_strctAppConfig.m_strctDAQ.m_strAcqusitionCard,'mc')
    fnDAQWrapper('SetBit',g_strctDAQParams.m_fStartRecordPort, 1);
    WaitSecs(fDelaySec); % give some time for the plexon system to start recording
end

fnDAQWrapper('StrobeWord', g_strctSystemCodes.m_iStartRecord);
[fLocalTime, fServerTime, fJitter] = fnSyncClockWithStimulusServer(100);
g_strctDAQParams = fnTsSetVar(g_strctDAQParams,'StimulusServerSync',[fLocalTime,fServerTime,fJitter]);
fnLog('Started recording');
g_strctRecordingInfo.m_iSession = g_strctRecordingInfo.m_iSession +1;
g_strctRecordingInfo.m_fStart = GetSecs();

if g_strctRealTimeStatServer.m_bConnected
    mssend(g_strctRealTimeStatServer.m_iSocket,{'PlexonFrameStart',g_strctRecordingInfo.m_iSession,g_strctRecordingInfo.m_fStart});
end
g_bRecording = true;
set(g_handles.hRecordButton,'String','Stop Recording','fontweight','bold');
%set(g_handles.hParadigmShift,'enable','off');
eval([g_strctParadigm.m_strCallbacks,'(''StartRecording'');']);
bOK = true;
return;
