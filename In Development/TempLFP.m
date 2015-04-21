for k=1:length(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(:))
    cla(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(k));
end

for k=1:length(g_strctWindows.m_strctStatPanel.m_a2hPlotSubAxes(:))
    cla(g_strctWindows.m_strctStatPanel.m_a2hPlotSubAxes(k));
end

set(g_strctWindows.m_strctStatPanel.m_a2hPushButtons(:,2:end),'visible','off')
set(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(:),'visible','off')
set(g_strctWindows.m_strctStatPanel.m_a2hPlotSubAxes(:),'visible','off')

OffsetX = 0.1;
OffsetY = -0.1;
     fHorizSpacing = 0.05;
        fVerticalSpacing = 0.05;
  
a2hPlotAxes2x2 = zeros(2,2);
for i=1:2
    for j=1:2
        
            fCenterX = j * 1.2* 1/(3) - OffsetX;
            fCenterY = 1- (1.2*i * 1/(3));
            fWidth = 1/3 - fHorizSpacing;
            fHeight = 1/3 - fVerticalSpacing - 0.05;
           aiAxesPosition = [fCenterX-fWidth/2,fCenterY-fHeight/2-OffsetY,fWidth,fHeight];
     
        a2hPlotAxes2x2(i,j) = axes('Position', aiAxesPosition, 'Parent',g_strctWindows.m_strctStatPanel.m_hPanel);
        box(a2hPlotAxes2x2(i,j),'on');
    end
end

delete(a2hPlotAxes2x2)



[a4fPSTH, a3fLFP,afLFP_Time, afSpike_Time, a3fWaveFormAvg,a3fWaveFormVar] = TrialCircularBuffer('GetAllPSTH');
A=squeeze(a3fLFP(:,1,:));
figure(2);
clf;
imagesc(afLFP_Time,1:size(A, 2),A');

