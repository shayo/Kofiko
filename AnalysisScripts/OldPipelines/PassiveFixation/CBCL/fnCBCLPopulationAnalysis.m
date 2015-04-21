function fnCBCLPopulationAnalysis(acUnits,strctConfig)

if 0
for iUnitIter=1:length(acUnits)
    fprintf('%d out of %d\n',iUnitIter,length(acUnits));
    strctUnit = acUnits{iUnitIter};
    if ~isfield(strctUnit.m_strctStatParams,'m_iAfterMS')
        strctUnit.m_strctStatParams.m_iAfterMS = strctUnit.m_strctStatParams.m_fAfterMS; 
        strctUnit.m_strctStatParams.m_iBeforeMS = strctUnit.m_strctStatParams.m_fBeforeMS;
        strctUnit.m_strctStatParams.m_iStartAvgMS = strctUnit.m_strctStatParams.m_fStartAvgMS;
        strctUnit.m_strctStatParams.m_iEndAvgMS = strctUnit.m_strctStatParams.m_fEndAvgMS;
        strctUnit.m_strctStatParams.m_iStartBaselineAvgMS = strctUnit.m_strctStatParams.m_fStartBaselineAvgMS;
        strctUnit.m_strctStatParams.m_iEndBaselineAvgMS = strctUnit.m_strctStatParams.m_fEndBaselineAvgMS;        
        strctUnit.m_a2bRaster_Valid = strctUnit.m_a2bPSTH_Valid;
            strctUnit.m_strctStatParams.m_iTimeSmoothingMS = strctUnit.m_strctStatParams.m_fTimeSmoothingMS;
    end
aiPeriStimulusRangeMS = strctUnit.m_strctStatParams.m_iBeforeMS:strctUnit.m_strctStatParams.m_iAfterMS;
iStartAvg = find(aiPeriStimulusRangeMS>=strctUnit.m_strctStatParams.m_iStartAvgMS,1,'first');
iEndAvg = find(aiPeriStimulusRangeMS>=strctUnit.m_strctStatParams.m_iEndAvgMS,1,'first');
iStartBaselineAvg = find(aiPeriStimulusRangeMS>=strctUnit.m_strctStatParams.m_iStartBaselineAvgMS,1,'first');
iEndBaselineAvg = find(aiPeriStimulusRangeMS>=strctUnit.m_strctStatParams.m_iEndBaselineAvgMS,1,'first');
    
  afSmoothingKernelMS = fspecial('gaussian',[1 7*strctUnit.m_strctStatParams.m_iTimeSmoothingMS],strctUnit.m_strctStatParams.m_iTimeSmoothingMS);
        a2fSmoothRaster = conv2(double(strctUnit.m_a2bRaster_Valid),afSmoothingKernelMS ,'same');
        afResponse = mean(a2fSmoothRaster(:,iStartAvg:iEndAvg),2);
        strctUnit.m_afBaselineRes = mean(a2fSmoothRaster(:,iStartBaselineAvg:iEndBaselineAvg),2);
        strctUnit.m_afStimulusResponseMinusBaseline = afResponse-strctUnit.m_afBaselineRes;
        % Now average according to stimulus !
        iNumStimuli = size(strctUnit.m_a2bStimulusCategory,1);
        strctUnit.m_afAvgStimulusResponseMinusBaseline = NaN*ones(1,iNumStimuli);
        for iStimulusIter=1:iNumStimuli
            aiIndex = find(strctUnit.m_aiStimulusIndexValid == iStimulusIter);
            if ~isempty(aiIndex)
                strctUnit.m_afAvgStimulusResponseMinusBaseline(iStimulusIter) = mean(strctUnit.m_afStimulusResponseMinusBaseline(aiIndex));
            end;
        end    
    
  strctUnit.m_afAvgFiringRateCategory = ones(1,strctUnit.m_iNumCategories)*NaN;
        for iCatIter=1:strctUnit.m_iNumCategories
            abSamplesCat = ismember(strctUnit.m_aiStimulusIndexValid, find(strctUnit.m_a2bStimulusCategory(:, iCatIter)));
            if sum(abSamplesCat) > 0
                strctUnit.m_afAvgFiringRateCategory(iCatIter) = fnMyMean(strctUnit.m_afStimulusResponseMinusBaseline(abSamplesCat));
            end
        end
       acUnits{iUnitIter} = strctUnit;
     
end
end 
fnOLD_CBCL_PopulationAnalysis(acUnits,strctConfig); % Run this onpreselected CBCL experiments only...
%fnNew_CBCL_PopulationAnalysis(acUnits,strctConfig)

function fnNew_CBCL_PopulationAnalysis(acEntries,strctConfig)
[a2iCodes,strctCodeIndex,acSubjects,acLists,a2iListToIndex] = fnGetUniqueExperimentCode(acEntries);

for k=1:length(acLists), fprintf('%s\n',acLists{k});end;
iListIndexCBCL = find(ismember(acLists,'CMU_CBCL_Experiment'));
iListIndexFOBv2 = find(ismember(acLists,'StandardFOB_v2'));

aiRelevantUnits = find(a2iListToIndex(iListIndexFOBv2,:) > 0 & a2iListToIndex(iListIndexCBCL,:) > 0);
aiEntriesFOB = a2iListToIndex(iListIndexFOBv2,aiRelevantUnits);

[afFSI, afQuality,afDprime] = fnGetFSI_And_Quality(acEntries(aiEntriesFOB));

aiUnitInd = find(afDprime > 0.5);

aiEntriesCBCL = a2iListToIndex(iListIndexCBCL,aiRelevantUnits);

acUnitsCBCL = acEntries( aiEntriesCBCL(aiUnitInd));
iNumUnits = length(aiUnitInd);
fnOLD_CBCL_PopulationAnalysis(acUnitsCBCL,strctConfig);


function fnOLD_CBCL_PopulationAnalysis(acUnits,strctConfig)
% Take only CBCL Experiments....

fQuality = 1.2; % 0.5
fMUAThres = 3.5;

aiNumSpikes = zeros(1,length(acUnits));
afMUA = zeros(1,length(acUnits));
afMaxStd = zeros(1,length(acUnits));
afAmpRange = zeros(1,length(acUnits));
abNoData = zeros(1,length(acUnits)) > 0;
abCBCL =  zeros(1,length(acUnits)) > 0;
for k=1:length(acUnits)
    
    if ~isfield(acUnits{k},'m_afISIDistribution') || ~isfield(acUnits{k},'m_afSpikeTimes') || ~isfield(acUnits{k},'m_afAvgWaveForm')   
        abNoData(k) = true;
        continue;
    end
    abCBCL(k) = strcmp(acUnits{k}.m_strImageListDescrip,'CMU_CBCL_Experiment_Inv') ||strcmp(acUnits{k}.m_strImageListDescrip,'CMU_CBCL_Experiment');
    aiNumSpikes(k) = length(acUnits{k}.m_afSpikeTimes);
    afMUA(k) = sum(acUnits{k}.m_afISIDistribution(1:3))/  sum(acUnits{k}.m_afISIDistribution) * 100;
    afAmpRange(k) = max(acUnits{k}.m_afAvgWaveForm)-min(acUnits{k}.m_afAvgWaveForm);
    afMaxStd(k) = max(acUnits{k}.m_afStdWaveForm);
end

abSubset = abCBCL & aiNumSpikes > 500 & afMaxStd./afAmpRange < fQuality;
acUnits = acUnits(abSubset);

%%

aiNumSpikes = zeros(1,length(acUnits));
afFaceSelectivity = zeros(1,length(acUnits));
afAmpRange = zeros(1,length(acUnits));
afMaxStd = zeros(1,length(acUnits));

for k=1:length(acUnits)
    aiNumSpikes(k) = length(acUnits{k}.m_afSpikeTimes);
    fFace = fnMyMean(acUnits{k}.m_afAvgStimulusResponseMinusBaseline(1:207));
    fNonFace = fnMyMean(acUnits{k}.m_afAvgStimulusResponseMinusBaseline(208:end));
    afFaceSelectivity(k) =(fFace-fNonFace)/(fFace+fNonFace);
    afAmpRange(k) = max(acUnits{k}.m_afAvgWaveForm)-min(acUnits{k}.m_afAvgWaveForm);
    afMaxStd(k) = max(acUnits{k}.m_afStdWaveForm);
end
acUnits = acUnits(aiNumSpikes > 500 & afMaxStd./afAmpRange < 0.5);
iNumUnits = length(acUnits);
abRocco = zeros(1,iNumUnits)>0;

for j=1:iNumUnits
    abRocco(j) = strcmpi(acUnits{j}.m_strSubject,'Rocco');
end
fprintf('%d Units survived (%d In Rocco and %d in Houdini)\n',iNumUnits,sum(abRocco),sum(~abRocco));
iSelectedCell = fnFindExampleCell(acUnits, 'Rocco','30-Apr-2010 17:29:57',18, 1, 2);

%%

% Decoding Analysisif 
a2bDecisions = zeros(411,iNumUnits);
for k=1:iNumUnits
    afFaceRes = acUnits{k}.m_afAvgStimulusResponseMinusBaseline(1:207);
    afNonFaceRes = acUnits{k}.m_afAvgStimulusResponseMinusBaseline(208:411);
    
    afFaceRes = afFaceRes(~isnan(afFaceRes))';
    afNonFaceRes = afNonFaceRes(~isnan(afNonFaceRes))';
    [W,Thres]=fnFisherDiscriminant(afFaceRes(:),afNonFaceRes(:));
    fThresholdCorrected = Thres/W;
    a2bDecisions(:,k) = acUnits{k}.m_afAvgStimulusResponseMinusBaseline(1:411) > fThresholdCorrected;
    
    
    fDeno = sqrt( (std(afFaceRes).^2+std(afNonFaceRes).^2)/2);
    afDprime(k) = abs(mean(afFaceRes) - mean(afNonFaceRes)) / (fDeno+eps);

    
    afFaceRes2 =  a2bDecisions(1:207,k);
    afNonFaceRes2 =  a2bDecisions(208:411,k);
    
    fDeno2 = sqrt( (std(afFaceRes2).^2+std(afNonFaceRes2).^2)/2);
    afDprime2(k) = abs(mean(afFaceRes2) - mean(afNonFaceRes2)) / (fDeno2+eps);
    
end
afTmp = sum(a2bDecisions,2);

figure(100);
clf;
[afHistDPrime, afCent] = hist(afDprime,0:0.1:1.7);
bar(afCent,afHistDPrime,0.7);
xlabel('d''');
ylabel('Number of units');
box on
if ~isempty(iSelectedCell)
   [f1,f2,afFP_Single,afTP_Single]=fnHistTwoClass(1e3*acUnits{iSelectedCell}.m_afAvgStimulusResponseMinusBaseline(1:207),1e3*acUnits{iSelectedCell}.m_afAvgStimulusResponseMinusBaseline(208:end))
   
   [f1,f2,afFP_Pop,afTP_Pop]=fnHistTwoClass(afTmp(1:207),afTmp(208:end));
    figure(f1);
    xlabel('Number of units voting for a face');
   figure;
   clf;
   hold on;
   plot(afFP_Single,afTP_Single,'k-.','LineWidth',2);
   plot(afFP_Pop,afTP_Pop,'k','LineWidth',2);
   legend('Single Cell','Population','Location','NorthEastOutside');
   axis equal
   box on
   grid on
   xlabel('False Positive Rate');
   ylabel('True Positive Rate');
end

   

%%
if 1
    load('CBCL_Models.mat');
    %%
    a2fFace = zeros(iNumUnits, 13);
    a2fNonFace = zeros(iNumUnits, 13);
    a2fFaceMax = zeros(iNumUnits, 13);
    a2fNonFaceMax = zeros(iNumUnits, 13);
    afDPrime = zeros(1,iNumUnits);
    a2fStd= zeros(iNumUnits, 13);
    afPerecentCorrect = zeros(1,iNumUnits);
    iNumUnits = length(acUnits);
    a2fStdNonFace = zeros(iNumUnits, 13);
    for iUnitIter=1:iNumUnits
        [a2fFace(iUnitIter,:), a2fNonFace(iUnitIter,:),...
            a2fFaceMax(iUnitIter,:), a2fNonFaceMax(iUnitIter,:),...
            afDPrime(iUnitIter),afPerecentCorrect(iUnitIter),a2fStd(iUnitIter,:),a2fStdNonFace(iUnitIter,:)] = ...
            fnFiringRateNumberOfCorrectRatios(acUnits{iUnitIter}, aiNumCorrectPairsInFaces_Sinha,aiNumCorrectPairsInNonFaces_Sinha,true,true);
    end
end
%%

afMeanF = zeros(1,13);
afStdErrF= zeros(1,13);
afMeanNF = zeros(1,13);
afStdErrNF= zeros(1,13);
for k=1:13
    [afMeanF(k),fDummy,afStdErrF(k)] = fnMyMean(a2fFace(:,k));
    [afMeanNF(k),fDummy,afStdErrNF(k)] = fnMyMean(a2fNonFace(:,k));    
end
%%

[afFaceSel, afNonFaceSel, Dummy1, Dummy2, Dummy3, Dummy4, afStdFaceSel, afStdNonFaceSel] = ...
            fnFiringRateNumberOfCorrectRatios(acUnits{iSelectedCell}, aiNumCorrectPairsInFaces_Sinha,aiNumCorrectPairsInNonFaces_Sinha,false,false);

figure(80);clf;hold on;
ahHandle(1) = fnFancyPlot2(0:12, afFaceSel, afStdFaceSel, [79,129,189]/255,0.5*[79,129,189]/255);
ahHandle(2) = fnFancyPlot2(0:12, afNonFaceSel, afStdNonFaceSel, [192,80,77]/255,0.5*[192,80,77]/255);
box on
set(gca,'xtick',0:12);
set(gca,'xlim',[0 12]);
grid on
figure(9);clf;
hold on;
ahHandle(1) = fnFancyPlot2(0:12, afMeanF, afStdErrF, [79,129,189]/255,0.5*[79,129,189]/255);
ahHandle(2) = fnFancyPlot2(0:12, afMeanNF, afStdErrNF, [192,80,77]/255,0.5*[192,80,77]/255);

set(gca,'xtick',0:12);
set(gca,'xlim',[0 12]);

% xlabel('Number of correct features (predicted by Sinha)');
% ylabel('Normalized firing rate, baseline subtracted (Hz)');

legend(ahHandle,'Faces','Non Faces','Location','NorthEastOutside');
grid on
box on

figure(6);
subplot(2,1,1);
hist(afPerecentCorrect);
xlabel('Percent Correct');
ylabel('Number of Units');
subplot(2,1,2);
hist(afDPrime);
xlabel('d''');
ylabel('Number of Units');
%% Latency Differences ?
a2fAvgResponseFacesPop = zeros(13,701);
a2fAvgResponseNonFacesPop = zeros(13,701);
for iUnitIter=1:iNumUnits
    strctUnit = acUnits{iUnitIter};
    
    a2fAvgResponseFaces = zeros(13, 701);
    a2fAvgResponseNonFaces = zeros(13, 701);
    for k=0:12
        aiIndFace = find(aiNumCorrectPairsInFaces_Sinha == k);
        if ~isempty(aiIndFace)
            afAvgResponse = mean(strctUnit.m_a2fAvgFirintRate_Stimulus(aiIndFace,:),1);
            a2fAvgResponseFaces(k+1,:) = afAvgResponse;
        end
        
     aiIndNonFace = find(aiNumCorrectPairsInNonFaces_Sinha == k);
        if ~isempty(aiIndNonFace)
            afAvgResponse = mean(strctUnit.m_a2fAvgFirintRate_Stimulus(207+aiIndNonFace,:),1);
            a2fAvgResponseNonFaces(k+1,:) = afAvgResponse;
        end
        
    end
    fNorm = max(strctUnit.m_a2fAvgFirintRate_Stimulus(:));
    a2fAvgResponseFaces = a2fAvgResponseFaces / fNorm;
    a2fAvgResponseNonFaces = a2fAvgResponseNonFaces / fNorm;
    
    a2fAvgResponseFacesPop = a2fAvgResponseFacesPop + a2fAvgResponseFaces;
    a2fAvgResponseNonFacesPop = a2fAvgResponseNonFacesPop + a2fAvgResponseNonFaces;
end
 for k=0:12
     acName{k+1} = [num2str(k),' Correct '];
 end
a2fAvgResponseNonFacesPop = a2fAvgResponseNonFacesPop / iNumUnits;
a2fAvgResponseFacesPop = a2fAvgResponseFacesPop / iNumUnits;

[afPeak,aiIndices] =  max(a2fAvgResponseFacesPop(:,200:500),[],2);
aiNonZero = afPeak~=0;
afPeak = afPeak(aiNonZero);
aiIndices = aiIndices(aiNonZero);
figure(10);
clf;
aiPeri = -200:500;
plot(aiPeri,a2fAvgResponseFacesPop','LineStyle','-');
hold on;
T=robustfit(aiIndices,afPeak);
X = 120:250;
plot(X, T(2)*X+T(1),'k');
plot((aiIndices),afPeak,'*');
xlabel('Time (ms)');
ylabel('Avg Response');
legend([acName,'Regression to peak'],'Location','NorthEastOutside');
title('Response to faces on CBCL');


[afPeak,aiIndices] =  max(a2fAvgResponseNonFacesPop(:,200:500),[],2);
aiNonZero = afPeak~=0;
afPeak = afPeak(aiNonZero);
aiIndices = aiIndices(aiNonZero);
figure(11);
clf;
aiPeri = -200:500;
plot(aiPeri,a2fAvgResponseNonFacesPop','LineStyle','-');
hold on;
T=robustfit(aiIndices,afPeak);
X = 120:250;
plot(X, T(2)*X+T(1),'k');
plot((aiIndices),afPeak,'*');
xlabel('Time (ms)');
ylabel('Avg Response');
legend([acName,'Regression to peak'],'Location','NorthEastOutside');
title('Response to non-faces on CBCL');


%%
strctTmp = load('CBCL_SelectedPerm.mat');
aiNumCorrectSinhaInFaces = strctTmp.afSumTrainFaceAvg(strctTmp.aiFace);
aiNumCorrectSinhaInNonFaces = strctTmp.afSumTrainNonFaceAvg(strctTmp.aiNonFace);

T = [aiNumCorrectSinhaInFaces;aiNumCorrectSinhaInNonFaces];
X = 1:20:length(T);
clear acName
for k=1:length(X)
    acName{k} = sprintf('%d',T(X(k)));
end

%%
if ~isempty(iSelectedCell)
figure(2);
clf;
imagesc(acUnits{iSelectedCell}.m_aiPeriStimulusRangeMS, 1:411, acUnits{iSelectedCell}.m_a2fAvgFirintRate_Stimulus(1:411,:))
set(gca,'ytick',X,'yticklabel',acName);
hold on;
plot([-200 500],[208 208],'w');
xlabel('Time (ms)');
colorbar
set(gcf,'color',[1 1 1])
%ylabel('Number of incorrect pairs');
end
%% FAlse Alarm Analysis

aiNumCorr = [aiNumCorrectPairsInFaces_Sinha;aiNumCorrectPairsInNonFaces_Sinha];

aiNumFA = zeros(1,iNumUnits);

iNumUnits = length(acUnits);
aiCount = zeros(1,411 );
for iUnitIter=1:iNumUnits 
    strctUnit=acUnits{iUnitIter};
    
    afAvgResponse = strctUnit.m_afAvgStimulusResponseMinusBaseline;
    afFacesRes = afAvgResponse(1:207);
    afSortedFaceRes = sort(afFacesRes);
    fPercentile = 0.95;
    fPercentileRes = afSortedFaceRes(round(fPercentile*length(afFacesRes)));
    afNonFaceRes = afAvgResponse(208:411);
    aiFalseAlarms = 207+find(afNonFaceRes > fPercentileRes);
    aiCount(aiFalseAlarms)=aiCount(aiFalseAlarms)+1;
    aiNumFA(iUnitIter) = length(aiFalseAlarms);
    
     
end


% aiFAInd = find(aiCount);
% figure;
% plot( aiCount(aiFAInd), aiNumCorr(aiFAInd),'b.');
% xlabel('Number of times image was fired as a FA');
% ylabel('Number of correct ratios');
% 
% 

return;

function hHandle = fnFancyPlot(afX, afY, afS, afColor1,afColor2)
aiNonNaN = ~isnan(afY);
afX = afX(aiNonNaN);
afY = afY(aiNonNaN);
afS = afS(aiNonNaN);

hHandle=fill([afX, afX(end:-1:1)],[afY+afS, afY(end:-1:1)-afS(end:-1:1)], afColor1,'FaceAlpha',0.5);
plot(afX,afY, 'color', afColor2,'LineWidth',2);
return;





function [afFaceSelectivityIndex] = fnFaceSelectivityIndex(acUnits, fStartAvgMS, fEndAvgMS)
iNumUnits = length(acUnits);
afFaceSelectivityIndex = zeros(1,iNumUnits);
for iUnitIter=1:iNumUnits
    strctUnit = acUnits{iUnitIter};

    iStartAvg = find(acUnits{iUnitIter}.m_aiPeriStimulusRangeMS >= fStartAvgMS,1,'first');
    iEndAvg = find(acUnits{iUnitIter}.m_aiPeriStimulusRangeMS >= fEndAvgMS,1,'first');

    fMeanFaceResponse = mean(mean(strctUnit.m_a2fAvgFirintRate_Stimulus(1:207, iStartAvg:iEndAvg),2));
    fMeanNonFaceResponse = mean(mean(strctUnit.m_a2fAvgFirintRate_Stimulus(208:end, iStartAvg:iEndAvg),2));
    
    afFaceSelectivityIndex(iUnitIter) = (fMeanFaceResponse-fMeanNonFaceResponse)/(fMeanFaceResponse+fMeanNonFaceResponse);
end
return;

