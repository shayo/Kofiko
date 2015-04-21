function fnDisplayForceChoiceParadigm(ahPanels,strctUnit)
%strctUnit.m_acRasters = strctUnit.m_acRasters(3:4); 
iNumRasters = length(strctUnit.m_acRasters);
iGridSize = ceil(sqrt(iNumRasters));


a2fColors= lines(iNumRasters);

hParent = ahPanels(2);
for iRasterIter=1:iNumRasters
    if ~isempty(strctUnit.m_acRasters{iRasterIter})
         hAxis = tightsubplot(iGridSize,iGridSize,iRasterIter,'Spacing',0.1,'Parent',hParent);
         hold on;
         ahHandle(iRasterIter) = fnFancyPlot2(strctUnit.m_afLFPTime ,...
                     strctUnit.m_acRasters{iRasterIter}.m_afAvgLFP,...
                     strctUnit.m_acRasters{iRasterIter}.m_afStdLFP,...
                     a2fColors(iRasterIter,:),...
                     a2fColors(iRasterIter,:)*0.5);    
    strctUnit.m_acRasters{iRasterIter}.m_strTitle(strctUnit.m_acRasters{iRasterIter}.m_strTitle == '_') = ' ';
        title(strctUnit.m_acRasters{iRasterIter}.m_strTitle);

        
        aiLim = axis(hAxis);
        fImageOFF = 1e3*median(strctUnit.m_acRasters{1}.m_afCenterImageOFF_TrialTS);
        fDecisionON = 1e3*median(strctUnit.m_acRasters{1}.m_afDecisionsImageON_TrialTS);
        fSaccade = 1e3*median(strctUnit.m_acRasters{1}.m_afSaccade_TrialTS);
        
        plot([0 0],aiLim(3:4),'r','LineWidth',2);
        
        plot([fImageOFF fImageOFF],aiLim(3:4),'g','LineWidth',2);
        
        plot([fDecisionON fDecisionON],aiLim(3:4),'b','LineWidth',2);
        plot([fSaccade fSaccade],aiLim(3:4),'m','LineWidth',2);
        
        
        
    end
end

%%

%delete(get(hParent,'children'))
hParent = ahPanels(1);

for iRasterIter=1:iNumRasters
    if ~isempty(strctUnit.m_acRasters{iRasterIter})
        hAxis = tightsubplot(iGridSize,iGridSize,iRasterIter,'Spacing',0.1,'Parent',hParent);
        fnDisplayTrialRaster(hAxis,strctUnit.m_acRasters{iRasterIter});
    end
end


hParent = ahPanels(3);
%hAxis = tightsubplot(2,1,1,'Spacing',0.2,'Parent',hParent);
hAxis = axes('Parent',hParent);
hold(hAxis,'on');

acRasterTitles = cell(1,iNumRasters);
iCounter = 0;
for iRasterIter=1:iNumRasters
    if ~isempty(strctUnit.m_acRasters{iRasterIter})
        acRasterTitles{iCounter+1} = strctUnit.m_acRasters{iRasterIter}.m_strTitle;
        iCounter = iCounter + 1;
        
        afStd = std(strctUnit.m_acRasters{iRasterIter}.m_a2fRaster,1)/sqrt( size(strctUnit.m_acRasters{iRasterIter}.m_a2fRaster,1));
        ahHandle(iRasterIter) = fnFancyPlot2(strctUnit.m_acRasters{iRasterIter}.m_aiRasterTimeMS,...
                     mean(strctUnit.m_acRasters{iRasterIter}.m_a2fRaster,1),...
                     afStd,...
                     a2fColors(iRasterIter,:),...
                     a2fColors(iRasterIter,:)*0.5);
                 
        
%         plot(strctUnit.m_acRasters{iRasterIter}.m_aiRasterTimeMS, ...
%             mean(strctUnit.m_acRasters{iRasterIter}.m_a2fRaster,1),'color',a2fColors(iRasterIter,:));
        
    end
end
legend(ahHandle,acRasterTitles(1:iCounter),'Location','SouthOutside')
hold on;

aiLim = axis(hAxis);
fImageOFF = 1e3*median(strctUnit.m_acRasters{1}.m_afCenterImageOFF_TrialTS);
fDecisionON = 1e3*median(strctUnit.m_acRasters{1}.m_afDecisionsImageON_TrialTS);
fSaccade = 1e3*median(strctUnit.m_acRasters{1}.m_afSaccade_TrialTS);

plot([0 0],aiLim(3:4),'r','LineWidth',2);

plot([fImageOFF fImageOFF],aiLim(3:4),'g','LineWidth',2);

plot([fDecisionON fDecisionON],aiLim(3:4),'b','LineWidth',2);
plot([fSaccade fSaccade],aiLim(3:4),'m','LineWidth',2);
%%


%         
% legend(ahHandle,acRasterTitles(1:iCounter),'Location','SouthOutside')
% hold on;
% 
% aiLim = axis(hAxis);
% fImageOFF = 1e3*median(strctUnit.m_acRasters{1}.m_afCenterImageOFF_TrialTS);
% fDecisionON = 1e3*median(strctUnit.m_acRasters{1}.m_afDecisionsImageON_TrialTS);
% fSaccade = 1e3*median(strctUnit.m_acRasters{1}.m_afSaccade_TrialTS);
% 
% plot([0 0],aiLim(3:4),'r','LineWidth',2);
% 
% plot([fImageOFF fImageOFF],aiLim(3:4),'g','LineWidth',2);
% 
% plot([fDecisionON fDecisionON],aiLim(3:4),'b','LineWidth',2);
% plot([fSaccade fSaccade],aiLim(3:4),'m','LineWidth',2);
return;

