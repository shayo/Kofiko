function fnDisplayBlockDesignExperiment(ahPanels,strctUnit)
h1 = tightsubplot(2,1,1,'Spacing',0.1,'Parent',ahPanels(1));
iNumBlocks = length(strctUnit.m_abCorrectBlock);
iNumImages = length(strctUnit.m_abCorrectTrial);
hold on;
for k=1:iNumBlocks
    if mod(k,2) == 0
        afColor = [0.5 0.5 0.5];
    else
        afColor = [0.8 0.8 0.8];
    end
    fStartTime = strctUnit.m_fBlockLengthSec * (k-1);
    rectangle('Position',[fStartTime -50 strctUnit.m_fBlockLengthSec 1050],'facecolor', afColor);
    strDescr = strctUnit.m_acBlocks{k};
    strDescr(strDescr=='_') = ' ';
    text(fStartTime,-30, strDescr,'FontSize',7,'color',[1 1 1]);
end
afTime = strctUnit.m_afStimulusOnsetTS-strctUnit.m_afStimulusOnsetTS(1);
plot(h1,afTime,strctUnit.m_afAvgEyePosFromFixationSpot);
xlabel('Time (sec)');
ylabel('Distance from fixation spot');
axis([1 iNumBlocks*strctUnit.m_fBlockLengthSec -50 500])

h2 = tightsubplot(2,2,3,'Spacing',0.1,'Parent',ahPanels(1));
iCorrect = sum(strctUnit.m_abCorrectTrial);
iIncorrect = sum(~strctUnit.m_abCorrectTrial);
explode = [1 0];
pie(h2,[iCorrect,iIncorrect] ,explode)
legend({'Fixation','Non Fixated'},'Location','NorthEastOutside');
title(sprintf('%d Trials',iCorrect+iIncorrect));
  

h3 = tightsubplot(2,2,4,'Spacing',0.1,'Parent',ahPanels(1));
iCorrect = sum(strctUnit.m_abCorrectBlock);
iIncorrect = sum(~strctUnit.m_abCorrectBlock);
explode = [1 0];
pie(h3,[iCorrect,iIncorrect] ,explode)
legend({'Fixation','Non Fixated'},'Location','NorthEastOutside');
title(sprintf('%d Blocks',iCorrect+iIncorrect));
  

