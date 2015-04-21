function fnDisplayForceChoiceClassificationImageBehavior(ahPanels,strctStatistics)
hParent = ahPanels(1);
h1 = tightsubplot(2,1,1,'Spacing',0.2,'Parent',hParent);

aiValues = [strctStatistics.m_iNumCorrect, ...
 strctStatistics.m_iNumIncorrect,...
 strctStatistics.m_iNumTimeout,...
 strctStatistics.m_iNumShortHold ];
acDescr = {'Correct','Incorrect','Timeout','Short Hold'};
aiExplode = [1 0 0 0];
pie(h1,aiValues(aiValues>0),aiExplode(aiValues>0))
legend(acDescr(aiValues>0),'Location','NorthEastOutside');

strDesignName = strctStatistics.m_strParadigmDesc;
strDesignName(strDesignName=='_') = ' ';
title(sprintf('%s %d Trials',strDesignName,strctStatistics.m_iNumTrials));

h1 = tightsubplot(2,1,2,'Spacing',0.2,'Parent',hParent);

[AX,H1,H2]=plotyy(strctStatistics.m_strctPerformance.m_afNoiseLevels,strctStatistics.m_strctPerformance.m_afPercCorrect*1e2,...
    strctStatistics.m_strctPerformance.m_afNoiseLevels,strctStatistics.m_strctPerformance.m_aiNumTrialsPerBin);
set(get(AX(1),'ylabel'),'String','Percent correct')
set(get(AX(2),'ylabel'),'String','Number of trials')
set(get(AX(1),'xlabel'),'String','Noise levels')

 return;

