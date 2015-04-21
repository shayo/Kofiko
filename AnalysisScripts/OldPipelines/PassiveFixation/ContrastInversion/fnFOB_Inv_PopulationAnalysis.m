function fnFOB_Inv_PopulationAnalysis(acUnits,strctConfig)


[a2iCodes,strctCodeIndex, acSubjects,acLists, a2iListToIndex, strctQuality] = fnGetUniqueExperimentCode(acUnits);


iListIndexInsEqHist = find(ismember(acLists,'StandardFOB_v4_Inv_Cropped_HistEq'));
iListIndexFOB = find(ismember(acLists,'StandardFOB_v5_Inv_Edges'));
iListIndexExt = find(ismember(acLists,'StandardFOB_v4_Inv_Cropped_External'));
iListIndexIns= find(ismember(acLists,'StandardFOB_v4_Inv_Cropped'));
aiRelevantUnits = find(a2iListToIndex(iListIndexFOB,:) > 0 & ...
                       a2iListToIndex(iListIndexExt,:) > 0 & ...
                       a2iListToIndex(iListIndexIns,:) > 0 & ...
                       a2iListToIndex(iListIndexInsEqHist,:) > 0 );


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
    
    
    abFOBList(k) = strcmp(acUnits{k}.m_strImageListDescrip,'StandardFOB_v4_Inv');
    if abFOBList(k)
        fFaces = fnMyMean(acUnits{k}.m_afAvgFirintRate_Stimulus(1:16));
        fNonFaces = fnMyMean(acUnits{k}.m_afAvgFirintRate_Stimulus(17:96));
        aiFaceSelectivity(k) = (fFaces-fNonFaces)/(fFaces+fNonFaces);
    end
    iIndex = find(acUnits{k}.m_afISICenter <= fISIThresholdMS,1,'last');
    afISI(k) = sum(acUnits{k}.m_afISIDistribution(1:iIndex)) / sum(acUnits{k}.m_afISIDistribution) * 100;
    
    abSinhaList(k) = strcmp(acUnits{k}.m_strImageListDescrip,'Sinha_v2_FOB');
    abCBCLList(k) = strcmp(acUnits{k}.m_strImageListDescrip,'CMU_CBCL_Experiment_Inv');
    aiNumSpikes(k) = length(acUnits{k}.m_afSpikeTimes);
    afMUA(k) = sum(acUnits{k}.m_afISIDistribution(1:3))/  sum(acUnits{k}.m_afISIDistribution) * 100;
    afAmpRange(k) = max(acUnits{k}.m_afAvgWaveForm)-min(acUnits{k}.m_afAvgWaveForm);
    afMaxStd(k) = max(acUnits{k}.m_afStdWaveForm);
end
fThreshold = 0;
abSubsetCBCL = abCBCLList & aiNumSpikes > 500 & afMaxStd./afAmpRange < fQuality;
abSubsetFOB = abFOBList & aiNumSpikes > 500 & afMaxStd./afAmpRange < fQuality & aiFaceSelectivity > fThreshold;
abSubsetSinha = abSinhaList & aiNumSpikes > 500 & afMaxStd./afAmpRange < fQuality;

% aiCBCL = find(abSubsetCBCL);
% abSubsetCBCLandFaceSelective = zeros(1,iNumUnits) > 0;
% for k=1:length(aiCBCL)
%     % Find corresponding FOB experiment
%     iIndex=find(afTime == afTime(aiCBCL(k)) & aiUnit == aiUnit(aiCBCL(k)) & aiRec == aiRec(aiCBCL(k)) & abSubsetFOB);
%     if ~isempty(iIndex)
%         abSubsetCBCLandFaceSelective(aiCBCL(k)) = 1;
%     end;
% end
% abSubsetCBCL =abSubsetCBCLandFaceSelective;

% These ones show nice activation and the increase response to inverted
% faces!
% abSubsetCBCL(:) = false;
% abSubsetCBCL( [26,   54,   73,   88,   97,   113,   116,   158,   236,   240,   242,   266,   287,   295,   298,   301,   304])=1;
% % % 
% % % Temp = acUnits(abSubsetCBCL);
% % % for k=1:length(Temp)
% % %     fprintf('%s, Exp %d, Ch %d, Unit %d\n',Temp{k}.m_strRecordedTimeDate, Temp{k}.m_iRecordedSession,Temp{k}.m_iChannel,Temp{k}.m_iUnitID);
% % % end;
% % % 
% % % 07-Oct-2010 09:59:23, Exp 4, Ch 1, Unit 1
% % % 08-Oct-2010 09:37:10, Exp 3, Ch 1, Unit 5
% % % 08-Oct-2010 09:37:10, Exp 6, Ch 1, Unit 1
% % % 09-Oct-2010 11:05:48, Exp 2, Ch 1, Unit 2
% % % 09-Oct-2010 11:05:48, Exp 2, Ch 1, Unit 5
% % % 10-Oct-2010 09:38:34, Exp 5, Ch 1, Unit 1
% % % 10-Oct-2010 09:38:34, Exp 5, Ch 1, Unit 2
% % % 12-Oct-2010 09:43:02, Exp 2, Ch 1, Unit 1
% % % 10-Oct-2010 14:41:34, Exp 3, Ch 1, Unit 2
% % % 10-Oct-2010 14:41:34, Exp 4, Ch 1, Unit 1
% % % 10-Oct-2010 14:41:34, Exp 4, Ch 1, Unit 2
% % % 11-Oct-2010 17:37:23, Exp 7, Ch 1, Unit 1
% % % 13-Oct-2010 13:41:29, Exp 4, Ch 1, Unit 1
% % % 13-Oct-2010 13:41:29, Exp 6, Ch 1, Unit 1
% % % 13-Oct-2010 13:41:29, Exp 6, Ch 1, Unit 2
% % % 13-Oct-2010 13:41:29, Exp 7, Ch 1, Unit 1
% % % 13-Oct-2010 13:41:29, Exp 7, Ch 1, Unit 2



a2fCol = [0    0.5000    1.0000;
          1    0 0;
           0.5000    1.0000    0.5000;
    1.0000    0.200         0.7;
    1.0000    0.5000         0;
    1.0000         0         0];


fprintf('FOB %d Sinha %d CBCL %d\n',sum(abSubsetFOB), sum(abSubsetSinha),sum(abSubsetCBCL));
[a2fAvgFOB, acCatNamesFOB,a2fStdFOB,a2fStdErr]= fnComputeNormalizedResponse(acUnits(abSubsetFOB));
afPeri = -200:500;
figure(1);
clf;
hold on;
clear ahHandles

    ahH(1)=fnFancyPlot(afPeri(100:600),a2fAvgFOB(1,100:600),a2fStdErr(1,100:600),a2fCol(1,:),0.5*a2fCol(1,:));
    ahH(2)=fnFancyPlot(afPeri(100:600),a2fAvgFOB(8,100:600),a2fStdErr(8,100:600),a2fCol(2,:),0.5*a2fCol(2,:));
    
    afNonFaces = a2fAvgFOB(2:6,:)
ahHandles(1) = plot(-100:400,a2fAvgFOB(1,100:600), 'color','b','LineWidth',3);


for k=1:5
    %ahHandles(k) = fnFancyPlot(-100:400,a2fAvgFOB(k,100:600), a2fStdErr(k,100:600),a2fCol(k,:),a2fCol(k,:)*0.5);
    
end
legend(ahHandles,acCatNamesFOB(1:5),'Location','NorthEastOutside');
grid on
box on
%,'Location','NorthEastOutside');

%ahHandles(6) = fnFancyPlot(-100:400,a2fAvgFOB(8,100:600), a2fStdErr(8,100:600),[1 0 0],[0.5 0 0]);
ahHandles(6) = plot(-100:400,a2fAvgFOB(8,100:600), 'color',[1 0 0],'linewidth',3);
legend(ahHandles,{acCatNamesFOB{1:5},'Inverted Faces'},'Location','NorthEastOutside');
grid on
box on

for k=1:4
    ahHandles(6+k) = plot(-100:400,a2fAvgFOB(8+k,100:600), 'color',a2fCol(1+k,:),'LineWidth',3,'LineStyle','--');
end
legend(ahHandles,{acCatNamesFOB{1:5},'Inverted Faces','Inverted Bodies','Inverted Fruits','Inverted Gadgets','Inverted Hands'},'Location','NorthEastOutside');
grid on
box on

ahHandles(11) = plot(-100:400,a2fAvgFOB(6,100:600), 'color',[0.2 0.2 0.2],'LineWidth',3);
ahHandles(12) = plot(-100:400,a2fAvgFOB(13,100:600), 'color',[0.2 0.2 0.2],'LineWidth',3,'LineStyle','--');

title(sprintf('%d units, %.1f threshold',sum(abSubsetFOB),fThreshold))


figure(1);
clf;
hold on;
plot(afPeri,a2fAvgFOB(1:6,:)','Linestyle','--');
plot(afPeri,a2fAvgFOB(8:end-1,:)');
%legend(acUnits{3}.m_acCatNames,'Location','NorthEastOutside')
xlabel('Time (ms)');
ylabel('Normalized Response');


[a2fAvgCBCL, acCatNamesCBCL,a2fStdCBCL]= fnComputeNormalizedResponse(acUnits(abSubsetCBCL));
a2fStdErrCBCL = a2fStdCBCL / (sqrt(sum(abSubsetCBCL)));
aiCBCLUnits = find(abSubsetCBCL);

a2fCol = [0    0.5000    1.0000;
          0.5000    1.0000    0.5000;
          1 0 0;
    0    1         1;
]          
figure(2);
clf;
hold on;
for k=[1,3]
    ahH(k)=fnFancyPlot(afPeri(100:600),a2fAvgCBCL(k,100:600),a2fStdErrCBCL(k,100:600),a2fCol(k,:),0.5*a2fCol(k,:));
end
axis([-100 400 0.2 0.8]);
grid on
box on

legend(ahH([1,3]),acUnits{aiCBCLUnits(1)}.m_acCatNames([1,3]),'Location','NorthEastOutside')
xlabel('Time (ms)');
ylabel('Normalized Response');
title(sprintf('%d Units ',sum(abSubsetCBCL)));


[a2fAvgSinha, acCatNamesSinha]= fnComputeNormalizedResponse(acUnits(abSubsetSinha));
aiFOBUnits = find(abSubsetFOB);
aiSinhaUnits = find(abSubsetSinha);


%%

%%
strctModel = load('D:\Code\Doris\Stimuli_Generating_Code\CBCL\CBCL_Model_Sinha_For_Inverted_Images.mat');
%% Plot LFP For CBCL
T = zeros(size(acUnits{aiCBCLUnits(1)}.m_a2fAvgLFPCategory));
for k=1:length(aiCBCLUnits)
    fMin = min(acUnits{aiCBCLUnits(k)}.m_a2fAvgLFPCategory(:));
    fMax = max(acUnits{aiCBCLUnits(k)}.m_a2fAvgLFPCategory(:));
    
    X = (acUnits{aiCBCLUnits(k)}.m_a2fAvgLFPCategory-fMin)/(fMax-fMin);
    T  = T + X;
end
T = T / length(aiCBCLUnits);
figure(20);
plot(-200:500,T')
legend('Faces','Non Faces','Inv Faces','Inv Non Faces','Location','NorthEastOutside');
%% LFP for FOB
T = zeros(size(acUnits{aiFOBUnits(1)}.m_a2fAvgLFPCategory));
for k=1:length(aiFOBUnits)
    fMin = min(acUnits{aiFOBUnits(k)}.m_a2fAvgLFPCategory(:));
    fMax = max(acUnits{aiFOBUnits(k)}.m_a2fAvgLFPCategory(:));
    
    X = (acUnits{aiFOBUnits(k)}.m_a2fAvgLFPCategory-fMin)/(fMax-fMin);
    T  = T + X;
end
T = T / length(aiFOBUnits);
figure(21);clf; hold on;
plot(0:500,T(1:7,201:end)')
plot(0:500,T(8:end,201:end)','LineStyle','--')
legend(acUnits{aiFOBUnits(1)}.m_acCatNames,'Location','NorthEastOutside');

%% Contrast Inversion Index
%-	Plot Contrast Inversion Index as a function of avg. firing rate
afCII = zeros(1,length(aiFOBUnits));
afFSI= zeros(1,length(aiFOBUnits));
afAvgFiringForFaces = zeros(1,length(aiFOBUnits));
for iUnitIter=1:length(aiFOBUnits)
   iStartAvg = find(acUnits{ aiFOBUnits(iUnitIter)}.m_aiPeriStimulusRangeMS>=40,1,'first');
   iEndAvg = find(acUnits{ aiFOBUnits(iUnitIter)}.m_aiPeriStimulusRangeMS>=280,1,'first');
   
   fAvgResponseForNormalContrast =  mean(mean(acUnits{ aiFOBUnits(iUnitIter)}.m_a2fAvgFirintRate_Stimulus(1:16,iStartAvg:iEndAvg),2));
   fAvgResponseForObjects = mean(mean(acUnits{ aiFOBUnits(iUnitIter)}.m_a2fAvgFirintRate_Stimulus(17:96,iStartAvg:iEndAvg),2));
   fAvgResponseForInvNormalContrast =  mean(mean(acUnits{ aiFOBUnits(iUnitIter)}.m_a2fAvgFirintRate_Stimulus(106:121,iStartAvg:iEndAvg),2));
   afCII(iUnitIter) = (fAvgResponseForNormalContrast-fAvgResponseForInvNormalContrast)/(fAvgResponseForNormalContrast+fAvgResponseForInvNormalContrast);
   afFSI(iUnitIter) = (fAvgResponseForNormalContrast-fAvgResponseForObjects)/(fAvgResponseForNormalContrast+fAvgResponseForObjects);
   afAvgFiringForFaces(iUnitIter) = fAvgResponseForNormalContrast;
end
figure(10);
subplot(2,2,1);
hist(afCII);
xlabel('Contrast Selectivity Index');
ylabel('# Units');
subplot(2,2,2);
plot(afFSI,afCII,'.');
xlabel('Face Selectivity Index');
ylabel('Contrast Selectivity Index');
T=robustfit(afFSI,afCII);
hold on;
grid on
plot(afFSI,T(2)*afFSI+T(1),'r');
subplot(2,2,3);
plot(afAvgFiringForFaces,afCII,'b.');
T=robustfit(afAvgFiringForFaces,afCII);
hold on;
grid on
plot(afAvgFiringForFaces,T(2)*afAvgFiringForFaces+T(1),'r');
xlabel('Average Firing rate (for faces)');
ylabel('Contrast Selectivity Index');


%%
iNumUnits = sum(abSubsetCBCL);
a2fFace = zeros(iNumUnits, 13);
a2fNonFace = zeros(iNumUnits, 13);
a2fInvFace = zeros(iNumUnits, 13);
a2fInvNonFace = zeros(iNumUnits, 13);

for iUnitIter=1:iNumUnits
    [a2fFace(iUnitIter,:), a2fNonFace(iUnitIter,:),a2fInvFace(iUnitIter,:),a2fInvNonFace(iUnitIter,:) ]= fnFiringRateNumberOfCorrectRatiosAux(acUnits{aiCBCLUnits(iUnitIter)}, strctModel);
end
%%

afMeanF = zeros(1,13);
afMeanNF = zeros(1,13);
afMeanIF = zeros(1,13);

afMeanINF = zeros(1,13);

for k=1:13
    afMeanF(k) = fnMyMean(a2fFace(:,k));
    afMeanNF(k) = fnMyMean(a2fNonFace(:,k));    
    [afMeanIF(k),Tmp,afStdErr(k)] = fnMyMean(a2fInvFace(:,k));    
    afMeanINF(k) = fnMyMean(a2fInvNonFace(:,k));    
end

figure(5);
plot(0:12, afMeanF,0:12,afMeanNF,0:12,afMeanIF,0:12,afMeanINF);
legend('Faces','Non Faces','Inv Faces','Inv Non Faces','Location','NorthEastOutside');
xlabel('# Correct Sinha Pairs');
ylabel('Normalized Resposne');

%%

figure(2);
clf;
hold on;
plot(afPeri,a2fAvgCBCL');
legend(acUnits{aiCBCLUnits(1)}.m_acCatNames,'Location','NorthEastOutside')
xlabel('Time (ms)');
ylabel('Normalized Response');

figure(3);
clf;
hold on;
plot(afPeri,a2fAvgSinha');
legend(acUnits{aiSinhaUnits(1)}.m_acCatNames,'Location','NorthEastOutside')
xlabel('Time (ms)');
ylabel('Normalized Response');


%% Differences within category ?
% Do some units like 
% 
% signtest(afResponses1,afResponses2)

function [a2fAvgFirintRate_CategoryPop, acCatNames, a2fStd,a2fStdErr]= fnComputeNormalizedResponse(acUnits)
iNumUnits = length(acUnits);
a3fAvgFiringRate = zeros(size(acUnits{1}.m_a2fAvgFirintRate_Category,1),size(acUnits{1}.m_a2fAvgFirintRate_Category,2),length(acUnits));
for iUnitIter=1:iNumUnits
    strctUnit = acUnits{iUnitIter};
    a2fAvgFirintRate_CategoryNormalized = strctUnit.m_a2fAvgFirintRate_Category / max(strctUnit.m_a2fAvgFirintRate_Category(:));
    a3fAvgFiringRate(:,:,iUnitIter) = a2fAvgFirintRate_CategoryNormalized;
end
a2fAvgFirintRate_CategoryPop = mean(a3fAvgFiringRate,3);
a2fStd = std(a3fAvgFiringRate,[],3);
a2fStdErr = a2fStd ./ sqrt(iNumUnits);
acCatNames = acUnits{1}.m_acCatNames;
return;





function [afResFace, afResNonFace,afResInvFace, afResInvNonFace] = fnFiringRateNumberOfCorrectRatiosAux(strctUnit, strctModel)
abFace = zeros(822,1) > 0;
abFace(strctModel.aiFace) = true;
abNonFace = zeros(822,1) > 0;
abNonFace(strctModel.aiNonFace) = true;

abInvFace = zeros(822,1) > 0;
abInvFace(strctModel.aiInvFace) = true;
abInvNonFace = zeros(822,1) > 0;
abInvNonFace(strctModel.aiInvNonFace ) = true;

afResFace    = zeros(1,13);
afResNonFace = zeros(1,13);
afResInvFace    = zeros(1,13);
afResInvNonFace = zeros(1,13);
for k=1:13
    aiInd = find(strctModel.aiNumCorrectSinha == k-1 & abFace);
    afResFace(k) = fnMyMean(strctUnit.m_afAvgFirintRate_Stimulus(aiInd));
    aiInd = find(strctModel.aiNumCorrectSinha == k-1 & abNonFace);
    afResNonFace(k) = fnMyMean(strctUnit.m_afAvgFirintRate_Stimulus(aiInd));
    
    aiInd = find(strctModel.aiNumCorrectSinha == k-1 & abInvFace);
    afResInvFace(k) = fnMyMean(strctUnit.m_afAvgFirintRate_Stimulus(aiInd));
    aiInd = find(strctModel.aiNumCorrectSinha == k-1 & abInvNonFace);
    afResInvNonFace(k) = fnMyMean(strctUnit.m_afAvgFirintRate_Stimulus(aiInd));
    
end
%fNormalizing = max(strctUnit.m_afAvgStimulusResponseMinusBaseline(:));
fNormalizing = max([afResFace, afResNonFace,afResInvFace,afResInvNonFace]);
afResFace = afResFace./ fNormalizing;
afResNonFace = afResNonFace./ fNormalizing;
afResInvFace = afResInvFace./fNormalizing;
afResInvNonFace = afResInvNonFace ./fNormalizing;
return;

function A = fnMyMax(B)
if isempty(B)
    A = NaN;
else
    A = max(B);
end;


function hHandle = fnFancyPlot(afX, afY, afS, afColor1,afColor2)
aiNonNaN = ~isnan(afY);
afX = afX(aiNonNaN);
afY = afY(aiNonNaN);
afS = afS(aiNonNaN);

hHandle=fill([afX, afX(end:-1:1)],[afY+afS, afY(end:-1:1)-afS(end:-1:1)], afColor1,'FaceAlpha',0.5);
plot(afX,afY, 'color', afColor2,'LineWidth',2);
return;