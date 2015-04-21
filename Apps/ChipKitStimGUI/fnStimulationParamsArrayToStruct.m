function strctParams=fnStimulationParamsArrayToStruct(iChannel,afParams)
% Build stimulation parameters for various purposes
strctParams.m_astrctChannels(iChannel).m_fPulseFrequencyHz = afParams(1);
strctParams.m_astrctChannels(iChannel).m_iPulse_Width_Microns = afParams(2);
strctParams.m_astrctChannels(iChannel).m_iTrain_Length_Microns = afParams(3);
strctParams.m_astrctChannels(iChannel).m_fTrain_Freq_Hz = afParams(4);
strctParams.m_astrctChannels(iChannel).m_iNumTrains_Per_Trigger = afParams(5);
strctParams.m_astrctChannels(iChannel).m_bSecondPulse = afParams(6);
strctParams.m_astrctChannels(iChannel).m_iSecond_Pulse_Delay_Microns = afParams(7);
strctParams.m_astrctChannels(iChannel).m_iSecond_Pulse_Width_Microns = afParams(8);
strctParams.m_astrctChannels(iChannel).m_iTriggerDelay_Microns = afParams(9);
strctParams.m_astrctChannels(iChannel).m_fAmplitude = afParams(10);
strctParams.m_astrctChannels(iChannel).m_bActive = afParams(11);
strctParams.m_astrctChannels(iChannel).m_iGateDelay_Microns= afParams(12);
strctParams.m_astrctChannels(iChannel).m_iGateLength_Microns= afParams(13);
strctParams.m_astrctChannels(iChannel).m_bUsePhotodiodeTrigger = afParams(14);
return
