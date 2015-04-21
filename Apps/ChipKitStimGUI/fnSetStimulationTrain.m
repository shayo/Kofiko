function bOK = fnSetStimulationTrain(iChannel, strctParams)
% Channel is 1 or 2
global g_hNanoStimulatorPort g_strctDAQParams

UDP_MODIFY_PULSE_FREQ = 1;
UDP_MODIFY_PULSE_WIDTH = 2;
UDP_MODIFY_SECOND_PULSE = 3;
UDP_MODIFY_TRAIN_LENGTH = 4;
UDP_MODIFY_TRAIN_FREQ = 5;
UDP_MODIFY_NUM_TRAINS = 6;
UDP_MODIFY_TRIG_DELAY = 7;
UDP_MODIFY_SECOND_PULSE_WIDTH = 8;
UDP_MODIFY_SECOND_PULSE_DELAY = 9;
UDP_MODIFY_AMPLITUDE = 10;
UDP_TOGGLE_CHANNEL_ACTIVE = 14;
UDP_MODIFY_GATE_DELAY= 23;
UDP_MODIFY_GATE_LENGTH = 24;
UDP_MODIFY_PHOTODIODE_TRIGGER = 25;

g_strctDAQParams = fnTsSetVar(g_strctDAQParams,'NanoStimulatorParams', strctParams);
         
bOK = true;
try
    IOPort('Purge',g_hNanoStimulatorPort);
    
    IOPort('Write',g_hNanoStimulatorPort,uint8([sprintf('%02d %d %.2f',UDP_MODIFY_PULSE_FREQ,iChannel-1,strctParams.m_astrctChannels(iChannel).m_fPulseFrequencyHz),10]));
    IOPort('Write',g_hNanoStimulatorPort,uint8([sprintf('%02d %d %d',UDP_MODIFY_PULSE_WIDTH,iChannel-1,strctParams.m_astrctChannels(iChannel).m_iPulse_Width_Microns),10]));
    IOPort('Write',g_hNanoStimulatorPort,uint8([sprintf('%02d %d %d',UDP_MODIFY_TRAIN_LENGTH,iChannel-1,strctParams.m_astrctChannels(iChannel).m_iTrain_Length_Microns),10]));
    IOPort('Write',g_hNanoStimulatorPort,uint8([sprintf('%02d %d %.2f',UDP_MODIFY_TRAIN_FREQ,iChannel-1,strctParams.m_astrctChannels(iChannel).m_fTrain_Freq_Hz),10]));
    IOPort('Write',g_hNanoStimulatorPort,uint8([sprintf('%02d %d %d',UDP_MODIFY_NUM_TRAINS,iChannel-1,strctParams.m_astrctChannels(iChannel).m_iNumTrains_Per_Trigger),10]));
    IOPort('Write',g_hNanoStimulatorPort,uint8([sprintf('%02d %d %d',UDP_MODIFY_SECOND_PULSE,iChannel-1,strctParams.m_astrctChannels(iChannel).m_bSecondPulse),10]));
    IOPort('Write',g_hNanoStimulatorPort,uint8([sprintf('%02d %d %d',UDP_MODIFY_SECOND_PULSE_DELAY,iChannel-1,strctParams.m_astrctChannels(iChannel).m_iSecond_Pulse_Delay_Microns),10]));
    IOPort('Write',g_hNanoStimulatorPort,uint8([sprintf('%02d %d %d',UDP_MODIFY_SECOND_PULSE_WIDTH,iChannel-1,strctParams.m_astrctChannels(iChannel).m_iSecond_Pulse_Width_Microns),10]));
    IOPort('Write',g_hNanoStimulatorPort,uint8([sprintf('%02d %d %d',UDP_MODIFY_TRIG_DELAY,iChannel-1,strctParams.m_astrctChannels(iChannel).m_iTriggerDelay_Microns),10]));
    IOPort('Write',g_hNanoStimulatorPort,uint8([sprintf('%02d %d %.2f',UDP_MODIFY_AMPLITUDE,iChannel-1,strctParams.m_astrctChannels(iChannel).m_fAmplitude),10]));
    IOPort('Write',g_hNanoStimulatorPort,uint8([sprintf('%02d %d %f',UDP_TOGGLE_CHANNEL_ACTIVE,iChannel-1,strctParams.m_astrctChannels(iChannel).m_bActive),10]));
    IOPort('Write',g_hNanoStimulatorPort,uint8([sprintf('%02d %d %f',UDP_MODIFY_GATE_DELAY,iChannel-1,strctParams.m_astrctChannels(iChannel).m_iGateDelay_Microns),10]));
    IOPort('Write',g_hNanoStimulatorPort,uint8([sprintf('%02d %d %f',UDP_MODIFY_GATE_LENGTH,iChannel-1,strctParams.m_astrctChannels(iChannel).m_iGateLength_Microns),10]));
    IOPort('Write',g_hNanoStimulatorPort,uint8([sprintf('%02d %d %f',UDP_MODIFY_PHOTODIODE_TRIGGER,iChannel-1,strctParams.m_astrctChannels(iChannel).m_bUsePhotodiodeTrigger),10]));
catch
    bOK = false;
    fprintf('Error sending parameters to Nano Stimulator\n');
    return;
end
WaitSecs(0.1);
NumBytesAvail =  IOPort('BytesAvailable', g_hNanoStimulatorPort);
if (NumBytesAvail > 0)
    strBuffer=char(IOPort('Read',g_hNanoStimulatorPort,0,NumBytesAvail));
    aiIndices = strfind(char(strBuffer), 'NOK');
    BOK = isempty(aiIndices);
else
    fprintf('Error sending parameters to Nano Stimulator\n');
    bOK = false;
    return;
    
end

return

function S=fnRecvString(hSocket, iTimeOut)
S=char();
tic
while 1
    NumBytesAvail =  IOPort('BytesAvailable', hSocket);
    if NumBytesAvail > 0
      cChar=IOPort('Read',hSocket,0,1);
      if (cChar == 10)
          break;
      else
          if (cChar ~= 13)
                S=[S,cChar];
          end
      end
    end
    if toc > iTimeOut 
        break;
    end
end
return;
