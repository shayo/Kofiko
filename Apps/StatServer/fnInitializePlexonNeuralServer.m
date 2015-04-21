function strctNeuralServer = fnInitializePlexonNeuralServer()
% Connect to mex plex and reterieve information about channels...
strctNeuralServer.m_bConnected = false;


try
    strctNeuralServer.m_hSocket = PL_InitClient(0);
catch
    strctNeuralServer.m_hSocket  = 0;
end
if strctNeuralServer.m_hSocket  == 0
    fnStatLog('Connection to neural server failed!');
    return;
end
% Query number of channels, etc...

pars = PL_GetPars(strctNeuralServer.m_hSocket);
strctNeuralServer.m_iNumSpikeChannels = pars(1);
strctNeuralServer.m_iNumberUnitsPerChannel = 4;

strctNeuralServer.m_fTimestampTick_usec = pars(2);
strctNeuralServer.m_fNumPointsInWaveform = pars(3);

strctNeuralServer.m_iNumChannels = pars(6);
strctNeuralServer.m_fAD_Freq = pars(8);
strctNeuralServer.m_fLastSampleTS = 0;

adenabledstart = 270;
maxcontchans = 256;
enabledchans = [];
for i = adenabledstart : adenabledstart+maxcontchans-1
    if (pars(i))
        enabledchans(i-adenabledstart+1) = pars(i);
    end
end
strctNeuralServer.m_aiEnabledChannels = enabledchans;



[iOK, Tmp]=system('.\MEX\win32\PlexRealTimeExe');
if iOK ~= 0
      fnStatLog('Connection to neural server failed!');
    return;
end
[acAttributes]=fnSplitString(Tmp, 10);
strctNeuralServer.m_acSpikeChannelNames=acAttributes(1:2:end);
strctNeuralServer.m_acAnalogChannelNames=acAttributes(2:2:end);
% iResult = PlexRealTime('InitPlexon');
% if iResult  ~= 1
%     fnStatLog('Connection to neural server failed!');
%     return;
% end
% 
% [strctNeuralServer.m_acSpikeChannelNames,strctNeuralServer.m_acAnalogChannelNames] = PlexRealTime('GetChannelNames');
% Try to automatically identify the active channels...

strctChannels = PlexonChannelGUI(strctNeuralServer.m_acSpikeChannelNames,strctNeuralServer.m_acAnalogChannelNames,strctNeuralServer.m_aiEnabledChannels);
if isempty(strctChannels)
    fprintf('Critical error!\n');
        strctNeuralServer = [];
        return;
    else
    strctNeuralServer.m_iNumActiveSpikeChannels =  sum(strctChannels.m_abActiveSpikeChannel );
    strctNeuralServer.m_aiActiveSpikeChannels = find(strctChannels.m_abActiveSpikeChannel);
    strctNeuralServer.m_aiSpikeToAnalogMapping = strctChannels.m_aiSpikeToAnalogMapping(strctChannels.m_abActiveSpikeChannel);
    strctNeuralServer.m_bConnected = true;
end

return;
