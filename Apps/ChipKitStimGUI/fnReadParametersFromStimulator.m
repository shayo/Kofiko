function [astrctChannel,acPresetNames] = fnReadParametersFromStimulator(hSocket)
fnClearMessageQueue(hSocket);

NUM_CHANNELS = 2;
NUM_PRESETS = 4;
UDP_GET_CURRENT_SETTINGS = 15;
UDP_GET_PRESET_NAMES = 16;

IOPort('Write',  hSocket , uint8([sprintf('%02d',UDP_GET_CURRENT_SETTINGS),10]));
for iChannel=1:NUM_CHANNELS
    S=fnRecvString(hSocket, 1);astrctChannel(iChannel).m_fPulseFrequencyHz = str2num(S);
    S=fnRecvString(hSocket, 1);astrctChannel(iChannel).m_iPulse_Width_Microns = str2num(S);
    S=fnRecvString(hSocket, 1);astrctChannel(iChannel).m_iTrain_Length_Microns = str2num(S);
    S=fnRecvString(hSocket, 1);astrctChannel(iChannel).m_fTrain_Freq_Hz = str2num(S);
    S=fnRecvString(hSocket, 1);astrctChannel(iChannel).m_iNumTrains_Per_Trigger = str2num(S);
    S=fnRecvString(hSocket, 1);astrctChannel(iChannel).m_bSecondPulse = str2num(S);
    S=fnRecvString(hSocket, 1);astrctChannel(iChannel).m_iSecond_Pulse_Delay_Microns = str2num(S);
    S=fnRecvString(hSocket, 1);astrctChannel(iChannel).m_iSecond_Pulse_Width_Microns = str2num(S);
    S=fnRecvString(hSocket, 1);astrctChannel(iChannel).m_iTriggerDelay_Microns = str2num(S);
    S=fnRecvString(hSocket, 1);astrctChannel(iChannel).m_fAmplitude = str2num(S);
    S=fnRecvString(hSocket, 1);astrctChannel(iChannel).m_bActive = str2num(S);
    S=fnRecvString(hSocket, 1);astrctChannel(iChannel).m_iGateDelay_Microns= str2num(S);
    S=fnRecvString(hSocket, 1);astrctChannel(iChannel).m_iGateLength_Microns= str2num(S);
    S=fnRecvString(hSocket, 1);astrctChannel(iChannel).m_bUsePhotodiodeTrigger = str2num(S);    
end
S=fnRecvString(hSocket, 1);
fnClearMessageQueue(hSocket);
IOPort('Write',  hSocket , uint8([sprintf('%02d',UDP_GET_PRESET_NAMES),10]));
acPresetNames = cell(1,NUM_PRESETS);
for k=1:NUM_PRESETS
    acPresetNames{k} = fnRecvString(hSocket, 1);
end
return;


function fnClearMessageQueue(hSocket)
try
    IOPort('Purge',hSocket);
catch
end


return;