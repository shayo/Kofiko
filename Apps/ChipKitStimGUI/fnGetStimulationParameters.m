function strctParams=fnGetStimulationParameters(strType, iChannel, fTriggerDelayMS)
% Build stimulation parameters for various purposes
switch strType
    case 'AntidromicElectrical'
        
        strctParams.m_astrctChannels(iChannel).m_fPulseFrequencyHz = 1;
        strctParams.m_astrctChannels(iChannel).m_iPulse_Width_Microns = 150;
        strctParams.m_astrctChannels(iChannel).m_iTrain_Length_Microns = 1000;
        strctParams.m_astrctChannels(iChannel).m_fTrain_Freq_Hz = 1;
        strctParams.m_astrctChannels(iChannel).m_iNumTrains_Per_Trigger = 1;
        strctParams.m_astrctChannels(iChannel).m_bSecondPulse = 1;
        strctParams.m_astrctChannels(iChannel).m_iSecond_Pulse_Delay_Microns = 100;
        strctParams.m_astrctChannels(iChannel).m_iSecond_Pulse_Width_Microns = 150;
        strctParams.m_astrctChannels(iChannel).m_iTriggerDelay_Microns = fTriggerDelayMS;
        strctParams.m_astrctChannels(iChannel).m_fAmplitude = 1;
        strctParams.m_astrctChannels(iChannel).m_bActive = 1;
        
    case 'Optical'
        strctParams.m_astrctChannels(iChannel).m_fPulseFrequencyHz = 1;
        strctParams.m_astrctChannels(iChannel).m_iPulse_Width_Microns = 1000000;
        strctParams.m_astrctChannels(iChannel).m_iTrain_Length_Microns = 1000000;
        strctParams.m_astrctChannels(iChannel).m_fTrain_Freq_Hz = 1;
        strctParams.m_astrctChannels(iChannel).m_iNumTrains_Per_Trigger = 1;
        strctParams.m_astrctChannels(iChannel).m_bSecondPulse = 0;
        strctParams.m_astrctChannels(iChannel).m_iSecond_Pulse_Delay_Microns = 0;
        strctParams.m_astrctChannels(iChannel).m_iSecond_Pulse_Width_Microns = 0;
        strctParams.m_astrctChannels(iChannel).m_iTriggerDelay_Microns = 0;
        strctParams.m_astrctChannels(iChannel).m_fAmplitude = 1;
        strctParams.m_astrctChannels(iChannel).m_bActive = 1;
        
end

return
