aiTrialType = 2:9;
for iIter=1:length(aiTrialType)
    iTrialType = aiTrialType(iIter)
iCorrect = 2;
clear a2fDirections afAmplitude a2fDirectionsMicroStim afAmplitudeMicroStim
for k=1:length(a2cTrialStat{iTrialType,iCorrect})
   a2fDirections(:,k) = a2cTrialStat{iTrialType,iCorrect}(k).m_afSaccadeDirection;
   afAmplitude(:,k) = a2cTrialStat{iTrialType,iCorrect}(k).m_fSaccadeAmplitude;
end
for k=1:length(a2cTrialStat{8+iTrialType,iCorrect})
   a2fDirectionsMicroStim(:,k) = a2cTrialStat{8+iTrialType,iCorrect}(k).m_afSaccadeDirection;
   afAmplitudeMicroStim(:,k) = a2cTrialStat{8+iTrialType,iCorrect}(k).m_fSaccadeAmplitude;
end

figure(16);
subplot(2,4,iIter);
hold on;
for k=1:length(a2cTrialStat{iTrialType,iCorrect})
    plot([0 a2fDirections(1,k)*afAmplitude(k)],[0 a2fDirections(2,k)*afAmplitude(k)],'b');
end
for k=1:length(a2cTrialStat{8+iTrialType,iCorrect})
    plot([0 a2fDirectionsMicroStim(1,k)*afAmplitudeMicroStim(k)],[0 a2fDirectionsMicroStim(2,k)*afAmplitudeMicroStim(k)],'g');
end
axis equal
axis([-150 150 -150 150]);

%%
figure(17);
subplot(2,4,iIter);
[afHist1,afCent]=hist(afAmplitude,50:10:400);
[afHist2,afCent]=hist(afAmplitudeMicroStim,50:10:400);
plot(afCent,afHist1,afCent,afHist2);

figure(18);
subplot(2,4,iIter);

h1=rose(atan2(a2fDirections(2,:),a2fDirections(1,:)),100);hold on;set(h1,'linewidth',3);
h2=rose(atan2(a2fDirectionsMicroStim(2,:),a2fDirectionsMicroStim(1,:)),100);
set(h2,'Color','g');
end