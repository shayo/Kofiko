function fnDisplayOverview()
global g_strctWindows g_strctCycle g_strctConfig g_strctNeuralServer

iNumChannelsOnScreen = size(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes,1);
bRescale = g_strctConfig.m_strctGUIParams.m_bAutoRescale;
% Pick the N channels to be displayed....
aiChIndInTrialBuf = find(g_strctNeuralServer.m_abChannelsDisplayed);

% aiChannelsToDisplay represents the indices in trial buffer !!!!
if length(aiChIndInTrialBuf) <= iNumChannelsOnScreen
     aiChannelsToDisplay = aiChIndInTrialBuf;
else
    aiChannelsToDisplay = aiChIndInTrialBuf(g_strctConfig.m_strctGUIParams.m_iChannelDisplayStart:min(length(aiChIndInTrialBuf), g_strctConfig.m_strctGUIParams.m_iChannelDisplayStart+iNumChannelsOnScreen-1));
end
iNumChannelsToDisplay = length(aiChannelsToDisplay);

XX=GetSecs();
[a4fPSTH, a3fLFP,afLFP_Time, afSpike_Time, a3fWaveFormAvg,a3fWaveFormVar] = TrialCircularBuffer('GetAllPSTH');
% Try to plot the LFP 
try
    a3fLFP_Subset = a3fLFP(:,g_strctCycle.m_abDisplayConditions > 0,:);
    a2fLFP=reshape(a3fLFP_Subset, size(a3fLFP_Subset,1)*size(a3fLFP_Subset,2),size(a3fLFP_Subset,3))';
    a2fLFP_Subset = a2fLFP(aiChannelsToDisplay,:);
    set(g_strctWindows.m_strctSettingsPanel.m_hLFPImage,'xdata', 1:size(a2fLFP_Subset,2),'ydata',1:size(a2fLFP_Subset,1),'cdata',a2fLFP_Subset,'CDataMapping','scaled');
    set(g_strctWindows.m_strctSettingsPanel.m_hLFPImageAxes,'xlim',[1 size(a2fLFP_Subset,2)],'ylim',[1 size(a2fLFP_Subset,1)]);
catch
end

% PSTH is 4D:  Time x Condition x Units x Channel
if g_strctConfig.m_strctGUIParams.m_bSmoothPSTH
    fPSTHBinSizeMS = (afSpike_Time(2)-afSpike_Time(1) )*1e3;
    fActualKernelSize = g_strctConfig.m_strctGUIParams.m_fSmoothingWindowMS/fPSTHBinSizeMS;
    afKernel = fspecial('gaussian',[1 ceil(7*fActualKernelSize)],fActualKernelSize);
end

NumConditions = size(a3fLFP,2);
NumUnits = size(a4fPSTH,3);
%% Draw LFP per condition
for iAxesIter=1:iNumChannelsToDisplay
    iChannel = aiChannelsToDisplay(iAxesIter);
    cla(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(iAxesIter,1));
    hold(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(iAxesIter,1),'on');
    for iCondition=1:NumConditions
        if g_strctCycle.m_abDisplayConditions(iCondition)
            plot(afLFP_Time,  a3fLFP(:,iCondition,iChannel),'parent',g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(iAxesIter,1),'color',g_strctCycle.m_a2fConditionColors(iCondition,:));
        end
    end
    if bRescale
        fMin = min(min(a3fLFP(:,:,iChannel)));
        fMax = max(max(a3fLFP(:,:,iChannel)));
        if  isempty(fMax) || (fMax <= fMin)
            fMax = fMin + 1;
        end
        set(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(iAxesIter,1),'xlim', [afLFP_Time(1) afLFP_Time(end)],'ylim',[fMin fMax]);
    end
end

%% Plot Waveform
NumPtsWF = size(a3fWaveFormAvg,1);
acstrUnitColor = 'ygcr';

for iAxesIter=1:iNumChannelsToDisplay
    iChannel = aiChannelsToDisplay(iAxesIter);
    
    for iUnit=1:NumUnits
        cla(g_strctWindows.m_strctStatPanel.m_a2hPlotSubAxes(iAxesIter,1+iUnit));
        hold(g_strctWindows.m_strctStatPanel.m_a2hPlotSubAxes(iAxesIter,1+iUnit),'on');
        
        
        afSqr = sqrt(a3fWaveFormVar(:,iUnit,iChannel));
        plot(g_strctWindows.m_strctStatPanel.m_a2hPlotSubAxes(iAxesIter,1+iUnit), 1:NumPtsWF,a3fWaveFormAvg(:,iUnit,iChannel),'color',acstrUnitColor(iUnit),'LineStyle','-','LineWidth',2);
        plot(g_strctWindows.m_strctStatPanel.m_a2hPlotSubAxes(iAxesIter,1+iUnit), 1:NumPtsWF,a3fWaveFormAvg(:,iUnit,iChannel)+afSqr,'color',acstrUnitColor(iUnit),'LineStyle','-');
        plot(g_strctWindows.m_strctStatPanel.m_a2hPlotSubAxes(iAxesIter,1+iUnit), 1:NumPtsWF,a3fWaveFormAvg(:,iUnit,iChannel)-afSqr,'color',acstrUnitColor(iUnit),'LineStyle','-');
    end
end
%% PSTH or Raster
if strcmp(g_strctConfig.m_strctGUIParams.m_strViewMode,'Raster')
    iCondition = 1;
    a2cRasters = TrialCircularBuffer('GetRastersForPlot',iCondition);
    for iAxesIter=1:iNumChannelsToDisplay
          iChannel = aiChannelsToDisplay(iAxesIter);
         for iUnit=1:NumUnits
          cla(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(iAxesIter,1+iUnit));
            hold(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(iAxesIter,1+iUnit),'on');
            plot(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(iAxesIter,1+iUnit),...
              a2cRasters{iChannel,iUnit}(:,1),  a2cRasters{iChannel,iUnit}(:,2),'.','color',g_strctCycle.m_a2fConditionColors(iCondition,:));
          
          if bRescale
              fMin = 1;
              fMax = max(a2cRasters{iChannel,iUnit}(:,2));
              if  isempty(fMax) || (fMax <= fMin)
                  fMax = fMin + 1;
              end
              set(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(iAxesIter,1+iUnit),'xlim', [afSpike_Time(1) afSpike_Time(end)],'ylim',[fMin fMax]);
          end
        end
   end
    
    
elseif strcmp(g_strctConfig.m_strctGUIParams.m_strViewMode,'BarGraph')
    if ~isnumeric(g_strctConfig.m_strctGUIParams.m_fBarGraphTo)
        g_strctConfig.m_strctGUIParams.m_fBarGraphTo = str2num(g_strctConfig.m_strctGUIParams.m_fBarGraphTo);
    end;
    if ~isnumeric(g_strctConfig.m_strctGUIParams.m_fBarGraphFrom)
        g_strctConfig.m_strctGUIParams.m_fBarGraphFrom = str2num(g_strctConfig.m_strctGUIParams.m_fBarGraphFrom);
    end;
    
    iStartInd = find(afSpike_Time >= g_strctConfig.m_strctGUIParams.m_fBarGraphFrom/1e3,1,'first');
    iEndInd = find(afSpike_Time <= g_strctConfig.m_strctGUIParams.m_fBarGraphTo/1e3,1,'last');
    
    
    fScale = 1/(afSpike_Time(2)-afSpike_Time(1));
    for iAxesIter=1:iNumChannelsToDisplay
         iChannel = aiChannelsToDisplay(iAxesIter);
        
         if size(a4fPSTH,2) == 1 % Only one condition....
             a2fAvg = squeeze(mean(a4fPSTH(iStartInd:iEndInd,:,:,iChannel),1))';
         else
            a2fAvg = squeeze(mean(a4fPSTH(iStartInd:iEndInd,:,:,iChannel),1));
         end
        % a2fAvg is usually Condition X Unit
        for iUnit=1:NumUnits
            cla(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(iAxesIter,1+iUnit));
            hold(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(iAxesIter,1+iUnit),'on');
            
            afBarsY = fScale*a2fAvg(g_strctCycle.m_abDisplayConditions, iUnit);
            afBarsX = 1:length(afBarsY);
            afBarTick = find(g_strctCycle.m_abDisplayConditions);
            for iIter=1:length(afBarTick)
                patch('xdata',[iIter-0.5 iIter-0.5 iIter+0.5 iIter+0.5],'ydata',[0 afBarsY(iIter) afBarsY(iIter) 0],'facecolor', ...
                    g_strctCycle.m_a2fConditionColors(afBarTick(iIter),:),'parent',g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(iAxesIter,1+iUnit) );
            end
            if bRescale
                fMin = 0;
                fMax = max(afBarsY);
                if  isempty(fMax) || (fMax <= fMin)
                    fMax = fMin + 1;
                end
                set(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(iAxesIter,1+iUnit),'xlim', [-0.5 length(afBarsY)+1],'ylim',[fMin fMax]);
            end
            
            
        end
    end

elseif strcmp(g_strctConfig.m_strctGUIParams.m_strViewMode,'PSTH')
    % Draw PSTH as curve firing rate per condition, per unit
    fScale = 1/(afSpike_Time(2)-afSpike_Time(1));
    for iAxesIter=1:iNumChannelsToDisplay
   iChannel = aiChannelsToDisplay(iAxesIter);
              
        for iUnit=1:NumUnits
            cla(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(iAxesIter,1+iUnit));
            hold(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(iAxesIter,1+iUnit),'on');
            
            fMin=Inf;
            fMax = -Inf;
             for iCondition=1:NumConditions
                if g_strctCycle.m_abDisplayConditions(iCondition)
                    if g_strctConfig.m_strctGUIParams.m_bSmoothPSTH
                        afSmoothCurve = conv2(fScale*a4fPSTH(:,iCondition,iUnit,iChannel)',afKernel,'same');
                        fMin = min([fMin; afSmoothCurve(:)]);
                        fMax = max([fMax; afSmoothCurve(:)]);
                        plot(afSpike_Time, afSmoothCurve,'parent',g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(iAxesIter,1+iUnit),'color',g_strctCycle.m_a2fConditionColors(iCondition,:));
                    else
                        afCurve = fScale*a4fPSTH(:,iCondition,iUnit,iChannel);
                          fMin = min([fMin; afCurve(:)]);
                        fMax = max([fMax; afCurve(:)]);
                         
                        plot(afSpike_Time,afCurve ,'parent',g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(iAxesIter,1+iUnit),'color',g_strctCycle.m_a2fConditionColors(iCondition,:));
                    end
                end
             end
            
             if bRescale
                   if  isempty(fMax) || (fMax <= fMin)
                     fMax = fMin + 1;
                   end
                 if ~isinf(fMax) && ~isinf(fMin)
                    set(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(iAxesIter,1+iUnit),'xlim', [afSpike_Time(1) afSpike_Time(end)],'ylim',[0.9*fMin 1.1*fMax]);
                 end
             end
             
             
        end
    end
end

%% Update how long each unit has been recorded, how many trials, and whether we potentially lost the unit
fLastKnownTS = TrialCircularBuffer('GetLastKnownTimestamp');
a2fTrialCounter = TrialCircularBuffer('GetUnitsTrialCounter');
for iAxesIter=1:iNumChannelsToDisplay
  iChannel = aiChannelsToDisplay(iAxesIter);
     
    for iUnit=1:NumUnits
        
        iNumEntries = size(g_strctNeuralServer.m_a2cActiveUnitsHistory{iChannel,iUnit},1);
        if g_strctNeuralServer.m_a2iCurrentActiveUnits(iChannel,iUnit) > 0 && iNumEntries > 0
            fStartTS = g_strctNeuralServer.m_a2cActiveUnitsHistory{iChannel,iUnit}(iNumEntries,1);
            fRecordedDurationSec = fLastKnownTS - fStartTS;
            fRecMin = floor(fRecordedDurationSec/60);
            fRecSec = round(fRecordedDurationSec-fRecMin*60);
            
            set(g_strctWindows.m_strctStatPanel.m_a2hPushButtons(iAxesIter,iUnit+1),'String', sprintf('Unit %d, Rec %d:%d, #%d',...
                g_strctNeuralServer.m_a2iCurrentActiveUnits(iChannel,iUnit),...
                fRecMin,fRecSec,a2fTrialCounter(iChannel,iUnit)));
        end
        
        if g_strctNeuralServer.m_a2bLostWarning(iChannel,iUnit) && g_strctNeuralServer.m_a2iCurrentActiveUnits(iChannel,iUnit) >0
            set(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(iAxesIter,iUnit+1),'color',[0.4 0 0 ])
        else
            if g_strctNeuralServer.m_a2iCurrentActiveUnits(iChannel,iUnit) > 0
                set(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(iAxesIter,iUnit+1),'color',[0 0.2 0 ])
            else
                set(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(iAxesIter,iUnit+1),'color',[0 0 0 ])
            end
        end
    end
end

drawnow
YY=GetSecs();
fnStatLog('Screen Update : %.2f ms ',(YY-XX)*1e3);

return;

% return;
%
% iTrialHistoryLength = size(g_strctNeuralServer.m_strctBuffer.m_a4fSpikeTS_Buffer,1);
% for iChannelIter=1:g_strctNeuralServer.m_iNumActiveSpikeChannels
%     iNumValidSamples = g_strctNeuralServer.m_strctBuffer.m_aiLFP_NumValidSamples(iChannelIter);
%     aiValidIndices = g_strctNeuralServer.m_strctBuffer.m_iTrialCounter-1:-1:g_strctNeuralServer.m_strctBuffer.m_iTrialCounter-iNumValidSamples;
%     aiValidIndices(aiValidIndices<1) = aiValidIndices(aiValidIndices<1)+iTrialHistoryLength;
%
%     afAverageLFP=squeeze(mean(g_strctNeuralServer.m_strctBuffer.m_a3fLFP_Buffer(aiValidIndices, iChannelIter,:),1));
%     plot(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(iChannelIter,1),afAverageLFP,'b');
% end
%
% % This displays the raster for a maximum of ? previous trials
% iMaxRasterLinesToPresent = 40;
% strUnitColor = ['y','g','c','r'];
% for iChannelIter=1:g_strctNeuralServer.m_iNumActiveSpikeChannels
%     for iUnitIter=1:g_strctNeuralServer.m_iNumberUnitsPerChannel
%
%         iNumValidSamples = min(iMaxRasterLinesToPresent,g_strctNeuralServer.m_strctBuffer.m_a2iSpikes_NumValidSamples(iChannelIter,iUnitIter));
%
%         aiValidIndices = g_strctNeuralServer.m_strctBuffer.m_iTrialCounter-1:-1:g_strctNeuralServer.m_strctBuffer.m_iTrialCounter-iNumValidSamples;
%         aiValidIndices(aiValidIndices<1) = aiValidIndices(aiValidIndices<1)+iTrialHistoryLength;
%
%         a2fTrialSpikes = squeeze(g_strctNeuralServer.m_strctBuffer.m_a4fSpikeTS_Buffer(aiValidIndices,iChannelIter, iUnitIter,:));
%         a2iLine = [1:size(a2fTrialSpikes,1)]' * ones(1,size(a2fTrialSpikes,2));
%         abValidSpikes= ~isnan(a2fTrialSpikes);
%
%         if sum(abValidSpikes(:)) >0
%             % Realign spike times to trial onset ?
%             plot(a2fTrialSpikes(abValidSpikes),a2iLine(abValidSpikes),'.','parent', g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(iChannelIter,1+iUnitIter),'color',strUnitColor(iUnitIter));
%         else
%             cla(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(iChannelIter,1+iUnitIter))
%         end
%     end
% end
% % X=g_strctNeuralServer.m_strctBuffer.m_a3fLFP_Buffer(aiValidIndices, iChannelIter,:)
% %
% % g_strctWindows
%
