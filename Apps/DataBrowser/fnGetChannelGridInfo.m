function astrctChannels = fnGetChannelGridInfo(strctStatServer)
%strctStatServer = load(strStatServerFile);
iNumChannels = length(strctStatServer.g_strctNeuralServer.m_aiActiveSpikeChannels);
% Extract the information per channel
iCounter=1;
for iCh=1:iNumChannels
    astrctChannels(iCounter).m_iChannel = strctStatServer.g_strctNeuralServer.m_aiActiveSpikeChannels(iCh);
    iGridIndex = strctStatServer.g_strctNeuralServer.m_a2iChannelToGridHoleAdvancer(astrctChannels(iCounter).m_iChannel,1);
    if ~isnan(iGridIndex)
        iHoleIndex = strctStatServer.g_strctNeuralServer.m_a2iChannelToGridHoleAdvancer(astrctChannels(iCounter).m_iChannel,2);
        if ~isfield(strctStatServer.g_strctNeuralServer.m_acGrids{iGridIndex},'m_strModelName')
        astrctChannels(iCounter).m_strGridModelName = strctStatServer.g_strctNeuralServer.m_acGrids{iGridIndex}.m_strName;
        astrctChannels(iCounter).m_fCenterOffsetX = strctStatServer.g_strctNeuralServer.m_acGrids{iGridIndex}.m_afGridHolesX(iHoleIndex);
        astrctChannels(iCounter).m_fCenterOffsetY = strctStatServer.g_strctNeuralServer.m_acGrids{iGridIndex}.m_afGridHolesY(iHoleIndex);
        astrctChannels(iCounter).m_strTargetName = strctStatServer.g_strctNeuralServer.m_acGrids{iGridIndex}.m_strctGridParams.m_astrctHoleInformation(iHoleIndex).m_strTargetName;
        astrctChannels(iCounter).m_strElectrodeType = strctStatServer.g_strctNeuralServer.m_acGrids{iGridIndex}.m_strctGridParams.m_astrctHoleInformation(iHoleIndex).m_strElectrodeType;
            
        else
        astrctChannels(iCounter).m_strGridModelName = strctStatServer.g_strctNeuralServer.m_acGrids{iGridIndex}.m_strModelName;
        astrctChannels(iCounter).m_fCenterOffsetX = strctStatServer.g_strctNeuralServer.m_acGrids{iGridIndex}.m_strctModel.m_aiLocX(iHoleIndex);
        astrctChannels(iCounter).m_fCenterOffsetY = strctStatServer.g_strctNeuralServer.m_acGrids{iGridIndex}.m_strctModel.m_aiLocY(iHoleIndex);
        astrctChannels(iCounter).m_strTargetName = strctStatServer.g_strctNeuralServer.m_acGrids{iGridIndex}.m_strctModel.m_strctGridParams.m_astrctHoleInformation(iHoleIndex).m_strTargetName;
        astrctChannels(iCounter).m_strElectrodeType = strctStatServer.g_strctNeuralServer.m_acGrids{iGridIndex}.m_strctModel.m_strctGridParams.m_astrctHoleInformation(iHoleIndex).m_strElectrodeType;
        end
        iCounter=iCounter+1;
    end
end

return;