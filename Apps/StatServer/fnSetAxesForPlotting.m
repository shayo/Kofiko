function fnSetAxesForPlotting()
global g_strctConfig g_strctWindows g_strctNeuralServer g_strctCycle

%
% Delete all kids...
ahChildren = get(g_strctWindows.m_strctStatPanel.m_hPanel,'Children');
delete(ahChildren(ishandle(ahChildren)));

% Now plot (!)
if ~isfield(g_strctNeuralServer,'m_iNumberUnitsPerChannel')
    iNumPlotsPerRow = 5; % Assume maximum 4 units per channel + LFP
else
    iNumPlotsPerRow = 1+g_strctNeuralServer.m_iNumberUnitsPerChannel;
end

iNumPlotsPerCol=min(g_strctConfig.m_strctGUIParams.m_iMaxChannelsOnScreen, sum(g_strctNeuralServer.m_abChannelsDisplayed));

a2hPlotAxes = zeros(iNumPlotsPerCol, iNumPlotsPerRow);
a2hPlotSubAxes = zeros(iNumPlotsPerCol, iNumPlotsPerRow);
a2hPushButtons= zeros(iNumPlotsPerCol, iNumPlotsPerRow);
ahChannelText = zeros(1,g_strctConfig.m_strctGUIParams.m_iMaxChannelsOnScreen);
    
iNumChannelsOnScreen = iNumPlotsPerCol;
% Pick the N channels to be displayed....
aiChIndInTrialBuf = find(g_strctNeuralServer.m_abChannelsDisplayed);
% aiChannelsToDisplay represents the indices in trial buffer !!!!
if length(aiChIndInTrialBuf) <= iNumChannelsOnScreen
    aiChannelsToDisplay = g_strctNeuralServer.m_aiActiveSpikeChannels(aiChIndInTrialBuf);
else
    aiChannelsToDisplay = g_strctNeuralServer.m_aiActiveSpikeChannels(aiChIndInTrialBuf(g_strctConfig.m_strctGUIParams.m_iChannelDisplayStart:min(length(aiChIndInTrialBuf), g_strctConfig.m_strctGUIParams.m_iChannelDisplayStart+iNumChannelsOnScreen-1)));
end

OffsetX = 0.1;
OffsetY = -0.1;
for iRowIter=1:iNumChannelsOnScreen
    for iColIter=1:iNumPlotsPerRow
        % Generate the axes
        fHorizSpacing = 0.05;
        fVerticalSpacing = 0.05;
        
        if iNumChannelsOnScreen < 4
            fCenterX = iColIter * 1.2* 1/(iNumPlotsPerRow+1) - OffsetX;
            fCenterY = 1- (1.2*iRowIter * 1/(4+1));
            fWidth = 1/iNumPlotsPerRow - fHorizSpacing;
            fHeight = 1/4 - fVerticalSpacing - 0.05;
        else
            fCenterX = iColIter * 1.2* 1/(iNumPlotsPerRow+1) - OffsetX;
            fCenterY = 1- (1.2*iRowIter * 1/(iNumPlotsPerCol+1));
            fWidth = 1/iNumPlotsPerRow - fHorizSpacing;
            fHeight = 1/iNumPlotsPerCol - fVerticalSpacing - 0.05;
        end
        aiAxesPosition = [fCenterX-fWidth/2,fCenterY-fHeight/2-OffsetY,fWidth,fHeight];
        
        a2hPlotAxes(iRowIter,iColIter) = axes('Position', aiAxesPosition, 'Parent',g_strctWindows.m_strctStatPanel.m_hPanel);
        box(a2hPlotAxes(iRowIter,iColIter),'on');
        
        if iColIter > 1
            aiButtonPos = [aiAxesPosition(1), aiAxesPosition(2)+aiAxesPosition(4), 0.65 * fWidth, 0.2 * fHeight];
            strBut = sprintf('Activate %d:%d',aiChannelsToDisplay(iRowIter),iColIter-1);
            
            if g_strctCycle.m_bPlexonIsRecording
                strEnable = 'on';
            else
                strEnable = 'off';
            end
            a2hPushButtons(iRowIter,iColIter) = uicontrol('style','pushbutton','units','normalized','position',aiButtonPos,...
                'String',strBut,'parent',g_strctWindows.m_strctStatPanel.m_hPanel,'callback',{@fnButCallback, iRowIter,iColIter-1},'enable',strEnable);
        else
            
            a2hPushButtons(iRowIter,iColIter) = NaN;
        end
        
        plot(-[1:10],1:10,'parent',a2hPlotAxes(iRowIter,iColIter));
        if iColIter > 1
            X = get(a2hPlotAxes(iRowIter,iColIter),'Position');
            fSize = min(X(3:4));
            aiSubPos = [X(1)+0.7*X(3),X(2)+X(4),0.3*fSize,0.3*fSize];
            a2hPlotSubAxes(iRowIter,iColIter) = axes('Position',aiSubPos,'XTickLabelMode','manual','YTickLabelMode','manual','Xtick',[],'Ytick',[],'parent',g_strctWindows.m_strctStatPanel.m_hPanel);
            plot(a2hPlotSubAxes(iRowIter,iColIter),1:10,1:10)
            set(a2hPlotSubAxes(iRowIter,iColIter),'XTickLabelMode','manual','YTickLabelMode','manual','Xtick',[],'Ytick',[]);
        else 
            aiSubplotAxesPos = [aiAxesPosition(1) aiAxesPosition(2)+fHeight fWidth, 0.2*fHeight];
            a2hPlotSubAxes(iRowIter,iColIter) = axes('Position', aiSubplotAxesPos, 'Parent',g_strctWindows.m_strctStatPanel.m_hPanel);
            set(a2hPlotSubAxes(iRowIter,iColIter),'Xtick',[],'Ytick',[])
            
            ahChannelText(iRowIter)=text(0.1,0.6,sprintf('Channel %d',aiChannelsToDisplay(iRowIter)),'parent',a2hPlotSubAxes(iRowIter,iColIter),'FontSize',14,'FontWeight','bold','color',[1 0 0]);
            
        end
        
    end
end
%%
g_strctWindows.m_strctStatPanel.m_a2hPlotAxes = a2hPlotAxes;
g_strctWindows.m_strctStatPanel.m_a2hPlotSubAxes = a2hPlotSubAxes;
g_strctWindows.m_strctStatPanel.m_a2hPushButtons = a2hPushButtons;
g_strctWindows.m_strctStatPanel.m_ahChannelText = ahChannelText;
fnUpdateAdvancerText();
return;

function fnButCallback(a,b,c,d)
global g_strctWindows  g_strctNeuralServer g_strctConfig

iNumChannelsOnScreen = size(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes,1);
aiChIndInTrialBuf = find(g_strctNeuralServer.m_abChannelsDisplayed);

% aiChannelsToDisplay represents the indices in trial buffer !!!!
if length(aiChIndInTrialBuf) <= iNumChannelsOnScreen
    aiChannelsToDisplay = aiChIndInTrialBuf;
else
    aiChannelsToDisplay = aiChIndInTrialBuf(g_strctConfig.m_strctGUIParams.m_iChannelDisplayStart:min(length(aiChIndInTrialBuf), g_strctConfig.m_strctGUIParams.m_iChannelDisplayStart+iNumChannelsOnScreen-1));
end
fnStatServerCallbacks('ToggleActive',aiChannelsToDisplay(c),d);
return;
