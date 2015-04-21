function ahSubPlots = fnDisplayTargetDetectionExperiment(ahPanels,strctStatistics)
hParent = ahPanels(1);
h1 = tightsubplot(2,2,1,'Spacing',0.1,'Parent',hParent);

iCorrect = sum(strctStatistics.m_abCorrect);
iIncorrect = sum(strctStatistics.m_abIncorrect);
iTimeout= sum(strctStatistics.m_abTimeout);
iShortHold= sum(strctStatistics.m_abShortHold);

explode = [1 0 0 0];
pie(h1,eps+[iCorrect,iIncorrect iTimeout iShortHold] ,explode)
legend({'Correct','Incorrect','Timeout','Short Hold'},'Location','NorthEastOutside');
title(sprintf('Overall Performance on %d trials',strctStatistics.m_iNumTrials));

aiNumDist = unique(strctStatistics.m_aiNumDistractors);
iNumValues = length(aiNumDist);
aiNumCorrect = zeros(1,iNumValues);
aiNumIncorrect = zeros(1,iNumValues);
aiNumTimeout= zeros(1,iNumValues);
aiNumShortHold = zeros(1,iNumValues);
afMeanLatency = zeros(1,iNumValues);
afStdLatency = zeros(1,iNumValues);
afMeanLatencyCorr = zeros(1,iNumValues);
afStdLatencyCorr = zeros(1,iNumValues);
afMeanLatencyInCorr = zeros(1,iNumValues);
afStdLatencyInCorr = zeros(1,iNumValues);
afPerformance = zeros(1,iNumValues);
afChanceLevel = zeros(1,iNumValues);
for k=1:iNumValues
   aiNumCorrect(k) = sum(strctStatistics.m_abCorrect(strctStatistics.m_aiNumDistractors ==aiNumDist(k)));
   aiNumIncorrect(k) = sum(strctStatistics.m_abIncorrect(strctStatistics.m_aiNumDistractors ==aiNumDist(k)));   
   aiNumTimeout(k) = sum(strctStatistics.m_abTimeout(strctStatistics.m_aiNumDistractors ==aiNumDist(k)));   
   aiNumShortHold(k) = sum(strctStatistics.m_abShortHold(strctStatistics.m_aiNumDistractors ==aiNumDist(k)));      
   
   afPerformance(k) = aiNumCorrect(k) /  (aiNumIncorrect(k)+aiNumCorrect(k)) * 100;
   afChanceLevel(k) = 1/(aiNumDist(k)+1) * 100;
   
   afMeanLatency(k) = mean(strctStatistics.m_afLatency(strctStatistics.m_aiNumDistractors ==aiNumDist(k)));      
   afStdLatency(k) = std(strctStatistics.m_afLatency(strctStatistics.m_aiNumDistractors ==aiNumDist(k)));      
   
   afMeanLatencyCorr(k) = mean(strctStatistics.m_afLatency(strctStatistics.m_abCorrect & strctStatistics.m_aiNumDistractors ==aiNumDist(k)));      
   afStdLatencyCorr(k) = std(strctStatistics.m_afLatency(strctStatistics.m_abCorrect & strctStatistics.m_aiNumDistractors ==aiNumDist(k)));      
   afMeanLatencyInCorr(k) = mean(strctStatistics.m_afLatency(strctStatistics.m_abCorrect & strctStatistics.m_aiNumDistractors ==aiNumDist(k)));      
   afStdLatencyInCorr(k) = std(strctStatistics.m_afLatency(strctStatistics.m_abCorrect & strctStatistics.m_aiNumDistractors ==aiNumDist(k)));      
   
end
h2 = tightsubplot(2,2,2,'Spacing',0.2,'Parent',hParent);
if length(aiNumDist) > 1
    bar(aiNumDist, [aiNumCorrect', aiNumIncorrect', aiNumTimeout',aiNumShortHold'],'parent',h2)
else
    aiNumDist = [0,aiNumDist];
    afMeanLatency = [0,afMeanLatency];
    afStdLatency = [0,afStdLatency];
    afMeanLatencyCorr = [0,afMeanLatencyCorr];
    afMeanLatencyInCorr = [0,afMeanLatencyInCorr];
    afPerformance = [0,afPerformance];
    bar(aiNumDist,[0,0,0,0;aiNumCorrect, aiNumIncorrect, aiNumTimeout,aiNumShortHold],'group','parent',h2)
end
xlabel('Num Distrators');
ylabel('# Trials');

h3 = tightsubplot(2,2,3,'Spacing',0.2,'Parent',hParent);
bar(aiNumDist, afPerformance);
hold on;
plot(aiNumDist, afChanceLevel,'r*');
xlabel('Num Distrators');
ylabel('% Correct');

% hParent = ahPanels(2);
% h3 = tightsubplot(2,2,3,'Spacing',0.2,'Parent',hParent);
% bar(aiNumDist, afMeanLatency,'parent',h3)
% hold on;
% errorbar(aiNumDist,afMeanLatency,afStdLatency,'r');
% title('Latency (all trials)');
% xlabel('Num Distractors');
% ylabel('Seconds');

h4 = tightsubplot(2,2,4,'Spacing',0.2,'Parent',hParent);
bar(aiNumDist, [afMeanLatencyCorr',afMeanLatencyInCorr'],'parent',h4)
xlabel('Num Distractors');
ylabel('Seconds');
title('Latency, split');
legend({'Correct','Incorrect'},'Location','NorthOutside');

%   
%    afMeanLatencyCorr(k) = mean(strctStatistics.m_afLatency(strctStatistics.m_abCorrect & strctStatistics.m_aiNumDistractors ==aiNumDist(k)));      
%    afStdLatencyCorr(k) = std(strctStatistics.m_afLatency(strctStatistics.m_abCorrect & strctStatistics.m_aiNumDistractors ==aiNumDist(k)));      
%    afMeanLatencyInCorr(k) = mean(strctStatistics.m_afLatency(strctStatistics.m_abCorrect & strctStatistics.m_aiNumDistractors ==aiNumDist(k)));      
%    afStdLatencyInCorr(k) = std(strctStatistics.m_afLatency(strctStatistics.m_abCorrect & strctStatistics.m_aiNumDistractors ==aiNumDist(k)));      

return;
