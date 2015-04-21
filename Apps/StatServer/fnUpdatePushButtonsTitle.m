function fnUpdatePushButtonsTitle()
global g_strctNeuralServer g_strctConfig g_strctWindows
aiChIndInTrialBuf = find(g_strctNeuralServer.m_abChannelsDisplayed);
iNumChannelsOnScreen = size(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes,1);

% aiChannelsToDisplay represents the indices in trial buffer !!!!
if length(aiChIndInTrialBuf) <= iNumChannelsOnScreen
    aiChannelsToDisplay = aiChIndInTrialBuf;
else
    aiChannelsToDisplay = aiChIndInTrialBuf(g_strctConfig.m_strctGUIParams.m_iChannelDisplayStart:min(length(aiChIndInTrialBuf), g_strctConfig.m_strctGUIParams.m_iChannelDisplayStart+iNumChannelsOnScreen-1));
end

for iRowIter=1:iNumChannelsOnScreen
    for iUnit=1:4
        iChannel=aiChannelsToDisplay(iRowIter);
      if g_strctNeuralServer.m_a2iCurrentActiveUnits(iChannel,iUnit) > 0
           strBut = sprintf('[%d:%d] is Active!',iChannel,iUnit);%
           set( g_strctWindows.m_strctStatPanel.m_a2hPushButtons(iRowIter,1+iUnit),'string',strBut,'FontWeight','Bold');
      else
            strBut = sprintf('Activate %d:%d',iChannel,iUnit);
            set( g_strctWindows.m_strctStatPanel.m_a2hPushButtons(iRowIter,1+iUnit),'string',strBut,'FontWeight','normal');
      end
    end
end

return;
