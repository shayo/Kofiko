function fnStopRecording(fDelaySec)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
%
global g_strctDAQParams g_strctSystemCodes g_bRecording g_handles g_strctParadigm g_strctRealTimeStatServer g_strctRecordingInfo g_strctAcquisitionServer g_strctAppConfig

fnParadigmToKofikoComm('JuiceOff');
fnDAQWrapper('StrobeWord', g_strctSystemCodes.m_iStopRecord);

if isfield(g_strctAppConfig,'m_strctAcquisitionServer') && g_strctAcquisitionServer.m_bConnected
        fndllZeroMQ_Wrapper('Send',g_strctAcquisitionServer.m_iSocket,['KofikoStopRecordSession ',num2str(g_strctRecordingInfo.m_iSession)]);
        fndllZeroMQ_Wrapper('Send',g_strctAcquisitionServer.m_iSocket,'StopRecord');
        
elseif strcmpi(g_strctAppConfig.m_strctDAQ.m_strAcqusitionCard,'mc')
    WaitSecs(fDelaySec); % give some time for the plexon system to start recording
    fnDAQWrapper('SetBit',g_strctDAQParams.m_fStartRecordPort, 0);
end
fnLog('Stopping recording');
g_bRecording = false;

if g_strctRealTimeStatServer.m_bConnected
    mssend(g_strctRealTimeStatServer.m_iSocket,{'PlexonFrameEnd',g_strctRecordingInfo.m_iSession,GetSecs()});
end

set(g_handles.hRecordButton,'String','Record','fontweight','normal');
set(g_handles.hParadigmShift,'enable','on');
eval([g_strctParadigm.m_strCallbacks,'(''StopRecording'');']);
[fLocalTime, fServerTime, fJitter] = fnSyncClockWithStimulusServer(100);
g_strctDAQParams = fnTsSetVar(g_strctDAQParams,'StimulusServerSync',[fLocalTime,fServerTime,fJitter]);
return;
