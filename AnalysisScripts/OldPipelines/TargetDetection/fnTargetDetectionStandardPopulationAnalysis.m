function fnTargetDetectionStandardPopulationAnalysis(acStatistics, strctConfig)
% Do population analysis

% First, sort by time
afTime = zeros(1,length(acStatistics));
for k=1:length(acStatistics)
    afTime(k) = datenum(acStatistics{k}.m_strRecordedTimeDate);
end
[afDummy,aiIndices ] = sort(afTime);

acStatistics = acStatistics(aiIndices);

% performance imporvement across days...

abCorrect = [];
abIncorrect = [];
abTimeout = [];
abShortHold = [];
afLatency = [];
afPerformancePerDay = zeros(1,length(acStatistics));
aiNumDist = [];
for iIter=1:length(acStatistics)
    abCorrect = [abCorrect, acStatistics{iIter}.m_abCorrect];
    abIncorrect = [abIncorrect, acStatistics{iIter}.m_abIncorrect];
    abTimeout = [abTimeout,  acStatistics{iIter}.m_abTimeout];
    abShortHold = [abShortHold,  acStatistics{iIter}.m_abShortHold];    
    afLatency = [afLatency, acStatistics{iIter}.m_afLatency];
    aiNumDist = [aiNumDist,acStatistics{iIter}.m_aiNumDistractors];
    afPerformancePerDay(iIter) = sum(acStatistics{iIter}.m_abCorrect) / acStatistics{iIter}.m_iNumTrials * 100;
end

aiNumUniqueDist = unique(aiNumDist);
iNumValues = length(aiNumUniqueDist);
aiNumCorrect = zeros(1,iNumValues);
aiNumIncorrect = zeros(1,iNumValues);
aiNumTimeout = zeros(1,iNumValues);
aiNumShortHold = zeros(1,iNumValues);
afPerformance = zeros(1,iNumValues);
afMeanLatencyPerDis = zeros(1,iNumValues);
afStdLatencyPerDis = zeros(1,iNumValues);
aiNumSamples = zeros(1,iNumValues);
for k=1:iNumValues
    aiNumSamples(k) = sum(aiNumDist ==aiNumUniqueDist(k));
   aiNumCorrect(k) = sum(abCorrect(aiNumDist ==aiNumUniqueDist(k)));
   aiNumIncorrect(k) = sum(abIncorrect(aiNumDist ==aiNumUniqueDist(k)));   
   aiNumTimeout(k) = sum(abTimeout(aiNumDist ==aiNumUniqueDist(k)));   
   aiNumShortHold(k) = sum(abShortHold(aiNumDist ==aiNumUniqueDist(k)));      
   afMeanLatencyPerDis(k) = mean(afLatency(aiNumDist ==aiNumUniqueDist(k)));      
   afStdLatencyPerDis(k)= std(afLatency(aiNumDist ==aiNumUniqueDist(k)));      
   afPerformance(k) = aiNumCorrect(k) / (aiNumCorrect(k) + aiNumIncorrect(k)) * 100;
end

figure;clf;
subplot(3,1,1);
plot(afPerformancePerDay);
hold on;
plot(afPerformancePerDay,'r.');
title('Performance across sessions');
xlabel('Sessions');
ylabel('% Correct');

subplot(3,1,2);
bar(aiNumUniqueDist, [aiNumCorrect', aiNumIncorrect', aiNumTimeout',aiNumShortHold']);
xlabel('Num Distractors');
ylabel('# Trials');
legend({'Correct','Incorrect','Timeout','Short Hold'},'Location','NorthEastOutside');

subplot(3,1,3);
bar(aiNumUniqueDist,[afPerformance; 1./(aiNumUniqueDist+1)*100]');
xlabel('Num Distractors');
ylabel('Performance');
legend({'Monkey','Chance level'},'Location','NorthEastOutside');


figure;clf;
errorbar(aiNumUniqueDist,afMeanLatencyPerDis,afStdLatencyPerDis./sqrt(aiNumSamples));
hold on;
xlabel('Num Distractors');
ylabel('Seconds');
title('Latency');

