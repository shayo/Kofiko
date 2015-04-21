function fnDisplayTrialRaster(hAxis,strctRaster,bShowLegend)
if isempty(strctRaster)
    return;
end;

if isfield(strctRaster,'m_a2bRaster')
    Raster = strctRaster.m_a2bRaster;
else
    Raster = strctRaster.m_a2fRaster;
end
iNumTrials = size(Raster,1);
axis(hAxis);
imagesc(strctRaster.m_aiRasterTimeMS,1:iNumTrials,Raster,'parent',hAxis);
axis xy
hold on;
h1=plot([0 0],[-1 iNumTrials+1],'r');
for k=1:iNumTrials
    h2=plot(strctRaster.m_afCenterImageOFF_TrialTS(k)*1e3*ones(1,2),[k-0.5 k+0.5],'g');
    h3=plot(strctRaster.m_afDecisionsImageON_TrialTS(k)*1e3*ones(1,2),[k-0.5 k+0.5],'c');
    h4=plot(strctRaster.m_afSaccade_TrialTS(k)*1e3*ones(1,2),[k-0.5 k+0.5],'m');
end
if strcmp(class(Raster),'uint8')
    colormap gray
else
    colormap jet
end
if exist('bShowLegend','var') && bShowLegend
%afMean = mean(Raster,1);
legend([h1,h2,h3,h4],{'Center Image ON','Center Image OFF','Decisions ON','Saccade'},'Location','SouthOutside');
strctRaster.m_strTitle(strctRaster.m_strTitle == '_') = ' ';
end
title(strctRaster.m_strTitle);
% % [AX,H1,H2] = plotyy([0 0],[-1 iNumTrials+1],strctRaster.m_aiRasterTimeMS,afMean/max(afMean));
% % set(H1,'color','r');
% % set(H2,'color','w');
% % set(H2,'linewidth',2);
% % hY1 = get(AX(1),'ylabel');
% % hY2 = get(AX(2),'ylabel');
% % 
% % set(hY1,'String','Trials','Color','k');
% % set(AX(1),'ycolor','k');
% % set(hY2,'String','Normalized Firing Rate','Color','k');
% % set(AX(2),'Xtick',[])
% % set(AX(2),'ycolor','k');
% % axis(AX(1),[strctRaster.m_aiRasterTimeMS(1), strctRaster.m_aiRasterTimeMS(end),1, iNumTrials])
% % axis(AX(2),[strctRaster.m_aiRasterTimeMS(1), strctRaster.m_aiRasterTimeMS(end),0, 2])
% % % hAxis2 = fnSecondYAxis(hAxis1);
% % % plot(hAxis2,strctRaster.m_aiRasterTimeMS,mean(Raster,1),'w');
return;
