function fnDisplayOddOneOutBehavior(ahPanels,strctStatistics)
hParent = ahPanels(1);
h1 = tightsubplot(2,2,1,'Spacing',0.2,'Parent',hParent);
plot(h1,strctStatistics.m_afRunningAvg);
xlabel('Valid Trials');
ylabel('Correct Perc');
h2 = tightsubplot(2,2,2,'Spacing',0.2,'Parent',hParent);
pie([strctStatistics.m_iNumCorrect,strctStatistics.m_iNumIncorrect,strctStatistics.m_iNumTimeout],{'Correct','Incorrect','Timeout'},'parent',h2)
h3 = tightsubplot(2,1,2,'Spacing',0.4,'Parent',hParent);
imagesc(strctStatistics.m_a2fConfusionMatrix,'parent',h3);
colormap jet
hold on;
for i=1:size(strctStatistics.m_a2fConfusionMatrix,1)
    for j=1:size(strctStatistics.m_a2fConfusionMatrix,2)
        text(i,j,sprintf('%.2f',strctStatistics.m_a2fConfusionMatrix(i,j)),'color',[1 1 1]);
    end
end
set(gca,'xtick',1:size(strctStatistics.m_a2fConfusionMatrix,2))
set(gca,'ytick',1:size(strctStatistics.m_a2fConfusionMatrix,1))
set(gca,'xticklabel',strctStatistics.m_acCatNames);
set(gca,'yticklabel',strctStatistics.m_acCatNames);
xlabel('Odd Category');
ylabel('Same Category');
colorbar
 return;

