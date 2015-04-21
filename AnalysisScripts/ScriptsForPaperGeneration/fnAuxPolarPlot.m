function fnAuxPolarPlot(a2fPopulationNoStimCue,a2fPopulationStimCue, afBinTimeCue, a2bSig,fMaxValue,bText)
if ~exist('bText','var')
    bText = false;
end
afGreen = [34,177,76]/255;

iNumBinsCue = length(afBinTimeCue);
a2fTargetCenter = [200 0;
    -200 0;
    0 -200;
    0 200;
    140 -140;
    140 140;
    -140 -140;
    -140 140];
a2fTargetCenterDir=a2fTargetCenter./ repmat(sqrt(sum(a2fTargetCenter.^2,2)),1,2);
aiOrder = [1,5,3,7,2,8,4,6,1];

for iBinIter=1:iNumBinsCue
    if length(afBinTimeCue) > 1
        tightsubplot(5,7,iBinIter,'Spacing',0.05);
    end
    fnPlotPolarGrid(0, fMaxValue, 4,bText);
    afX = a2fTargetCenterDir(:,1) .* a2fPopulationNoStimCue(:,iBinIter);
    afY = -a2fTargetCenterDir(:,2) .* a2fPopulationNoStimCue(:,iBinIter);
    afXs = a2fTargetCenterDir(:,1) .* a2fPopulationStimCue(:,iBinIter);
    afYs = -a2fTargetCenterDir(:,2) .* a2fPopulationStimCue(:,iBinIter);
    plot(afX(aiOrder),afY(aiOrder),'k','LineWidth',2);
    plot(afXs(aiOrder),afYs(aiOrder),'color',afGreen,'LineWidth',2);
    if ~isempty(a2bSig)
        abSig = a2bSig(:,iBinIter);
        plot(afX(abSig),afY(abSig),'r.');
        plot(afXs(abSig),afYs(abSig),'r.');
    end
    if length(afBinTimeCue) > 1
        title(sprintf('%d',afBinTimeCue(iBinIter)));
    end
end
return;
