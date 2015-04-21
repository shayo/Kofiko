function fnDisplayForceChoiceClassificationImage(ahPanels,strctUnit)
iNumRasters = length(strctUnit.m_acRasters);
iGridSize = ceil(sqrt(iNumRasters));
%delete(get(hParent,'children'))
hParent = ahPanels(1);

for iRasterIter=1:iNumRasters
    if ~isempty(strctUnit.m_acRasters{iRasterIter})
        hAxis = tightsubplot(iGridSize,iGridSize,iRasterIter,'Spacing',0.1,'Parent',hParent);
        fnDisplayTrialRaster(strctUnit.m_acRasters{iRasterIter});
    end
end

hParent = ahPanels(2);
hAxis = tightsubplot(2,1,1,'Spacing',0.2,'Parent',hParent);
hold(hAxis,'on');

acRasterTitles = cell(1,iNumRasters);
a2fColors= lines(iNumRasters);
iCounter = 0;
for iRasterIter=1:iNumRasters
    if ~isempty(strctUnit.m_acRasters{iRasterIter})
        acRasterTitles{iCounter+1} = strctUnit.m_acRasters{iRasterIter}.m_strTitle;
        iCounter = iCounter + 1;
        plot(strctUnit.m_acRasters{iRasterIter}.m_aiRasterTimeMS, ...
            mean(strctUnit.m_acRasters{iRasterIter}.m_a2fRaster,1),'color',a2fColors(iRasterIter,:));
    end
end
legend(acRasterTitles(1:iCounter))
hold on;

for k=1:length(strctUnit.m_acRasters)
    if ~isempty(strctUnit.m_acRasters{k})
        iInd = k;
        break;
    end;
end;
aiLim = axis(hAxis);
fImageOFF = 1e3*median(strctUnit.m_acRasters{iInd}.m_afCenterImageOFF_TrialTS);
fDecisionON = 1e3*median(strctUnit.m_acRasters{iInd}.m_afDecisionsImageON_TrialTS);
fSaccade = 1e3*median(strctUnit.m_acRasters{iInd}.m_afSaccade_TrialTS);

plot([0 0],aiLim(3:4),'r','LineWidth',2);

plot([fImageOFF fImageOFF],aiLim(3:4),'g','LineWidth',2);

plot([fDecisionON fDecisionON],aiLim(3:4),'b','LineWidth',2);
plot([fSaccade fSaccade],aiLim(3:4),'m','LineWidth',2);

afAllNoise = [];
for k=1:4
    if ~isempty(strctUnit.m_acRasters{k})
        afAllNoise = [afAllNoise,strctUnit.m_acRasters{k}.m_afNoiseLevel ];
    end
end
title(sprintf('Mean noise level: %.2f',mean(afAllNoise)));

return;

