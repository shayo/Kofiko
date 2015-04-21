function fnUpdateAdvancerText()
global g_strctWindows g_strctNeuralServer g_strctConfig g_strctCycle
iNumChannelsOnScreen = size(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes,1);

% Pick the N channels to be displayed....
aiChIndInTrialBuf = find(g_strctNeuralServer.m_abChannelsDisplayed);

% aiChannelsToDisplay represents the indices in trial buffer !!!!
if length(aiChIndInTrialBuf) <= iNumChannelsOnScreen
    aiChannelsToDisplay = aiChIndInTrialBuf;
else
    aiChannelsToDisplay = aiChIndInTrialBuf(g_strctConfig.m_strctGUIParams.m_iChannelDisplayStart:min(length(aiChIndInTrialBuf), g_strctConfig.m_strctGUIParams.m_iChannelDisplayStart+iNumChannelsOnScreen-1));
end
iNumChannelsToDisplay = length(aiChannelsToDisplay);


if isfield( g_strctNeuralServer,'m_a2iChannelToGridHoleAdvancer')
    for iAxesIter=1:iNumChannelsToDisplay
        iChannel = g_strctNeuralServer.m_aiActiveSpikeChannels(aiChannelsToDisplay(iAxesIter));
        iAdvancerIndex = g_strctNeuralServer.m_a2iChannelToGridHoleAdvancer(iChannel,3);
        if ~isnan(iAdvancerIndex)
            fDepthOffsetMM = g_strctNeuralServer.m_a2iChannelToGridHoleAdvancer(iChannel,4);
            fReadOutTicks = g_strctCycle.m_afAdvancerPrevReadOut(iAdvancerIndex);
            fDepthMM = fDepthOffsetMM + fReadOutTicks / g_strctConfig.m_strctAdvancers.m_fMouseWheelToMM;
            set(g_strctWindows.m_strctStatPanel.m_ahChannelText(iAxesIter),'String',sprintf('Channel %d Depth %.2f',iChannel, fDepthMM));
        else
            set(g_strctWindows.m_strctStatPanel.m_ahChannelText(iAxesIter),'String',sprintf('Channel %d',iChannel));
        end
    end
    drawnow
end
return;
