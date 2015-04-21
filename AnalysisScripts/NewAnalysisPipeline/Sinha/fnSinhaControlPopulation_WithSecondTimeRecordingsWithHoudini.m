
aiIntervalChannel = cat(1,a2cTable{aiIntervalToDataEntryInstance,1});

aiIntervalsWithBothCh1 =  find(a2bIntervalListsToDataEntries(:,1) & aiIntervalChannel == 1);

% aiFOBDataEntries = a2bIntervalListsToDataEntries(aiIntervalsWithBothCh1,1);
aiSinhaDataEntries = a2bIntervalListsToDataEntries(aiIntervalsWithBothCh1,1);

iNumUnits = length(acUnits);
afSinhaFSI = nans(1,iNumUnits);
for iIter=1:iNumUnits
%     [Dummy, Dummy, aFOB_FSI(iIter)]=fnFindAttribute(acDisplayedEntries{aiFOBDataEntries(iIter)}.m_a2cAttributes,'FSI');
    [bExist, Dummy, Value]=fnFindAttribute(acDisplayedEntries{aiSinhaDataEntries(iIter)}.m_a2cAttributes,'FSI');
    if bExist
        afSinhaFSI(iIter) = Value;
    end;
end
% aiIntervalsBothAgree= aiIntervalsWithBothCh1(aFOB_FSI > 0.3 & afSinhaFSI > 0.3);
aiRelevantDataEntries = 1:length(afSinhaFSI);%aiSinhaDataEntries(afSinhaFSI > 0.3);
iNumRelevant = length(aiRelevantDataEntries);
acData = cell(1,iNumRelevant);
for iIter=1:iNumRelevant
    fprintf('Loading %d out of %d\n',iIter,iNumRelevant);
    acData{iIter} = load( acDisplayedEntries{aiRelevantDataEntries(iIter)}.m_strFile);
end

abHasAll= zeros(1,iNumRelevant);
afMaxAvgFiringRateForFaces = zeros(1,iNumRelevant);
for iIter=1:iNumRelevant
    afMaxAvgFiringRateForFaces(iIter) = max(acUnits{iIter}.m_a2fAvgFirintRate_Category(1,200:500));
    abHasAll(iIter) = ~isempty( acUnits{iIter}.m_strctContrastPair11Parts) && isfield(acUnits{iIter},'m_strctFaceSelectivity') && ~isempty(acUnits{iIter}.m_strctFaceSelectivity);
end
acUnits = acUnits(abHasAll > 0 & afMaxAvgFiringRateForFaces > 10 & afSinhaFSI > 0.3);

if 0
aiSelectedSubPop = [1,5,8,22,25,29];
acData = acData(aiSelectedSubPop);
end

iNumRelevant = length(acData);

a2fTmp = zeros(iNumRelevant,55);
afFaceSelective = zeros(1,iNumRelevant);
aiChannel = zeros(1,iNumRelevant);
a2fPValue = zeros(iNumRelevant,55);
a2fResponses = zeros(iNumRelevant, 1682);
fPThres = 1e-5;

a3fFullRes = zeros(1682,701,  iNumRelevant);
a3fFullResNorm = zeros(1682,701,  iNumRelevant);

for iIter=1:iNumRelevant
    a2fResponses(iIter,:)=acUnits{iIter}.m_afAvgFirintRate_Stimulus;
    
    a2fPValue(iIter,:) = acUnits{iIter}.m_strctContrastPair11Parts.m_afPvalue;
    abLarger = acUnits{iIter}.m_strctContrastPair11Parts.m_a2fAvgFiring(:,1) > acUnits{iIter}.m_strctContrastPair11Parts.m_a2fAvgFiring(:,2) ;
    afTuning = zeros(1,55);
    afTuning(abLarger' & a2fPValue(iIter,:)<fPThres) = 1;
    afTuning(~abLarger' & a2fPValue(iIter,:)<fPThres) = 0.5;
    a2fTmp(iIter,:) = afTuning;%acUnits{iIter}.m_strctContrastPair11Parts.m_afTuning;
    afFaceSelective(iIter)=acUnits{iIter}.m_strctFaceSelectivity.m_fFaceSelectivityIndex;
    aiChannel(iIter) = acUnits{iIter}.m_strctChannelInfo.m_iChannelID;
    
    a3fFullRes(:,:,iIter) = acUnits{iIter}.m_a2fAvgFirintRate_Stimulus;
    a3fFullResNorm(:,:,iIter) = a3fFullRes(:,:,iIter)/max(acUnits{iIter}.m_a2fAvgFirintRate_Stimulus(:));
end

for iIter=1:length(acData)
    afRatioCorrect(iIter) = acUnits{iIter}.m_strctHairComparison.m_afAvgFiringCondition(1) / mean(acUnits{iIter}.m_afAvgFirintRate_Stimulus(1:16)) * 1e2;
    afRatioIncorrect(iIter) = acUnits{iIter}.m_strctHairComparison.m_afAvgFiringCondition(2) / mean(acUnits{iIter}.m_afAvgFirintRate_Stimulus(1:16)) * 1e2;
end
figure(4);
clf;
plot(afRatioCorrect, afRatioIncorrect,'.');
hold on;plot([0 120],[0 120],'k')
xlabel('Response to correct features (relative to avg response to a real face)');
ylabel('Response to incorrect features (relative to avg response to a real face)');
hist(afRatioIncorrect)
%%
close all
for k=1:3:iNumRelevant
    figure(100+k);
    clf;
    
    for j=1:3
        subplot(3,1,j);
aiFullFaces = 1:16;
aiFullFacesInv = 1641:1656;
aiCropped = 1609:1624;
aiCroppedInv = 1625:1640;

siSubSubSet = k+j-1

hold on;
plot(-200:500, nanmean(nanmean(a3fFullResNorm(1:16,:,siSubSubSet),3),1),'r','LineWidth',2);
plot(-200:500, nanmean(nanmean(a3fFullResNorm(aiFullFacesInv,:,siSubSubSet),3),1),'r--');

plot(-200:500,nanmean(nanmean(a3fFullResNorm(17:96,:,siSubSubSet),3),1),'k','LineWidth',2);

plot(-200:500,nanmean(nanmean(a3fFullResNorm(end-25:end-13,:,siSubSubSet),3),1),'b','LineWidth',2);
plot(-200:500,nanmean(nanmean(a3fFullResNorm(end-12:end,:,siSubSubSet),3),1),'b--','LineWidth',1);

plot(-200:500, nanmean(nanmean(a3fFullResNorm(aiCroppedInv,:,siSubSubSet),3),1),'g--');
plot(-200:500, nanmean(nanmean(a3fFullResNorm(aiCropped,:,siSubSubSet),3),1),'g','LineWidth',2);

legend({'Faces','Faces Inv','Objects','Correct Features','Incorrect Features','Cropped','Cropped Inverted'});
title(num2str(k+j-1));
    end;
    set(gcf,'position',[ 680   116   779   982]);
end;


figure(100);
clf;
%plot(a3fFullResNorm([1219,1283],:,18)')
plot(a3fFullResNorm([835,899],:,18)')

% 
% 
% 1219 : Cartoon - all features present execpt hair
% 1283 : Cartoon - all features present WITH hair

%%
figure(2);
clf;
imagesc((a2fResponses),[0 60]);
colorbar;
a2fResponsesNorm = a2fResponses./repmat(max(a2fResponses,[],2),1,size(a2fResponses,2));
figure(3);imagesc(a2fResponsesNorm)

X=[...
mean(nanmean(a2fResponsesNorm(:,1:16)))
mean(nanmean(a2fResponsesNorm(:,17:96)))
mean(nanmean(a2fResponsesNorm(:,97:549)))
mean(nanmean(a2fResponsesNorm(:,1327:1608)))
mean(nanmean(a2fResponsesNorm(:,550:575)))
mean(nanmean(a2fResponsesNorm(:,602:612)))];

figure(21);
bar(X);
set(gca,'xticklabel',{'Faces','Objects','Sinha11','Sinha8','Sinha11+Black Hair','Sinha aspect ratio'});



figure(22);
clf; hold on;
plot(-200:500, nanmean(nanmean(a3fFullResNorm(1:16,:,:),3),1),'r');
plot(-200:500,nanmean(nanmean(a3fFullResNorm(17:96,:,:),3),1),'g');
plot(-200:500,nanmean(nanmean(a3fFullResNorm(97:549,:,:),3),1),'b');
plot(-200:500,nanmean(nanmean(a3fFullResNorm(1327:1608,:,:),3),1),'c');
plot(-200:500,nanmean(nanmean(a3fFullResNorm(550:575,:,:),3),1),'m');
plot(-200:500,nanmean(nanmean(a3fFullResNorm(602:612,:,:),3),1),'k');
plot(-200:500,nanmean(nanmean(a3fFullResNorm(end-25:end-13,:,:),3),1),'b--');
legend({'Faces','Objects','Sinha 11 (All perm, no hair)','Sinha 8 (with hair)','Sinha 11 + Black Hair','Sinha 11 (All aspect Ratio)','Sinha 11 (no hair) Correct'},'Location','NorthEastOutside')

figure(4);
imagesc(a2fTmp);
colormap hot

figure(41);clf;
subplot(2,1,1);
hold on;
bar(1:55,sum(a2fTmp == 1,1),'b');
bar(1:55,-sum(a2fTmp == 0.5,1),'r');
axis([0 55 -12 12]);
box on
set(gca,'xtick',1:1:55);
ylabel('Number of cells');
acPartNames11 = {'Forehead','Left Eye','Nose','Right Eye','Left Cheek','Upper Lip','Right Cheek','Lower Left Cheek','Mouth','Lower Right Cheek','Chin'};

a2bParts = zeros(11,55);
a2iPairs11 = nchoosek(1:11,2);
for k=1:55
    a2bParts(a2iPairs11(k,1),k) = 1;
    a2bParts(a2iPairs11(k,2),k) = 1;
end
subplot(2,1,2);
imagesc(a2bParts);
colormap gray
set(gca,'ytick',1:11);
set(gca,'yticklabel',acPartNames11);
set(gca,'xtick',1:1:55);
clear a2fNorm

for j=1:length(acUnits)
    a2fNorm(j,:) = acUnits{j}.m_strctHairComparison.m_afAvgFiringCondition / max(acUnits{j}.m_strctHairComparison.m_afAvgFiringCondition);
end
figure(6);
clf;
bar(1:6,nanmean(a2fNorm));
set(gca,'xticklabel',acUnits{1}.m_strctHairComparison.m_acConditionNames);
xticklabel_rotate
figure;
anova1(a2fNorm)



for k=1:length(acData)
    a3fCartoonTuning(:,:,k) = acData{k}.strctUnit.m_strctCartoonFeatureTuning.m_a2fTuning;
    a3fCartoonTuningNorm(:,:,k) = acData{k}.strctUnit.m_strctCartoonFeatureTuning.m_a2fTuning / max(acData{k}.strctUnit.m_strctCartoonFeatureTuning.m_a2fTuning(:));
a3fSinhaTuning(:,:,k) = acData{k}.strctUnit.m_strctSinhaFeatureTuning.m_a2fTuning;
a2fSigTuning(k,:) = acData{k}.strctUnit.m_strctSinhaFeatureTuning.m_afSigTuning;
a3fSinhaTuningNorm(:,:,k) = acData{k}.strctUnit.m_strctSinhaFeatureTuning.m_a2fTuning / max(acData{k}.strctUnit.m_strctSinhaFeatureTuning.m_a2fTuning(:));
end

a2fTuningPop = nanmean(a3fSinhaTuningNorm,3);
figure(8);
clf;
plot(a2fTuningPop','LineWidth',2);
legend( acData{1}.strctUnit.m_strctSinhaFeatureTuning.m_acCondNames);

a2fTuningPopCartoon = nanmean(a3fCartoonTuningNorm,3);
figure(9);
plot(a2fTuningPopCartoon','LineWidth',2);
legend( acData{1}.strctUnit.m_strctCartoonFeatureTuning.m_acCondNames);


% Sinha parts (correct contrast)
clear a2fSinhaPartSig a2fSinhaPartSigInv a2bSinhaFeatureTuning a2bCartoonFeatureTuning a2fCartoonPartSig
for k=1:length(acData)
    a2bSinhaFeatureTuning(k,:) = acData{k}.strctUnit.m_strctSinhaFeatureTuning.m_afSigTuning < 0.05;
    a2bCartoonFeatureTuning(k,:) = acData{k}.strctUnit.m_strctCartoonFeatureTuning.m_afSigTuning< 0.05;
    a2fCartoonPartSig(k,:) = (diag(acData{k}.strctUnit.m_strctCartoonANOVA.m_a2fPValue) < 0.005)';
    a2fSinhaPartSig(k,:) = (diag(acData{k}.strctUnit.m_strctSinhaPartsCorrectFeaturesANOVA.m_a2fPValue) < 0.005)';
    a2fSinhaPartSigInv(k,:) = (diag(acData{k}.strctUnit.m_strctSinhaPartsIncorrectFeaturesANOVA.m_a2fPValue) < 0.005)';
end

figure(10);
clf;
subplot(1,2,1);
imagesc(a2bSinhaFeatureTuning);
colormap gray
set(gca,'xtick',1:4,'xticklabel',acData{1}.strctUnit.m_strctSinhaFeatureTuning.m_acCondNames);
xticklabel_rotate
title('Tuning in Sinha-like images');
subplot(1,2,2);
imagesc(a2bCartoonFeatureTuning);
colormap gray
set(gca,'xtick',1:4,'xticklabel',acData{1}.strctUnit.m_strctSinhaFeatureTuning.m_acCondNames);
xticklabel_rotate
title('Tuning in Cartoon-like images');

figure(11);
clf;
subplot(1,2,1);
imagesc(a2fSinhaPartSig(:,2:end));
colormap gray
set(gca,'xtick',1:7,'xticklabel',acData{1}.strctUnit.m_strctSinhaPartsCorrectFeaturesANOVA.m_acFactorNames(2:end));
xticklabel_rotate
title('Sinha stimuli');
subplot(1,2,2);
imagesc(a2fCartoonPartSig);
colormap gray
set(gca,'xtick',1:7,'xticklabel',acData{1}.strctUnit.m_strctCartoonANOVA.m_acFactorNames);
xticklabel_rotate
title('Cartoon stimuli');
  
figure(12);
clf;
subplot(1,2,1);
imagesc(a2fSinhaPartSig(:,2:end) & a2fCartoonPartSig);
colormap gray
set(gca,'xtick',1:7,'xticklabel',acData{1}.strctUnit.m_strctSinhaPartsCorrectFeaturesANOVA.m_acFactorNames(2:end));
xticklabel_rotate
title('Shared in both stimuli');
subplot(1,2,2);
A = a2fCartoonPartSig;
B = a2fSinhaPartSig(:,2:end);
imagesc( (A&~B) | (B&~A));
colormap gray
set(gca,'xtick',1:7,'xticklabel',acData{1}.strctUnit.m_strctCartoonANOVA.m_acFactorNames);
xticklabel_rotate
title('In one but not the other');


figure(13);
clf;
subplot(1,2,1);
imagesc(a2fSinhaPartSig(:,2:end) & ~a2fCartoonPartSig);
colormap gray
set(gca,'xtick',1:7,'xticklabel',acData{1}.strctUnit.m_strctSinhaPartsCorrectFeaturesANOVA.m_acFactorNames(2:end));
xticklabel_rotate
title('Tuned in Sinha but not cartoon');

subplot(1,2,2);
imagesc(~a2fSinhaPartSig(:,2:end) & a2fCartoonPartSig);
colormap gray
set(gca,'xtick',1:7,'xticklabel',acData{1}.strctUnit.m_strctSinhaPartsCorrectFeaturesANOVA.m_acFactorNames(2:end));
xticklabel_rotate
title('Tuned in Cartoon but not Sinha');



%%
figure(14);clf;
subplot(1,2,1);
imagesc(a2fSinhaPartSig(:,2:end))
colormap gray
ylabel('Units');
title('Correct Contrast');
set(gca,'xtick',1:7,'xticklabel',acData{1}.strctUnit.m_strctSinhaPartsCorrectFeaturesANOVA.m_acFactorNames(2:end));
xticklabel_rotate

subplot(1,2,2);
imagesc(a2fSinhaPartSigInv(:,2:end))
colormap gray
ylabel('Units');
title('Incorrect Contrast');
set(gca,'xtick',1:7,'xticklabel',acData{1}.strctUnit.m_strctSinhaPartsCorrectFeaturesANOVA.m_acFactorNames(2:end));
xticklabel_rotate

figure(15);clf;
subplot(1,2,1);
imagesc(a2fSinhaPartSig & a2fSinhaPartSigInv)
colormap gray
ylabel('Units');
title('Tuned in both contrast conditions');
set(gca,'xtick',1:8,'xticklabel',acData{1}.strctUnit.m_strctSinhaPartsCorrectFeaturesANOVA.m_acFactorNames);
xticklabel_rotate

subplot(1,2,2);
imagesc( (~a2fSinhaPartSig & a2fSinhaPartSigInv) | (a2fSinhaPartSig & ~a2fSinhaPartSigInv))
colormap gray
ylabel('Units');
title('Tuned in one but not the other');
set(gca,'xtick',1:8,'xticklabel',acData{1}.strctUnit.m_strctSinhaPartsCorrectFeaturesANOVA.m_acFactorNames);
xticklabel_rotate


figure(16);clf;
subplot(1,2,1);
imagesc(a2fSinhaPartSig & ~a2fSinhaPartSigInv)
colormap gray
ylabel('Units');
title('Tuned in  Correct contrast only');
set(gca,'xtick',1:8,'xticklabel',acData{1}.strctUnit.m_strctSinhaPartsCorrectFeaturesANOVA.m_acFactorNames);
xticklabel_rotate

subplot(1,2,2);
imagesc( ~a2fSinhaPartSig & a2fSinhaPartSigInv)
colormap gray
ylabel('Units');
title('Tuned in inverted contrast only');
set(gca,'xtick',1:8,'xticklabel',acData{1}.strctUnit.m_strctSinhaPartsCorrectFeaturesANOVA.m_acFactorNames);
xticklabel_rotate

for k=1:length(acData)
    a2fPart8PValue(k,:) = acData{k}.strctUnit.m_strctContrastPair8Parts.m_afPvalue;
    a2fPart8AlargerB(k,:) = acData{k}.strctUnit.m_strctContrastPair8Parts.m_a2fAvgFiring(:,1) > acData{k}.strctUnit.m_strctContrastPair8Parts.m_a2fAvgFiring(:,2);
end
fThres = 0.05;
a2iTuning = zeros(size(a2fPart8PValue));
a2iTuning(a2fPart8PValue < fThres & a2fPart8AlargerB) = 0.5;
a2iTuning(a2fPart8PValue < fThres & ~a2fPart8AlargerB) = 1;

figure(19);
clf;
imagesc(a2iTuning);
colormap hot
aiPos = sum(a2fPart8PValue < fThres & ~a2fPart8AlargerB,1);
aiNeg = sum(a2fPart8PValue < fThres & a2fPart8AlargerB,1);

figure(20);clf;
subplot(2,1,1);
bar(1:28,aiPos,'b');
hold on;
bar(1:28,-aiNeg,'r');
axis([0 29 -15 15])
xlabel('Part pairs (8 parts sinha)');
set(gca,'xtick',1:28);
subplot(2,1,2);

iNumParts =8 ;
a2iPartRatio = nchoosek(1:iNumParts,2);
acPartNames8 = {   'Mouth'    'Nose'    'Eyebrow'    'Eyes'    'Pupils'    'BoundingEllipse'    'Hair'    'Forehead'};
a2iTable = zeros(8,  28);
for k=1:28
    a2iTable( a2iPartRatio(k,1) ,k) =  1;
    a2iTable( a2iPartRatio(k,2) ,k) =  1;
end
imagesc(a2iTable);
set(gca,'yticklabel',acPartNames8);
set(gca,'ytick',1:8);
colormap gray
set(gca,'xtick',1:28);

clear a3fPSTHcropnorm  a3fPSTHcrop
for k=1:length(acData)
    a2fTemp = [acData{k}.strctUnit.m_strctCroppedAnalysis.m_a2fPSTH;nanmean(acData{k}.strctUnit.m_a2fAvgFirintRate_Stimulus(17:96,:))];;
    a3fPSTHcrop(:,:,k) = a2fTemp;
    a3fPSTHcropnorm(:,:,k) = a2fTemp / max(a2fTemp(:));
end
a2fPSTHnorm = nanmean(a3fPSTHcropnorm,3)
   
figure(21);
clf;
plot(-200:500,a2fPSTHnorm','linewidth',2);
legend([acData{1}.strctUnit.m_strctCroppedAnalysis.m_acConditionNames,'Objects']);


figure(22);
clf;
for k=1:length(acData)
    tightsubplot(5,6,k,'Spacing',0.05);
    a2fTemp = [acData{k}.strctUnit.m_strctCroppedAnalysis.m_a2fPSTH;nanmean(acData{k}.strctUnit.m_a2fAvgFirintRate_Stimulus(17:96,:))];;
    plot(-200:500,a2fTemp','linewidth',2);
    title(num2str(k));
end
legend([acData{k}.strctUnit.m_strctCroppedAnalysis.m_acConditionNames,'Objects']);


% Show sub population
aiSelectedSubPop = [1,5,8,22,25,29];
figure(23);
clf;
plot(-200:500,nanmean(a3fPSTHcropnorm(:,:,aiSelectedSubPop),3)')


a2fTemp = [acData{k}.strctUnit.m_strctCroppedAnalysis.m_a2fPSTH;nanmean(acData{k}.strctUnit.m_a2fAvgFirintRate_Stimulus(17:96,:))];;

%% The plot doris wanted

aiIncorrectPermutations = 1670:1682;
aiCorrectPermutations = 1657:1669;
aiBlackHairCorrectFeatures = 550:562;
aiBlackHairIncorrectFeatures = 563:575;
aiWhiteHairCorrectFeatures = 576:588;
aiWhiteHairIncorrectFeatures = 589:601;
aiFaces = 1:16;
aiNonFaces = 17:96;

acLegend = {'Faces','Objects','Correct contrast no hair','Incorrect conrast no hair','Correct contrast with hair','Incorrect contrast with hair'};
T = [ nanmean(nanmean(a3fFullResNorm(aiFaces,:,:),3),1);
         nanmean(nanmean(a3fFullResNorm(aiNonFaces,:,:),3),1);
         nanmean(nanmean(a3fFullResNorm(aiCorrectPermutations,:,:),3),1);
         nanmean(nanmean(a3fFullResNorm(aiIncorrectPermutations,:,:),3),1);
         nanmean(nanmean(a3fFullResNorm(aiBlackHairCorrectFeatures,:,:),3),1);
         nanmean(nanmean(a3fFullResNorm(aiBlackHairIncorrectFeatures,:,:),3),1)];
     
figure(202);
clf; hold on;
plot(-200:500,T(2:end,:)','LineWidth',2);
legend(acLegend(2:end),'Location','northeastoutside');
xlabel('Time (ms)');
ylabel('Avg. normalized response');
box on
