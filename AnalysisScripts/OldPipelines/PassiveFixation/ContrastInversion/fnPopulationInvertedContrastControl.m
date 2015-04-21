function fnPopulationInvertedContrastControl(acEntries,strctConfig)


% This script will accumulate the statistics from several different lists.
% It will display the PSTH for faces, cropped faces, cropped histogram
% equated faces, cropped external contours, and their inverted contrast
% versions.
%
% Questions :
% 1. Do inverted FOB contrast have longer latencies?
% 2. 

% Generate unique codes 
[a2iCodes,strctCodeIndex,acSubjects,acLists,a2iListToIndex] = fnGetUniqueExperimentCode(acEntries);
fnDisplayFOBResults(a2iCodes,strctCodeIndex,acSubjects,acLists,a2iListToIndex,acEntries,strctConfig);

fnDisplayCroppedFOBResults(a2iCodes,strctCodeIndex,acSubjects,acLists,a2iListToIndex,acEntries,strctConfig);





%fnDisplayAll(a2iCodes,strctCodeIndex,acSubjects,acLists,a2iListToIndex,acEntries,strctConfig);



function fnDisplayFOBResults(a2iCodes,strctCodeIndex,acSubjects,acLists,a2iListToIndex,acEntries,strctConfig)
for k=1:length(acLists), fprintf('%s\n',acLists{k});end;
iListIndexFOBv4 = find(ismember(acLists,'StandardFOB_v4_Inv'));
aiRelevantUnits = find(a2iListToIndex(iListIndexFOBv4,:) > 0);
aiEntries = a2iListToIndex(iListIndexFOBv4,aiRelevantUnits);
[afFSI, afQuality] = fnGetFSI_And_Quality(acEntries(aiEntries));
aiUnitInd = find(afFSI > 0.3 &afQuality < 0.5);
acUnits = acEntries( aiEntries(aiUnitInd));
iNumUnits = length(aiUnitInd);

a2fPopFOB = zeros(iNumUnits, 701);
a2fPopFOBInv = zeros(iNumUnits, 701);

a2fPopObjHands = zeros(iNumUnits, 701);
a2fPopObjBodies = zeros(iNumUnits, 701);
a2fPopObjGadgets = zeros(iNumUnits, 701);
a2fPopObjFruits = zeros(iNumUnits, 701);
a2fPopObjHandsInv = zeros(iNumUnits, 701);
a2fPopObjBodiesInv = zeros(iNumUnits, 701);
a2fPopObjGadgetsInv = zeros(iNumUnits, 701);
a2fPopObjFruitsInv = zeros(iNumUnits, 701);
a2fPopObjScr = zeros(iNumUnits, 701);
a2fPopObjScrInv = zeros(iNumUnits, 701);


a3fMean = zeros(5,701,iNumUnits);
a3fMeanInv = zeros(5,701,iNumUnits);

for iUnitIter=1:iNumUnits
    a2fTemp(iUnitIter,:)=acUnits{iUnitIter}.m_afAvgFirintRate_Stimulus / max(acUnits{iUnitIter}.m_a2fAvgFirintRate_Stimulus(:));
    a3fTemp(iUnitIter,:,:)=acUnits{iUnitIter}.m_a2fAvgFirintRate_Stimulus / max(acUnits{iUnitIter}.m_a2fAvgFirintRate_Stimulus(:));
    
    afResponsesNormal = mean(acUnits{iUnitIter}.m_a2fAvgFirintRate_Stimulus(17:96,251:451),2);
    afResponsesInv  = mean(acUnits{iUnitIter}.m_a2fAvgFirintRate_Stimulus(106+16:201,251:451),2);
    a2fFiringRateNormal = acUnits{iUnitIter}.m_a2fAvgFirintRate_Stimulus(17:96,:);
    a2fFiringRateInv = acUnits{iUnitIter}.m_a2fAvgFirintRate_Stimulus(106+16:201,:);
    fNormalizationFactor = max( max(a2fFiringRateNormal(:)),max(a2fFiringRateInv(:)));
    a2fFiringRateNormal = a2fFiringRateNormal / fNormalizationFactor;
    a2fFiringRateInv = a2fFiringRateInv /fNormalizationFactor ;
    
    iNumQuat = 6;
    afRange = linspace(min(afResponsesNormal),max(afResponsesNormal),iNumQuat);
    [afValues,aiInd] = histc(afResponsesNormal,afRange);
    
    %     figure(10);
    %     clf;
    %     hold on;
    %     a2fColorPos = lines(iNumQuat);
    %     acCat = cell(1,2*(iNumQuat-1));
    for k=1:iNumQuat-1
        aiIndK = find(aiInd == k);
        a3fMean(k,:,iUnitIter) = mean(a2fFiringRateNormal(aiIndK,:),1);
        %        plot(-200:500,a2fMean(k,:),'color',a2fColorPos(k,:),'LineWidth',2);
        a3fMeanInv(k,:,iUnitIter) = mean(a2fFiringRateInv(aiIndK,:),1);
        %         plot(-200:500,afMeanInv(k,:),'color',a2fColorPos(k,:),'LineWidth',2,'LineStyle','--');
        %         acCat{ 2*(k-1)+1} = sprintf('Normal   %.2f - %.2f',afRange(k),afRange(k+1));
        %         acCat{ 2*(k-1)+2} = sprintf('Inverted %.2f - %.2f',afRange(k),afRange(k+1));
    end
    %    legend(acCat);
    
    
    
    fNormalizingFactor = max([acUnits{iUnitIter}.m_a2fAvgFirintRate_Category(:);]);
    a2fPopFOB(iUnitIter,:) = acUnits{iUnitIter}.m_a2fAvgFirintRate_Category(1,:)/fNormalizingFactor;
    a2fPopFOBInv(iUnitIter,:) = acUnits{iUnitIter}.m_a2fAvgFirintRate_Category(8,:)/fNormalizingFactor;
    a2fPopObjScr(iUnitIter,:) = acUnits{iUnitIter}.m_a2fAvgFirintRate_Category(6,:)/fNormalizingFactor;
    a2fPopObjScrInv(iUnitIter,:) = acUnits{iUnitIter}.m_a2fAvgFirintRate_Category(13,:)/fNormalizingFactor;
    a2fPopObjHands(iUnitIter,:) = acUnits{iUnitIter}.m_a2fAvgFirintRate_Category(5,:)/fNormalizingFactor;
    a2fPopObjBodies(iUnitIter,:) = acUnits{iUnitIter}.m_a2fAvgFirintRate_Category(2,:)/fNormalizingFactor;
    a2fPopObjGadgets(iUnitIter,:) = acUnits{iUnitIter}.m_a2fAvgFirintRate_Category(4,:)/fNormalizingFactor;
    a2fPopObjFruits(iUnitIter,:) = acUnits{iUnitIter}.m_a2fAvgFirintRate_Category(3,:)/fNormalizingFactor;
    a2fPopObjHandsInv(iUnitIter,:) = acUnits{iUnitIter}.m_a2fAvgFirintRate_Category(12,:)/fNormalizingFactor;
    a2fPopObjBodiesInv(iUnitIter,:) = acUnits{iUnitIter}.m_a2fAvgFirintRate_Category(9,:)/fNormalizingFactor;
    a2fPopObjGadgetsInv(iUnitIter,:) = acUnits{iUnitIter}.m_a2fAvgFirintRate_Category(11,:)/fNormalizingFactor;
    a2fPopObjFruitsInv(iUnitIter,:) = acUnits{iUnitIter}.m_a2fAvgFirintRate_Category(10,:)/fNormalizingFactor;
end


figure(10);
clf;
hold on;
a2fColorPos = lines(iNumQuat);
acCat = cell(1,2*(iNumQuat-1));
for k=1:iNumQuat-1
    aiCanSum = sum(isnan(squeeze(a3fMean(k,:,:))),1) == 0;
    a2fMeanPopNonNaN = mean(a3fMean(k,:,aiCanSum),3);
    
    aiCanSum2 = sum(isnan(squeeze(a3fMeanInv(k,:,:))),1) == 0;
    a2fMeanInvPopNonNaN = mean(a3fMeanInv(k,:,aiCanSum2),3);
    
    plot(-200:500,a2fMeanPopNonNaN,'color',a2fColorPos(k,:),'LineWidth',2);
    
    plot(-200:500,a2fMeanInvPopNonNaN,'color',a2fColorPos(k,:),'LineWidth',2,'LineStyle','--');
    acCat{ 2*(k-1)+1} = sprintf('Normal   %.2f - %.2f',afRange(k),afRange(k+1));
    acCat{ 2*(k-1)+2} = sprintf('Inverted %.2f - %.2f',afRange(k),afRange(k+1));
end
legend(acCat,'Location','NorthEastOutside');
    
    

X=squeeze(mean(a3fTemp,1));
figure(11);clf;hold on;
plot(-200:500,X(1,:),'b');
plot(-200:500,X(27,:),'r'); % body 11
plot(-200:500,X(44,:),'g'); % fruit12
plot(-200:500,X(33,:),'c'); % fruit1
plot(-200:500,X(51,:),'y'); % tech 3
plot(-200:500,X(58,:),'m'); % tech 10

plot(-200:500,X(1+105,:),'b--');
plot(-200:500,X(27+105,:),'r--'); % body 11
plot(-200:500,X(44+105,:),'g--'); % fruit12
plot(-200:500,X(33+105,:),'c--'); % fruit1
plot(-200:500,X(51+105,:),'y--'); % tech 3
plot(-200:500,X(58+105,:),'m--'); % tech 10
legend({'face','body11','fruit12','fruit1','tech3','tech10','inv face','inv body11','inv fruit12','inv fruit1','inv tech3','inv tech10'},'location','northeastoutside');

Tmp = (a2fPopObjHands + a2fPopObjBodies + a2fPopObjGadgets + a2fPopObjFruits)/4;
TmpInv = (a2fPopObjHandsInv + a2fPopObjBodiesInv + a2fPopObjGadgetsInv + a2fPopObjFruitsInv)/4;

% % 
% % afAvgResponsesNormal = mean(a3fResponsesNormal,2);
% % afAvgResponsesInv = mean(a3fResponsesInv,2);
% % [afHistNormal,aiIndNormal]=histc(afAvgResponsesNormal(17:96), linspace(min(afAvgResponsesNormal(17:96)),max(afAvgResponsesNormal(17:96)),5))
% % [afHistInv,aiIndInv]=histc(afAvgResponsesInv(17:96), linspace(min(afAvgResponsesInv(17:96)),max(afAvgResponsesInv(17:96)),5))
% % 
% aiTrueCategory = [ones(1,16),2*ones(1,16),3*ones(1,16),4*ones(1,16),5*ones(1,16),6*ones(1,16)];
% figure(101);
% plot(aiTrueCategory,aiIndNormal,'b.');
% plot(aiIndInv)

% Statistical tests
aiPeri = -200:500;
aiStartAvg = find(aiPeri>=50,1,'first')
aiEndAvg = find(aiPeri<=250,1,'last')

afFaceRes = mean(a2fPopFOB(:,aiStartAvg:aiEndAvg),2)
afFaceInvRes = mean(a2fPopFOBInv(:,aiStartAvg:aiEndAvg),2)
[p,h]=ttest(afFaceRes,afFaceInvRes)

% Latency
[afDummy, aiLatencyFace] = max(a2fPopFOB,[],2);
mean(aiLatencyFace) - 200
std((aiLatencyFace))

[afDummy, aiLatencyFaceInv] = max(a2fPopFOBInv,[],2);
mean(aiLatencyFaceInv) - 200
std(aiLatencyFaceInv) 
[p,h]=ttest(aiLatencyFace,aiLatencyFaceInv)

figure(5);
clf;
hold on;
grid on 
box on
plot(-200:500,  mean(a2fPopFOB),'k','LineWidth',3);
plot(-200:500,  mean(a2fPopFOBInv),'k--','LineWidth',3);
plot(-200:500, mean(Tmp),'color',[0.7 0.5 0.3],'LineWidth',3);
plot(-200:500, mean(TmpInv),'color',[0.7 0.5 0.3],'LineWidth',3,'LineStyle','--');
xlabel('Time (ms)');
ylabel('Normalized Average Firing Rate (Hz)');
legend('Faces with external features (normal contrast)','Faces with external features (inverted Contrast)','Objects (normal contrast)','Objects (inverted contrast)','Location','northeastoutside');    


%%
iExample1 = 67;%fnFindExampleCell(acUnits,'Houdini','08-Oct-2010 09:37:10',5,1,2,'StandardFOB_v4_Inv');
iExample2 = fnFindExampleCell(acUnits,'Houdini','10-Oct-2010 09:38:34',5,1,2,'StandardFOB_v4_Inv');
Tmp1 = (a2fPopObjHands(iExample1,:) + a2fPopObjBodies(iExample1,:) + a2fPopObjGadgets(iExample1,:) + a2fPopObjFruits(iExample1,:))/4;
Tmp2 = (a2fPopObjHands(iExample2,:) + a2fPopObjBodies(iExample2,:) + a2fPopObjGadgets(iExample2,:) + a2fPopObjFruits(iExample2,:))/4;

Tmp1Inv = (a2fPopObjHandsInv(iExample1,:) + a2fPopObjBodiesInv(iExample1,:) + a2fPopObjGadgetsInv(iExample1,:) + a2fPopObjFruitsInv(iExample1,:))/4;
Tmp2Inv = (a2fPopObjHandsInv(iExample2,:) + a2fPopObjBodiesInv(iExample2,:) + a2fPopObjGadgetsInv(iExample2,:) + a2fPopObjFruitsInv(iExample2,:))/4;

figure(11);
clf;
subplot(2,1,1);
hold on;
plot(-200:500,a2fPopFOB(iExample1,:),'k','LineWidth',2);
plot(-200:500,a2fPopFOBInv(iExample1,:),'k--','LineWidth',2);
plot(-200:500,Tmp1,'color',[0.7 0.5 0.3],'LineWidth',2);
plot(-200:500,Tmp1Inv,'color',[0.7 0.5 0.3],'LineWidth',2,'LineStyle','--');
ylabel('Normalized Firing Rate (Hz)');
axis([-100 400 0 1.1]);
set(gca,'xticklabel','');
subplot(2,1,2);
hold on;
plot(-200:500,a2fPopFOB(iExample2,:),'k','LineWidth',2);
plot(-200:500,a2fPopFOBInv(iExample2,:),'k--','LineWidth',2);
plot(-200:500,Tmp2,'color',[0.7 0.5 0.3],'LineWidth',2);
plot(-200:500,Tmp2Inv,'color',[0.7 0.5 0.3],'LineWidth',2,'LineStyle','--');

xlabel('Time (ms)');
ylabel('Normalized Firing Rate (Hz)');
axis([-100 400 0 1.1]);
%%
figure(10);
clf;hold on;
fSeperation=1;
Tmp = (a2fPopObjHands + a2fPopObjBodies + a2fPopObjGadgets + a2fPopObjFruits)/4;
for k=40:70
    plot(-200:500,fSeperation*k+a2fPopFOB(k,:),'k','LineWidth',1);
    plot(-200:500,fSeperation*k+a2fPopFOBInv(k,:),'r','LineWidth',1);
    plot(-200:500,fSeperation*k+Tmp(k,:),'g','LineWidth',1);
end
%%


% P = [a2fPopObjHands;
%      a2fPopObjBodies;
%      a2fPopObjFruits;
%      a2fPopObjGadgets;];
% N = [a2fPopObjHandsInv;
%      a2fPopObjBodiesInv;
%      a2fPopObjFruitsInv;
%      a2fPopObjGadgetsInv;];
% 
% plot(-200:500, mean(P,1),'LineWidth',3,'Color',[0.7 0.5 0.3],'LineStyle','-');
% plot(-200:500, mean(N,1),'LineWidth',3,'Color',[0.7 0.5 0.3],'LineStyle','--');
% 
% 
% axis([-100 400 0 0.5]);
% xlabel('Time (ms)');
% ylabel('Average Normalized Firing Rate (Hz)');
% grid on
% box on
% legend('Faces with external contours (normal contrast)','Faces with external contours (inverted contrast)','Objects (normal contrast)','Objects (inverted contrast)','Location','NorthEastOutside');
% 
% grid off
% % Actual Statistics...
% aiPeri = -200:500;
% iStart = find(aiPeri==0,1,'first');
% iEnd = find(aiPeri==300,1,'first');
% 
% afFaces =   mean(a2fPopFOB(:,iStart:iEnd),2);
% afFacesInv =   mean(a2fPopFOBInv(:,iStart:iEnd),2);
% 
% 
% afHands = mean(a2fPopObjHands(:, iStart:iEnd),2);
% afHandsInv = mean(a2fPopObjHandsInv(:, iStart:iEnd),2);
% 
% afBodies = mean(a2fPopObjBodies(:, iStart:iEnd),2);
% afBodiesInv = mean(a2fPopObjBodiesInv(:, iStart:iEnd),2);
% 
% afFruits = mean(a2fPopObjFruits(:, iStart:iEnd),2);
% afFruitsInv = mean(a2fPopObjFruitsInv(:, iStart:iEnd),2);
% 
% afGadgets = mean(a2fPopObjGadgets(:, iStart:iEnd),2);
% afGadgetsInv = mean(a2fPopObjGadgetsInv(:, iStart:iEnd),2);
% 
% afScrambled = mean(a2fPopObjScr(:, iStart:iEnd),2);
% afScrambledInv = mean(a2fPopObjScrInv(:, iStart:iEnd),2);

return;


function fnDisplayCroppedFOBResults(a2iCodes,strctCodeIndex,acSubjects,acLists,a2iListToIndex,acEntries,strctConfig)
for k=1:length(acLists), fprintf('%s\n',acLists{k});end;
iListIndexInsEqHist = find(ismember(acLists,'StandardFOB_v4_Inv_Cropped_HistEq'));
iListIndexFOB = find(ismember(acLists,'StandardFOB_v5_Inv_Edges'));
aiRelevantUnits = find(a2iListToIndex(iListIndexFOB,:) > 0 & a2iListToIndex(iListIndexInsEqHist,:) > 0);

aiFOBExperiments = a2iListToIndex(iListIndexFOB,aiRelevantUnits);
aiFOBCroppedExperiments = a2iListToIndex(iListIndexInsEqHist,aiRelevantUnits);
[afFSI1, afQuality1] = fnGetFSI_And_Quality(acEntries(aiFOBExperiments));
[afFSI2, afQuality2] = fnGetFSI_And_Quality(acEntries(aiFOBCroppedExperiments));
%%
aiUnitInd = find(afFSI2 > 0.3 & afQuality2 < 0.5  );

iNumUnits = length(aiUnitInd);



for iUnitIter=1:iNumUnits
    %afCorr(iUnitIter) = corr(acEntries{iFOBUnitCroped}.m_afAvgFirintRate_Stimulus(1:16),aiFOBCorrectFeatureNumber');

    aiFOBUnit(iUnitIter) = aiFOBExperiments(aiUnitInd(iUnitIter));
    aiFOBUnitCroped(iUnitIter) = aiFOBCroppedExperiments(aiUnitInd(iUnitIter));
end    
    
acFOBEntries = acEntries(   aiFOBUnit);
acCroppedEntries = acEntries(   aiFOBUnitCroped);

iNumUnits = length(acFOBEntries);
%save('D:\Data\Doris\Data For Publications\Sinha\Final Data For Revised Neuron Paper\Inverted_CroppedFaces','acFOBEntries','acCroppedEntries');

a2fPopFOB = zeros(iNumUnits, 701);
a2fPopFOBInv = zeros(iNumUnits, 701);
a2fPopObjHands = zeros(iNumUnits, 701);
a2fPopObjBodies = zeros(iNumUnits, 701);
a2fPopObjGadgets = zeros(iNumUnits, 701);
a2fPopObjFruits = zeros(iNumUnits, 701);
a2fPopObjHandsInv = zeros(iNumUnits, 701);
a2fPopObjBodiesInv = zeros(iNumUnits, 701);
a2fPopObjGadgetsInv = zeros(iNumUnits, 701);
a2fPopObjFruitsInv = zeros(iNumUnits, 701);

a2fPopObjScr = zeros(iNumUnits, 701);
a2fPopObjScrInv = zeros(iNumUnits, 701);
aiFOBCorrectFeatureNumber = [12     9    12    12    10    11    12    12    10     7    11    11     8    11    11    12];

for iUnitIter=1:iNumUnits
    
    fNormalizingFactor = max([acFOBEntries{iUnitIter}.m_a2fAvgFirintRate_Category(:);
                              acCroppedEntries{iUnitIter}.m_a2fAvgFirintRate_Category(:);]);
    
    a2fPopFOB(iUnitIter,:) = acCroppedEntries{iUnitIter}.m_a2fAvgFirintRate_Category(1,:)/fNormalizingFactor;
    a2fPopFOBInv(iUnitIter,:) = acCroppedEntries{iUnitIter}.m_a2fAvgFirintRate_Category(8,:)/fNormalizingFactor;
    
    a2fPopObjScr(iUnitIter,:) = acFOBEntries{iUnitIter}.m_a2fAvgFirintRate_Category(6,:)/fNormalizingFactor;
    a2fPopObjScrInv(iUnitIter,:) = acFOBEntries{iUnitIter}.m_a2fAvgFirintRate_Category(13,:)/fNormalizingFactor;
    

    afPopObj(iUnitIter) = mean(mean(acFOBEntries{iUnitIter}.m_a2fAvgFirintRate_Stimulus(17:96, [100:300]+200 ),2))/fNormalizingFactor;
    afPopObjInv(iUnitIter) = mean(mean(acFOBEntries{iUnitIter}.m_a2fAvgFirintRate_Stimulus(122:201, [100:300]+200 ),2))/fNormalizingFactor;
    
    a2fPopObjHands(iUnitIter,:) = acFOBEntries{iUnitIter}.m_a2fAvgFirintRate_Category(5,:)/fNormalizingFactor;
    a2fPopObjBodies(iUnitIter,:) = acFOBEntries{iUnitIter}.m_a2fAvgFirintRate_Category(2,:)/fNormalizingFactor;
    a2fPopObjGadgets(iUnitIter,:) = acFOBEntries{iUnitIter}.m_a2fAvgFirintRate_Category(4,:)/fNormalizingFactor;
    a2fPopObjFruits(iUnitIter,:) = acFOBEntries{iUnitIter}.m_a2fAvgFirintRate_Category(3,:)/fNormalizingFactor;
 %   a2fPopObjEdges(iUnitIter,:) =  acFOBEntries{iUnitIter}.m_a2fAvgFirintRate_Category(16,:)/fNormalizingFactor;
    a2fPopObjHandsInv(iUnitIter,:) = acFOBEntries{iUnitIter}.m_a2fAvgFirintRate_Category(12,:)/fNormalizingFactor;
    a2fPopObjBodiesInv(iUnitIter,:) = acFOBEntries{iUnitIter}.m_a2fAvgFirintRate_Category(9,:)/fNormalizingFactor;
    a2fPopObjGadgetsInv(iUnitIter,:) = acFOBEntries{iUnitIter}.m_a2fAvgFirintRate_Category(11,:)/fNormalizingFactor;
    a2fPopObjFruitsInv(iUnitIter,:) = acFOBEntries{iUnitIter}.m_a2fAvgFirintRate_Category(10,:)/fNormalizingFactor;
end
mean(afPopObj)
[p,h]=ttest(afPopObj,afPopObjInv)

figure(5);
clf;
hold on;
grid on 
box on
plot(-200:500,  mean(a2fPopFOB),'k','LineWidth',3);
plot(-200:500,  mean(a2fPopFOBInv),'k--','LineWidth',3);

P = [a2fPopObjHands;
     a2fPopObjBodies;
     a2fPopObjFruits;
     a2fPopObjGadgets;];
N = [a2fPopObjHandsInv;
     a2fPopObjBodiesInv;
     a2fPopObjFruitsInv;
     a2fPopObjGadgetsInv;];

plot(-200:500, mean(P,1),'LineWidth',3,'Color',[0.7 0.5 0.3],'LineStyle','-');
plot(-200:500, mean(N,1),'LineWidth',3,'Color',[0.7 0.5 0.3],'LineStyle','--');

% plot(-200:500, mean(a2fPopObjEdges),'LineWidth',3,'Color',[0.7 0.5 0.3],'LineStyle','-');

axis([-100 400 0 0.75]);
% xlabel('Time (ms)');
% ylabel('Average Normalized Firing Rate (Hz)');
grid on
box on
legend('Faces (normal contrast)','Faces (inverted contrast)','Objects (normal contrast)','Objects (inverted contrast)','Location','NorthEastOutside');
set(gcf,'position',[1051         485         560         368]);
%%
figure(6);
clf;
hold on;
grid on 
box on
% plot(-200:500, mean(P,1),'r','LineWidth',2);
% plot(-200:500, mean(N,1),'r--','LineWidth',2);

plot(-200:500, mean(a2fPopObjHands),'color',0.9*[190,75,72]/255,'LineStyle','-','LineWidth',3);
plot(-200:500, mean(a2fPopObjHandsInv),'color',[190,75,72]/255,'LineStyle','--','LineWidth',3);

plot(-200:500, mean(a2fPopObjBodies),'color',0.9*[74,126,187]/255,'LineStyle','-','LineWidth',3);
plot(-200:500, mean(a2fPopObjBodiesInv),'color',[74,126,187]/255,'LineStyle','--','LineWidth',3);

plot(-200:500, mean(a2fPopObjFruits),'color',0.9*[152,185,84]/255,'LineStyle','-','LineWidth',3);
plot(-200:500, mean(a2fPopObjFruitsInv),'color',[152,185,84]/255,'LineStyle','--','LineWidth',3);

plot(-200:500, mean(a2fPopObjGadgets),'color',0.9*[200,115,255]/255,'LineStyle','-','LineWidth',3);
plot(-200:500, mean(a2fPopObjGadgetsInv),'color',[200,115,255]/255,'LineStyle','--','LineWidth',3);

plot(-200:500, mean(a2fPopObjScr),'Color',0.9*[0.3 0.3 0.3],'LineStyle','-','LineWidth',3);
plot(-200:500, mean(a2fPopObjScrInv),'Color',[0.3 0.3 0.3],'LineStyle','--','LineWidth',3);
axis([0 300 0.06 0.22])

  box on;
legend('Hands (normal contrast)','Hands (inverted contrast)','Bodies (normal contrast)','Bodies (inverted contrast)','Fruits (normal contrast)','Fruits (inverted contrast)',...
    'Gadgets (normal contrast)','Gadgets (inverted contrast)','Scrambled (normal contrast)','Scrambled (inverted contrast)','Location','NorthEastOutside');
grid off
%%

% Actual Statistics...
aiPeri = -200:500;
iStart = find(aiPeri==100,1,'first');
iEnd = find(aiPeri==250,1,'first');

iStartB = find(aiPeri==10,1,'first');
iEndB = find(aiPeri==40,1,'first');

afFaces =   mean(a2fPopFOB(:,iStart:iEnd),2);
afFacesInv =   mean(a2fPopFOBInv(:,iStart:iEnd),2);

afHands = mean(a2fPopObjHands(:, iStart:iEnd),2);
afHandsInv = mean(a2fPopObjHandsInv(:, iStart:iEnd),2);

afBodies = mean(a2fPopObjBodies(:, iStart:iEnd),2);
afBodiesInv = mean(a2fPopObjBodiesInv(:, iStart:iEnd),2);

afFruits = mean(a2fPopObjFruits(:, iStart:iEnd),2);
afFruitsInv = mean(a2fPopObjFruitsInv(:, iStart:iEnd),2);

afGadgets = mean(a2fPopObjGadgets(:, iStart:iEnd),2);
afGadgetsInv = mean(a2fPopObjGadgetsInv(:, iStart:iEnd),2);

afScrambled = mean(a2fPopObjScr(:, iStart:iEnd),2);
afScrambledInv = mean(a2fPopObjScrInv(:, iStart:iEnd),2);
% 
% afFaces =   mean(a2fPopFOB(:,iStart:iEnd),2)- mean(a2fPopFOB(:,iStartB:iEndB),2);
% afFacesInv =   mean(a2fPopFOBInv(:,iStart:iEnd),2)-mean(a2fPopFOBInv(:,iStartB:iEndB),2);
% 
% afHands = mean(a2fPopObjHands(:, iStart:iEnd),2) - mean(a2fPopObjHands(:, iStartB:iEndB),2);
% afHandsInv = mean(a2fPopObjHandsInv(:, iStart:iEnd),2) - mean(a2fPopObjHandsInv(:, iStartB:iEndB),2);
% 
% afBodies = mean(a2fPopObjBodies(:, iStart:iEnd),2) - mean(a2fPopObjBodies(:, iStartB:iEndB),2);
% afBodiesInv = mean(a2fPopObjBodiesInv(:, iStart:iEnd),2) - mean(a2fPopObjBodiesInv(:, iStartB:iEndB),2);
% 
% afFruits = mean(a2fPopObjFruits(:, iStart:iEnd),2) -  mean(a2fPopObjFruits(:, iStartB:iEndB),2);
% afFruitsInv = mean(a2fPopObjFruitsInv(:, iStart:iEnd),2) - mean(a2fPopObjFruitsInv(:, iStartB:iEndB),2);
% 
% afGadgets = mean(a2fPopObjGadgets(:, iStart:iEnd),2) - mean(a2fPopObjGadgets(:, iStartB:iEndB),2);
% afGadgetsInv = mean(a2fPopObjGadgetsInv(:, iStart:iEnd),2) - mean(a2fPopObjGadgetsInv(:, iStartB:iEndB),2);
% 
% afScrambled = mean(a2fPopObjScr(:, iStart:iEnd),2)-mean(a2fPopObjScr(:, iStartB:iEndB),2);
% afScrambledInv = mean(a2fPopObjScrInv(:, iStart:iEnd),2) - mean(a2fPopObjScrInv(:, iStartB:iEndB),2)

figure(7);
clf;

h=bar([mean(afFaces), mean(afFacesInv);
     mean(afHands),mean(afHandsInv);...
     mean(afBodies),mean(afBodiesInv);
     mean(afFruits), mean(afFruitsInv);
     mean(afGadgets), mean(afGadgetsInv);
     mean(afScrambled), mean(afScrambledInv)]);
set(gca,'xtickLabel',{'Faces','Hands','Bodies','Fruits','Gadgets','Scrambled Images'});
% ylabel('Average Normalized Firing Rate (Hz)');
legend('Normal Contrast','Inverted Contrast','Location','NorthEastOutside');
axis([0 7 0 0.7])

set(h(1),'facecolor',[79,129,189]/255);
set(h(2),'facecolor',[192,80,77]/255);

%%
[p1,h1]=ttest2(afFaces,afFacesInv)
[p2,h2]=ttest(afHands,afHandsInv)
[p3,h3]=ttest(afBodies,afBodiesInv)
[p4,h4]=ttest(afFruits,afFruitsInv)
[p5,h5]=ttest(afGadgets,afGadgetsInv)
[p6,h6]=ttest(afScrambled,afScrambledInv)

% 
% Tmp = (a2fPopObjHands + a2fPopObjBodies + a2fPopObjGadgets + a2fPopObjFruits)/4;
% 
% 
% figure(10);
% clf;hold on;
% fSeperation=1;
% for k=1:size(a2fPopFOB,1)
%     plot(-200:500,fSeperation*k+a2fPopFOB(k,:),'k','LineWidth',1);
%     plot(-200:500,fSeperation*k+a2fPopFOBInv(k,:),'r','LineWidth',1);
%     plot(-200:500,fSeperation*k+Tmp(k,:),'g','LineWidth',1);
% end

return;




function fnDisplayAll(a2iCodes,strctCodeIndex,acSubjects,acLists,a2iListToIndex,acEntries,strctConfig)
for k=1:length(acLists), fprintf('%s\n',acLists{k});end;
iListIndexInsEqHist = find(ismember(acLists,'StandardFOB_v4_Inv_Cropped_HistEq'));
iListIndexFOB = find(ismember(acLists,'StandardFOB_v5_Inv_Edges'));
iListIndexExt = find(ismember(acLists,'StandardFOB_v4_Inv_Cropped_External'));
iListIndexIns= find(ismember(acLists,'StandardFOB_v4_Inv_Cropped'));
aiRelevantUnits = find(a2iListToIndex(iListIndexFOB,:) > 0 & ...
                       a2iListToIndex(iListIndexExt,:) > 0 & ...
                       a2iListToIndex(iListIndexIns,:) > 0 & ...
                       a2iListToIndex(iListIndexInsEqHist,:) > 0 );
                   
                   

iNumUnits = length(aiRelevantUnits);

a2fPopFOB = zeros(iNumUnits, 701);
a2fPopFOBExt = zeros(iNumUnits, 701);
a2fPopFOBInv = zeros(iNumUnits, 701);
a2fPopFOBIns = zeros(iNumUnits, 701);
a2fPopFOBInsInv = zeros(iNumUnits, 701);
a2fPopFOBExtInv = zeros(iNumUnits, 701);
a2fPopFOBInsEqHist = zeros(iNumUnits, 701);
a2fPopFOBInsEqHistInv = zeros(iNumUnits, 701);
a2fPopLineDrawings = zeros(iNumUnits, 701);

a2fPopObjHands = zeros(iNumUnits, 701);
a2fPopObjBodies = zeros(iNumUnits, 701);
a2fPopObjGadgets = zeros(iNumUnits, 701);
a2fPopObjFruits = zeros(iNumUnits, 701);

a2fPopObjHandsInv = zeros(iNumUnits, 701);
a2fPopObjBodiesInv = zeros(iNumUnits, 701);
a2fPopObjGadgetsInv = zeros(iNumUnits, 701);
a2fPopObjFruitsInv = zeros(iNumUnits, 701);

afFaceSelectivityIndex = zeros(1,iNumUnits);
for iUnitIter=1:iNumUnits
    iUnitIndex = aiRelevantUnits(iUnitIter);
    
    iEntryFOB = a2iListToIndex(iListIndexFOB,iUnitIndex);
    iEntryExt = a2iListToIndex(iListIndexExt,iUnitIndex);
    iEntryIns = a2iListToIndex(iListIndexIns,iUnitIndex);
    iEntryInsEqHist = a2iListToIndex(iListIndexInsEqHist,iUnitIndex);
    
    fprintf('Unit %d\n',iEntryFOB);
    
    fNormalizingFactor = max([acEntries{iEntryFOB}.m_a2fAvgFirintRate_Category(:);...
                              acEntries{iEntryExt}.m_a2fAvgFirintRate_Category(:);...
                              acEntries{iEntryInsEqHist}.m_a2fAvgFirintRate_Category(:);...
                              acEntries{iEntryIns}.m_a2fAvgFirintRate_Category(:)]);
    
    afFOB = acEntries{iEntryFOB}.m_a2fAvgFirintRate_Category(1,:)/fNormalizingFactor;
    afFOBInv = acEntries{iEntryFOB}.m_a2fAvgFirintRate_Category(8,:)/fNormalizingFactor;
    afFOBExt = acEntries{iEntryExt}.m_a2fAvgFirintRate_Category(1,:)/fNormalizingFactor;
    afFOBExtInv = acEntries{iEntryExt}.m_a2fAvgFirintRate_Category(8,:)/fNormalizingFactor;
    afFOBIns = acEntries{iEntryIns}.m_a2fAvgFirintRate_Category(1,:)/fNormalizingFactor;
    afFOBInsInv = acEntries{iEntryIns}.m_a2fAvgFirintRate_Category(8,:)/fNormalizingFactor;
    
    a2fPopLineDrawings(iUnitIter,:) = acEntries{iEntryFOB}.m_a2fAvgFirintRate_Category(16,:)/fNormalizingFactor;
 a2fPopObjHands(iUnitIter,:) = acEntries{iEntryFOB}.m_a2fAvgFirintRate_Category(5,:)/fNormalizingFactor;
a2fPopObjBodies(iUnitIter,:) = acEntries{iEntryFOB}.m_a2fAvgFirintRate_Category(2,:)/fNormalizingFactor;
a2fPopObjGadgets(iUnitIter,:) = acEntries{iEntryFOB}.m_a2fAvgFirintRate_Category(4,:)/fNormalizingFactor;
a2fPopObjFruits(iUnitIter,:) = acEntries{iEntryFOB}.m_a2fAvgFirintRate_Category(3,:)/fNormalizingFactor;

 a2fPopObjHandsInv(iUnitIter,:) = acEntries{iEntryFOB}.m_a2fAvgFirintRate_Category(12,:)/fNormalizingFactor;
a2fPopObjBodiesInv(iUnitIter,:) = acEntries{iEntryFOB}.m_a2fAvgFirintRate_Category(9,:)/fNormalizingFactor;
a2fPopObjGadgetsInv(iUnitIter,:) = acEntries{iEntryFOB}.m_a2fAvgFirintRate_Category(11,:)/fNormalizingFactor;
a2fPopObjFruitsInv(iUnitIter,:) = acEntries{iEntryFOB}.m_a2fAvgFirintRate_Category(10,:)/fNormalizingFactor;


    afPopFOBInsEqHist = acEntries{iEntryInsEqHist}.m_a2fAvgFirintRate_Category(1,:)/fNormalizingFactor;
    afPopFOBInsEqHistInv = acEntries{iEntryInsEqHist}.m_a2fAvgFirintRate_Category(8,:)/fNormalizingFactor;
    a2fPopFOB(iUnitIter,:) = afFOB;
    a2fPopFOBExt(iUnitIter,:) = afFOBExt;
    a2fPopFOBExtInv(iUnitIter,:) = afFOBExtInv;
    a2fPopFOBInv(iUnitIter,:) = afFOBInv;
    a2fPopFOBIns(iUnitIter,:) = afFOBIns;
    a2fPopFOBInsInv(iUnitIter,:) = afFOBInsInv;
    
    a2fPopFOBInsEqHist(iUnitIter,:) = afPopFOBInsEqHist;
    a2fPopFOBInsEqHistInv(iUnitIter,:) = afPopFOBInsEqHistInv;
    
    fFaceRes = fnMyMean(acEntries{iEntryFOB}.m_afAvgFirintRate_Stimulus(1:16));
    fNonFaceRes = fnMyMean(acEntries{iEntryFOB}.m_afAvgFirintRate_Stimulus(17:96));
    afFaceSelectivityIndex(iUnitIter) = (fFaceRes-fNonFaceRes)/(fFaceRes+fNonFaceRes);
end
aiFaceSelective = find(afFaceSelectivityIndex > 0.5);
figure(4);
clf;
% tightsubplot(2,1,1);
hold on;
plot(-200:500, mean(a2fPopFOB(aiFaceSelective,:),1),'b','linewidth',3);
plot(-200:500, mean(a2fPopFOBInv(aiFaceSelective,:),1),'color',[ 0 0 0.7],'linewidth',3,'LineStyle','--');

plot(-200:500, mean(a2fPopFOBIns(aiFaceSelective,:),1),'r','linewidth',3);
plot(-200:500, mean(a2fPopFOBInsInv(aiFaceSelective,:),1),'color',[0.7 0 0 ],'linewidth',3,'LineStyle','--');

plot(-200:500, mean(a2fPopFOBExt(aiFaceSelective,:),1),'g','linewidth',3);
plot(-200:500, mean(a2fPopFOBExtInv(aiFaceSelective,:),1),'color',[0 0.7 0],'linewidth',3,'LineStyle','--');

plot(-200:500, mean(a2fPopFOBInsEqHist(aiFaceSelective,:),1),'c','linewidth',3);
plot(-200:500, mean(a2fPopFOBInsEqHistInv(aiFaceSelective,:),1),'color',[0 0.7 0.7],'linewidth',3,'LineStyle','--');

plot(-200:500, mean(a2fPopObjHands(aiFaceSelective,:),1),'m','linewidth',3);
plot(-200:500, mean(a2fPopObjBodies(aiFaceSelective,:),1),'m','linewidth',3);
plot(-200:500, mean(a2fPopObjGadgets(aiFaceSelective,:),1),'m','linewidth',3);
plot(-200:500, mean(a2fPopObjFruits(aiFaceSelective,:),1),'m','linewidth',3);
plot(-200:500, mean(a2fPopObjHandsInv(aiFaceSelective,:),1),'k','linewidth',3);
plot(-200:500, mean(a2fPopObjBodiesInv(aiFaceSelective,:),1),'k','linewidth',3);
plot(-200:500, mean(a2fPopObjGadgetsInv(aiFaceSelective,:),1),'k','linewidth',3);
plot(-200:500, mean(a2fPopObjFruitsInv(aiFaceSelective,:),1),'k','linewidth',3);

plot(-200:500, mean(a2fPopLineDrawings(aiFaceSelective,:),1),'y','linewidth',3);



axis([-100 400 0 0.6]); grid on; box on;
legend('Full Faces','Full Faces Inverted','Internal Face Region','Internal Face Region Inverted','External Face Region','External Face Region Inverted',...
    'Internal Face Region Hist Eq','Internal Face Region Hist Eq Inverted','location','northeastoutside');
% 
% tightsubplot(2,1,2);hold on;
% afAvgPopFOB =  mean(a2fPopFOB(aiFaceSelective,:),1);
% afAvgPopFobInv = mean(a2fPopFOBInv(aiFaceSelective,:),1);
% afAvgPopFOBIns = mean(a2fPopFOBIns(aiFaceSelective,:),1);
% afAvgPopFOBInsInv = mean(a2fPopFOBInsInv(aiFaceSelective,:),1);
% afAvgPopFOBExt    = mean(a2fPopFOBExt(aiFaceSelective,:),1);
% afAvgPopFOBExtInv = mean(a2fPopFOBExtInv(aiFaceSelective,:),1);
% afAvgPopFOBInsEqHist = mean(a2fPopFOBInsEqHist(aiFaceSelective,:),1);
% afAvgPopFOBInsEqHistInv = mean(a2fPopFOBInsEqHistInv(aiFaceSelective,:),1);
% 
% sum(afAvgPopFOB(250:451))



return;










function [afISIPerc] = fnGetQuality(acUnitsRAW)
% find corresponding experiments...
fQuality = 0.5; % 0.5
fISIThresholdMS = 1;
fISIThresholdPerc = 1.5;
iNumUnits =  length(acUnits);

aiNumSpikes = zeros(1,iNumUnits);
afMUA = zeros(1,iNumUnits);
afMaxStd = zeros(1,iNumUnits);
afAmpRange = zeros(1,iNumUnits);
abNoData = zeros(1,iNumUnits) > 0;
abFOBList =  zeros(1,iNumUnits) > 0;
abSinhaList  =  zeros(1,iNumUnits) > 0;
abCBCLList=  zeros(1,iNumUnits) > 0;
aiFaceSelectivity = NaN*ones(1,iNumUnits);

aiRec = zeros(1,iNumUnits);
aiUnit = zeros(1,iNumUnits);
afTime = zeros(1,iNumUnits);
for k=1:iNumUnits
    if ~isfield(acUnits{k},'m_afISIDistribution') || ~isfield(acUnits{k},'m_afSpikeTimes') 
        abNoData(k) = true;
        continue;
    end
    afTime(k) = datenum(acUnits{k}.m_strRecordedTimeDate);
    aiRec(k) = acUnits{k}.m_iRecordedSession;
    aiUnit(k) = acUnits{k}.m_iUnitID;
    
    iIndex = find(acUnits{k}.m_afISICenter <= fISIThresholdMS,1,'last');
    afISI(k) = sum(acUnits{k}.m_afISIDistribution(1:iIndex)) / sum(acUnits{k}.m_afISIDistribution) * 100;
    aiNumSpikes(k) = length(acUnits{k}.m_afSpikeTimes);
    afMUA(k) = sum(acUnits{k}.m_afISIDistribution(1:3))/  sum(acUnits{k}.m_afISIDistribution) * 100;
    afAmpRange(k) = max(acUnits{k}.m_afAvgWaveForm)-min(acUnits{k}.m_afAvgWaveForm);
    afMaxStd(k) = max(acUnits{k}.m_afStdWaveForm);
end


function hHandle = fnFancyPlot(afX, afY, afS, afColor1,afColor2)
aiNonNaN = ~isnan(afY);
afX = afX(aiNonNaN);
afY = afY(aiNonNaN);
afS = afS(aiNonNaN);

hHandle=fill([afX, afX(end:-1:1)],[afY+afS, afY(end:-1:1)-afS(end:-1:1)], afColor1,'FaceAlpha',0.5);
plot(afX,afY, 'color', afColor2,'LineWidth',2);
return;