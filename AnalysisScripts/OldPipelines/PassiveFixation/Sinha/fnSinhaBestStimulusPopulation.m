function fnSinhaPopulationAnalysis(acUnits,strctConfig)

%%
warning off
for k=1:15
    try
        close(k)
    catch
    end
end
warning on
%% Face Selectivity Index
bUseStandardParamOnly = true;
bAnalyzeOnlySubSet = true;

fQuality =  0.5; %1.2

aiNumSpikes = zeros(1,length(acUnits));
afMUA = zeros(1,length(acUnits));
afMaxStd = zeros(1,length(acUnits));
afAmpRange = zeros(1,length(acUnits));
abNoData = zeros(1,length(acUnits)) > 0;
for k=1:length(acUnits)
    if ~isfield(acUnits{k},'m_afISIDistribution') || ~isfield(acUnits{k},'m_afSpikeTimes') 
        abNoData(k) = true;
        continue;
    end
    aiNumSpikes(k) = length(acUnits{k}.m_afSpikeTimes);
    afMUA(k) = sum(acUnits{k}.m_afISIDistribution(1:3))/  sum(acUnits{k}.m_afISIDistribution) * 100;
    afAmpRange(k) = max(acUnits{k}.m_afAvgWaveForm)-min(acUnits{k}.m_afAvgWaveForm);
    afMaxStd(k) = max(acUnits{k}.m_afStdWaveForm);
    
end

acUnits = acUnits(~abNoData & aiNumSpikes > 500 & afMaxStd./afAmpRange < fQuality); % This clears up most of the junk units
% The MUA was not found to be a reliable measure and many good units were
% thrown away...
[aiFaceSelectivityIndex]  = fnComputeFaceSelecitivyIndex(acUnits);

abRelevant = zeros(1,length(acUnits))>0;
for iUnitIter=1:length(acUnits)
    switch acUnits{iUnitIter}.m_strParadigmDesc
        case 'Sinha_v2_FOB'
            abRelevant(iUnitIter)=1;
        otherwise
    end
end
acUnits2=acUnits(abRelevant & aiFaceSelectivityIndex>0.3);
aiTemp = zeros(1,432);
a2fAvgRes = zeros(432,length(acUnits2));
for k=1:length(acUnits2)
    
    afRes = acUnits2{k}.m_afAvgFirintRate_Stimulus(97:528);
    afRes = afRes/max(afRes);
    a2fAvgRes(:,k)=afRes;
end
for k=0:12
    aiInd = find(aiNumWrongRatios==k);
    afAvgRes(k+1) = mean(mean(a2fAvgRes(aiInd,:)));
end
[afSorted,aiInd]=sort(mean(a2fAvgRes,2))
figure;plot(aiNumWrongRatios(aiInd),'.')

mean(aiNumWrongRatios(aiInd(1:16)))
mean(aiNumWrongRatios(aiInd(end-16:end)))

figure;plot(afAvgRes)

figure;imagesc(a2fAvgRes);colormap jet
ylabel('Stimuli');
xlabel('Units');

figure;
errorbar(1:432,mean(a2iSort,2),std(a2iSort,[],2)/sqrt(432));

figure;
plot(1:432,mean(a2fAvgRes,2));


abRocco = zeros(1,length(acUnits));
for k=1:length(acUnits)
    abRocco(k) = strcmpi(acUnits{k}.m_strSubject,'Rocco');
end
fprintf('We recorded from %d single units (%d in Houdini and %d in Rocco)\n', length(acUnits),sum(~abRocco),sum(abRocco));


aiSubSet = find(aiFaceSelectivityIndex > 0.3 );
% aiSubSet = find(aiFaceSelectivityIndex > 0 & aiFaceSelectivityIndex < 0.3);


[afH,afX]= hist(aiFaceSelectivityIndex,-1:0.1:1);
hFig = figure(2);
clf
bar(afX,afH,0.7);
hold on;
plot([0.3 0.3],[0 max(afH)],'g');
xlabel('Face Selectivity Index');
ylabel('Number of Units');
axis([-1.1 1.1 0 max(afH)*1.1])
set(gcf,'Position',[923   957   317   141]);
%saveas(hFig,'D:\Publications\Sinha\MatFigures\FaceSelectivity.fig');

if bAnalyzeOnlySubSet
    acUnits = acUnits(aiSubSet);
end

abRocco = zeros(1,length(acUnits));
for k=1:length(acUnits)
    abRocco(k) = strcmpi(acUnits{k}.m_strSubject,'Rocco');
end
fprintf('%d  were found to be face selective cells (%d in Houdini and %d in Rocco)\n',sum(aiFaceSelectivityIndex>0.3),...
    sum(~abRocco),sum(abRocco) );


%% Avg Firing Rate per Category 
[aiPeriStimulusMS, a2fAvgFiringNorm,acAvgFiringNames] = fnComputePeriAvg(acUnits);
hFig = figure(3);
clf;
plot(aiPeriStimulusMS, a2fAvgFiringNorm(1:7,:)','LineWidth',2);
% xlabel('Time (ms)');
% ylabel('Normalized Firing Rate');
acAvgFiringNames{7} = 'Part Intensity';
legend(acAvgFiringNames(1:7),'Location','NorthEastOutside');
axis([-100 400 0 0.8])
grid on
set(gcf,'Position',[ 779   835   461   263]);
%saveas(hFig,'D:\Publications\Sinha\MatFigures\PSTH.fig');

%%


%% Display example cell
%iSelectedCell = fnFindExampleCell(acUnits, 'Houdini','26-Jul-2010 09:22:28', 19, 1, 2);
iSelectedCell = fnFindExampleCell(acUnits, 'Rocco','19-Jul-2010 17:50:06', 8, 1, 1);
if ~isempty(iSelectedCell)
   [a2fFiring,afPValue,acNames]= fnGetAllRatios(acUnits{iSelectedCell});
   afMaxFir = max(a2fFiring,[],2);
    
    hFig=figure(4);
    clf;
    
    h=bar(1:55,1e3*a2fFiring);
    hold on;
    set(h(1),'FaceColor',[74,126,187]/255,'EdgeColor','none');
    set(h(2),'FaceColor',0.9*[190,75,72]/255,'EdgeColor','none');
     aiSig = find(afPValue < 1e-5);
    plot(aiSig,1e3*max(afMaxFir(aiSig))*1.1,'r*');
    axis([0 56 0 38]);
     set(gca,'xtick',1:3:55)
     box on
     
%     xticklabel_rotate
    
      legend({'Int Part A < Int Part B','Int Part A > Int Part B'},'Location','NorthEastOutside');
%     title(sprintf('Cell %s, Exp %d, Ch %d, Unit %d',strctExampleCell.m_strRecordedTimeDate,...
%         strctExampleCell.m_iRecordedSession,strctExampleCell.m_iChannel,strctExampleCell.m_iUnitID));
end

iSelectedCell2 = fnFindExampleCell(acUnits, 'Houdini','22-Jul-2010 09:34:34', 14, 1, 1);
if ~isempty(iSelectedCell2)
strctUnit = acUnits{iSelectedCell2};

A = strctUnit.m_a2fAvgFirintRate_Stimulus(97:528,:);
[Temp,indA]=sort(strctUnit.m_afAvgFirintRate_Stimulus(97:528),'descend');
A = A(indA,:);

B = strctUnit.m_a2fAvgFirintRate_Stimulus(1:16,:);
[Temp,indB]=sort(strctUnit.m_afAvgFirintRate_Stimulus(1:16),'descend');
B = B(indB,:);

C = strctUnit.m_a2fAvgFirintRate_Stimulus(17:96,:);
[Temp,indC]=sort(strctUnit.m_afAvgFirintRate_Stimulus(17:96),'descend');
C = C(indC,:);

figure(100);
clf;
imagesc(strctUnit.m_aiPeriStimulusRangeMS(101:601),1:16,B(:,101:601),[0 100]);
axis xy
set(gca,'ytick',[1 16])
set(gcf,'Position',[1155        1000         318         101])
figure(101);
clf;
imagesc(strctUnit.m_aiPeriStimulusRangeMS(101:601),17:96,C(:,101:601),[0 100]);
axis xy
set(gca,'ytick',[17 96])
set(101,'Position',[ 1152         789         318         101])
set(gca,'xticklabel','');

figure(102);
clf;
imagesc(strctUnit.m_aiPeriStimulusRangeMS(101:601),97:528,A(:,101:601),[0 100]);
axis xy
set(gca,'ytick',[97 528])
set(gcf,'Position',[ 1152         675         318         215])
set(gca,'xticklabel','');
end
% figure(104);
% clf;
% imagesc(strctUnit.m_aiPeriStimulusRangeMS,1:size(NewZ,1),...
%     NewZ,[0 100]);
% colorbar('location','NorthOutside');
% colormap jet
% axis([-20 320 1 529])

%% Significant Ratios
% acUnits = acUnits(abRocco==0);

fPValue = 1e-5;
[a2iSigRatio, acNames, aiSinhaRatio,abASmallerB, aiNumSignificant,a2bSigPair] = fnCalcSigRatiosSinha(acUnits, fPValue);

fnPlotSigmoidsHistograms(acUnits);


if 0
    fnAnalyzeMarginals(acUnits(aiNumSignificant > 0));
end
%fnAnalyzeMarginals2D(acUnits(aiFaceSelectivityIndex > 0.3 & aiNumSignificant > 0));
%%

iNumUnits = length(acUnits);
figure(5);
clf;
hold on;
ahHandles(1) = bar(a2iSigRatio(:,1),'facecolor',[79,129,189]/255);
ahHandles(2) = bar(-a2iSigRatio(:,2),'facecolor',[192,80,77]/255);
% ylabel('Number of units');
% xlabel('Pair Index');



%strctCBCL_Pred = load('D:\Code\Doris\Stimuli_Generating_Code\Sinha\CBCLInvarianceRatios.mat');
strctMonkeyPred = load('D:\Code\Doris\Stimuli_Generating_Code\Sinha\MonkeyInvarianceRatios.mat');
strctShayPred = load('D:\Code\Doris\Stimuli_Generating_Code\Sinha\ShayInvarianceRatios.mat');

fMax = max(abs(a2iSigRatio(:)));
plot([0 55],[fMax+5 fMax+5],'k--');
plot([0 55],[-fMax-5 -fMax-5],'k--');

 % Draw Predictions from monkey
 fMarkerSizeW = 0.5;
 fMarkerSizeH = 4;
%  afR = linspace(0.8,0.8,12);
%  afColors1 = [zeros(12,1),afR',afR'];
%  afColors2 = [ afR',zeros(12,1),afR' ];
%   afColors3 = [0 0 1];

 
 afColors1=1.2*[155,187,89]/255;
  afColors2=1.2*[128,100,162]/255;
  afColors3=1.2*[75,172,198]/255;
 
for k=1:12
    iPairIndex = strctMonkeyPred.aiInvarianceRatios(k);
    if strctMonkeyPred.aiSelectivityIndex(iPairIndex) > 0
        ahHandles(3) = fnPlotFilledTriangle(0,iPairIndex,fMax+10,fMarkerSizeW,fMarkerSizeH, afColors1);
    else
        ahHandles(3) = fnPlotFilledTriangle(1,iPairIndex,-fMax-10,fMarkerSizeW,fMarkerSizeH,afColors1);
    end
      set(ahHandles(3),'edgecolor','none');
    
    iPairIndex = strctShayPred.aiInvarianceRatios(k);
    if strctShayPred.aiSelectivityIndex(iPairIndex) > 0
        ahHandles(4) = fnPlotFilledTriangle(0,iPairIndex,fMax+15,fMarkerSizeW,fMarkerSizeH, afColors2);
    else
        ahHandles(4) = fnPlotFilledTriangle(1,iPairIndex,-fMax-15,fMarkerSizeW,fMarkerSizeH, afColors2);
    end
        set(ahHandles(4),'edgecolor','none');
  
    iPairIndex = aiSinhaRatio(k);
    if ~abASmallerB(k)
        ahHandles(5) = fnPlotFilledTriangle(0,iPairIndex,fMax+20,fMarkerSizeW,fMarkerSizeH, afColors3);

    else
        ahHandles(5) = fnPlotFilledTriangle(1,iPairIndex,-fMax-20,fMarkerSizeW,fMarkerSizeH, afColors3);

    end
       set(ahHandles(5),'edgecolor','none');
     
end

legend(ahHandles,{'Part A < Part B','Part A > Part B','Pred Monkey','Pred Human','Pred Sinha'},'Location','NorthEastOutside');
axis([0 56 -fMax-25 fMax+25])
set(gca,'yticklabel',num2str(abs(str2num(get(gca,'ytickLabel')))));
box on
% set(gcf,'position',[   486   700   858   331]);
% set(gca,'position',[0.1300    0.1100    0.5839    0.8150]);

%%
set(gcf,'position',[275   703   612   299]);

set(gca,'Position',[ 0.1300    0.1100    0.5070    0.8150]);

%title(sprintf('n= %d, P < 10^{-%d}',iNumUnits,log10(fPValue)));
%%
[afHist,afCent]=hist(aiNumSignificant,0:55);
figure(6);
clf;
bar(afCent,afHist,0.7);
grid on
% xlabel('Number of significant features');
% ylabel('Number of units');
fprintf('%d out of %d are tuned for at least one pair, on avg: %.2f +- %.2f \n',sum(aiNumSignificant>0),length(aiNumSignificant),mean(aiNumSignificant(aiNumSignificant>0)),...
    std(aiNumSignificant(aiNumSignificant>0)))
fprintf('%.2f are tuned for at least one pair\n',sum(aiNumSignificant>0))

%title(sprintf('n= %d, log_{10}(p-Value) < %.1f',iNumUnits,log10(fPValue)));
axis([-1 33 0 40])
acTicks = get(gca,'yticklabel');
acTicks(:,3) = ' ';
acTicks(end,:) = '120';
set(gca,'ytickLabel',acTicks);
set(gcf,'Position',[ 680   835   411   263]);
% % strctTmp = load('SinhaPairSelectivityIndex.mat');
% % 
% % figure(7);
% % clf;
% % subplot(1,2,1);
% % plot(abs(strctTmp.aiSelectivityIndex(aiSortInd)));
% % xlabel('Pair Index, sorted by number of cells tuned for it');
% % ylabel('Predicted Selectivity Index from CBCL');
% % subplot(1,2,2);
% % plot(X/iNumUnits, abs(strctTmp.aiSelectivityIndex),'.');
% % xlabel('Percentage of units tuned');
% % ylabel('Predicted selectivity index');
 % Number 8 in the sorted list correspond to pair number 2, which is
 % forehead nose, revealing that CBCL prediction is not good because there
 % is little forehead information there.
% 
% figure(7);
% clf;
% plot(afNumSig /iNumUnits,'LineWidth',3)
% xlabel('Part Pairs');
% ylabel('Percent of cells tuned for this ratio');
% grid on
% title(sprintf('n = %d, log10(p) < %d ',iNumUnits,log10(fPValue)));
% 
% abInSinhaSet = ismember(aiSortInd(1:iNumDisplay),intersect(aiSinhaRatio, aiSortInd(1:iNumDisplay)));

% aiSinhaSubset = find(abInSinhaSet);
X = abs(a2iSigRatio(:,1)-a2iSigRatio(:,2));
[afNumSig, aiSortInd] = sort(X,'descend');

figure(7);
clf;hold on;
iNumDisplay = 10;

a2iPartRatio = nchoosek(1:11,2);
acPartNames = {'Forehead','L Eye','Nose','R Eye','L Cheek','Up Lip','R Cheek','LL Cheek','Mouth','LR Cheek','Chin'};
    
abALargerB = a2iSigRatio(aiSortInd(1:iNumDisplay),1) > a2iSigRatio(aiSortInd(1:iNumDisplay),2);
acTunedPairs = cell(1,iNumDisplay);
for j=1:iNumDisplay
    iPartA = a2iPartRatio(aiSortInd(j),1);
    iPartB = a2iPartRatio(aiSortInd(j),2);
    if abALargerB(j)
        acTunedPairs{j} = [acPartNames{iPartA},' > ',acPartNames{iPartB}];
    else
        acTunedPairs{j} = [acPartNames{iPartB},' > ',acPartNames{iPartA}];
    end
end
iNumTunedUnits = sum(aiNumSignificant>0);
barh(afNumSig(1:iNumDisplay) /iNumTunedUnits,0.7);
axis ij
% set(gca,'yticklabel',acTunedPairs);
set(gca,'yticklabel','');
% set(gca,'ytick',1:iNumDisplay);
%xlabel('Percent of tuned cells');
%legend(h2,'Sinha Proposed Ratio' ,'Location','NorthEastOutside');
grid on
%set(gca,'ylim',[0 19])
axis([0 0.8 0 11])
box on
%% Display Part contrast tuning for example cell
if iSelectedCell > 0
    fnDisplayExampleCellContrastTuningCurve(acUnits{iSelectedCell});
    
end
fnDisplayPairWiseContrast(acUnits)
 fnDisplayPopulationContrastTuningCurve(acUnits)
 
 
 fnDisplayAnovaStatistics(acUnits);

 %%
 
  fnDisplayPairWiseCorrelations(acUnits,a2bSigPair);

%%



%% Draw Number of incorrect sinha ratios (population)
%fnSinhaIncorrectRatioPlotAnalysis(acUnits);

%% Draw Pair-wise contrast tuning for population
%fnDisplayPairWiseContrast(acUnits);

 %% Draw Pair-wise contrast tuning for example cell


 
 

return;


function fnDisplayPairWiseCorrelations(acUnits,a2bSigPair)
iNumUnits = length(acUnits);
afFractionVarianceExplained = zeros(1,iNumUnits);
a2fOptWeights = zeros(iNumUnits,11);
fThresP = 10^-4;
aiNumSigPairs = NaN*ones(1,iNumUnits);
aiNumInteractions = NaN*ones(1,iNumUnits);
aiSigByUtest = zeros(1,iNumUnits);
for iUnitIter=1:iNumUnits
    a2fP = cat(2,acUnits{iUnitIter}.m_acSinhaPlots{6}.m_astrctPairwiseAnova.m_afP);
    aiNumSigPairs(iUnitIter) = sum(a2fP(1,:) < fThresP & a2fP(2,:) < fThresP);
    aiNumInteractions(iUnitIter) = sum(a2fP(1,:) < fThresP & a2fP(2,:) < fThresP & a2fP(3,:) < fThresP);
    afFractionVarianceExplained(iUnitIter) = 100-acUnits{iUnitIter}.m_acSinhaPlots{7}.m_fVarianceExplained;
    aiSigByUtest(iUnitIter) = sum(acUnits{iUnitIter}.m_acSinhaPlots{3}.m_afPolarDiffPvalue < 1e-5);
    a2fOptWeights(iUnitIter,:) = acUnits{iUnitIter}.m_acSinhaPlots{7}.m_afOptW;
end

% 
% 
% strctStat.m_afCorrSum = afCorrSum;
% strctStat.m_afCorrMax = afCorrMax;
% strctStat.m_afCorrMult = afCorrMult;

abHasSigPair = sum(a2bSigPair,2) > 0;
figure(20);clf;
[afHist,afCent]= hist(afFractionVarianceExplained(abHasSigPair)/100,0:0.05:1);
bar(afCent,afHist,0.7);
axis([-0.05 0.5 0 max(afHist)+5])
box on
xlabel('Fraction of Variance Explained');
ylabel('Number of Units');

afCorrSum = [];
afCorrMult= [];
afCorrMax = [];
for iUnitIter=1:iNumUnits
    afCorrSum = [afCorrSum,acUnits{iUnitIter}.m_acSinhaPlots{7}.m_afCorrSum(a2bSigPair(iUnitIter,:))];
    afCorrMult = [afCorrMult,acUnits{iUnitIter}.m_acSinhaPlots{7}.m_afCorrMult(a2bSigPair(iUnitIter,:))];
    afCorrMax = [afCorrMax,acUnits{iUnitIter}.m_acSinhaPlots{7}.m_afCorrMax(a2bSigPair(iUnitIter,:))];
end

afCent = 0:0.1:1;
[afHistSum,afCent]=hist(afCorrSum,afCent);
[afHistMult,afCent]=hist(afCorrMult,afCent);
[afHistMax,afCent]=hist(afCorrMax,afCent);


figure(21);
clf;
ahHandles = bar(afCent,[afHistSum',afHistMult', afHistMax'] ,0.7);
set(ahHandles(1),'FaceColor',[0 0 0.6]);
set(ahHandles(2),'FaceColor',[0 0.6 0]);
set(ahHandles(3),'FaceColor',[0.6 0 0]);
xlabel('Correlation Coefficient');
ylabel('Number of part pairs');
box on


% 
% 
% aiSigCell = find(aiNumSigPairs > 0);
% [afHist,afCent] = hist(aiNumSigPairs(aiSigCell),0:20);
% 
% figure(10);
% clf;
% bar(afCent,afHist,0.8);
% set(gca,'xtick',[0:10,12:2:20])
% xlabel('Number of significant pairs');
% ylabel('Number of Units');
% axis([0 20 0 max(afHist)*1.1]);
% 
% 
% aiSigCell = find(aiNumSigPairs > 0);
% [afHist,afCent] = hist(aiNumInteractions(aiSigCell),0:15);
% 
% figure(161);
% clf;
% bar(afCent,afHist,0.8);
% set(gca,'xtick',0:20)
% xlabel('Number of significant pairs interactions');
% ylabel('Number of Units');
% axis([-0.5 15 0 max(afHist)*1.1]);
% 
% aiNumInteractions(aiSigCell) ./ aiNumSigPairs(aiSigCell) * 100
% hist(aiNumInteractions(find(aiNumSigPairs)),0:55)


return;


function fnDisplayAnovaStatistics(acUnits)
iNumUnits = length(acUnits);
a2fPartPvalues = zeros(iNumUnits,11); %11-way anova

fThresPvalue = 0.01;
aiNumSigInteractions = zeros(1,iNumUnits);
a2bSig = zeros(iNumUnits,55);
a2fPartRobustFitPvalue = zeros(iNumUnits,11);

for iUnitIter=1:iNumUnits
    a2fPartPvalues(iUnitIter,:) = acUnits{iUnitIter}.m_acSinhaPlots{6}.m_strctAnova.m_afP';
    a2fPartRobustFitPvalue(iUnitIter,:) = acUnits{iUnitIter}.m_acSinhaPlots{2}.m_afPvalue;
    a2fInteractions =  cat(2,acUnits{iUnitIter}.m_acSinhaPlots{6}.m_astrctPairwiseAnova.m_afP);
    aiNumSigInteractions(iUnitIter) = sum(a2fInteractions(3,:) < fThresPvalue & a2fInteractions(1,:) < fThresPvalue & a2fInteractions(2,:) < fThresPvalue);
    a2bSig(iUnitIter,:) = all(a2fInteractions < 1e-4,1);
end
afNumSignificantParts = sum(a2fPartPvalues < fThresPvalue,2);
fprintf('From %d units, %d have NO sig part (anova factor), and %d do have at least one. \n', iNumUnits,sum(afNumSignificantParts==0),sum(afNumSignificantParts>0) );

[afHist,afCent] = hist(afNumSignificantParts(afNumSignificantParts>0),0:11);
afWhichSig = sum(a2fPartPvalues < fThresPvalue,1);
figure(14);
bar(afCent,afHist,0.7);
xlabel('Number of significant face parts');
ylabel('Number of units');
box on
axis([0 11 0 max(afHist)+5])
set(gca,'xtick',[0:11])

figure(15);clf;
barh(afWhichSig,0.7);
set(gca,'ytickLabel',acUnits{1}.m_acSinhaPlots{2}.m_acPartNames);
xlabel('Number of units');
box on
axis(gca,[0 max(afHist)+5 0 11.5])
% 
% afNumSignificantParts = sum(a2fPartRobustFitPvalue < fThresPvalue,2);
% [afHist,afCent] = hist(afNumSignificantParts(afNumSignificantParts>0),0:11);
% afWhichSig = sum(a2fPartPvalues < fThresPvalue,1);
% figure(16);
% bar(afCent,afHist,0.7);
% xlabel('Number of significant face parts');
% ylabel('Number of units');
% box on
% axis([0 11 0 max(afHist)+5])
% set(gca,'xtick',[0:11])
% % afWhichSig/sum(afWhichSig)*1e2
% figure(16);clf;
% barh(afWhichSig,0.7);
% set(gca,'ytickLabel',acUnits{1}.m_acSinhaPlots{2}.m_acPartNames);
% xlabel('Number of units');
% box on
% axis(gca,[0 max(afHist)+5 0 11.5])
% 
% %% Interactions
% [afHist,afCent] = hist(aiNumSigInteractions);
% figure(125);clf;
% bar(1:11,afWhichSig,0.8);
% set(gca,'xtickLabel',acUnits{1}.m_acSinhaPlots{2}.m_acPartNames);
% ylabel('Number of units');
% box on
% axis([0 11.5 0 max(afHist)+5])
% xticklabel_rotate;

fprintf('%d out of %d were found to have significant interactions with P value smaller than 10^-5\n',sum(aiNumSigInteractions>0),iNumUnits);


%% 
iSelectedCell = fnFindExampleCell(acUnits, 'Houdini','29-Jul-2010 10:30:35', 2, 1, 1);

return;


function fnAnalyzeMarginals(acUnits)
iNumUnits = length(acUnits);
afCorrelationSum = zeros(1,iNumUnits);
afCorrelationMult =zeros(1,iNumUnits);
afCorrelationMax =zeros(1,iNumUnits);

for k=1:iNumUnits
    strctUnit = acUnits{k};
    if strcmp(acUnits{k}.m_strImageListDescrip,'SinhaFOB')
        strctTmp = load('SinhaV1.mat');
        a2iPerm = strctTmp.a2iAllPerm(1:242,:);
    else
        strctTmp = load('SinhaV2.mat');
        a2iPerm = strctTmp.a2iAllPerm;
    end
        iStimulusOffset = 96;
    

% Variance explained by a linear summation model
iNumPerm = size(a2iPerm,1);
iNumParts = 11;
iNumIntensities = 11;
a2fPredictedResponseComponents = zeros(iNumPerm, iNumParts);
afRecordedAvgResponse = zeros(1,iNumPerm);
for iStimulusIter=1:iNumPerm
   afRecordedAvgResponse(iStimulusIter) = strctUnit.m_afAvgFirintRate_Stimulus(iStimulusOffset+iStimulusIter);
    aiInd = sub2ind([iNumParts iNumIntensities], 1:iNumParts, double(a2iPerm(iStimulusIter,:)));
    a2fPredictedResponseComponents(iStimulusIter,:) = strctUnit.m_acSinhaPlots{1}.m_a2fPartIntensityMean(aiInd);
end
% Linear Model

%afOptimalWeights = a2fPredictedResponseComponents\afRecordedAvgResponse';

%afPredictedResponses_LinearWeightedAddition = a2fPredictedResponseComponents * afOptimalWeights;
%afPredictedResponses = afPredictedResponses_LinearWeightedAddition;

afCorrelationSum(k) = corr(afRecordedAvgResponse', sum(a2fPredictedResponseComponents,2));
afCorrelationMult(k) = corr(afRecordedAvgResponse', prod(a2fPredictedResponseComponents,2));
afCorrelationMax(k) = corr(afRecordedAvgResponse', max(a2fPredictedResponseComponents,[],2));

end

%mean(afCorrelationMax.^2)
%mean(afCorrelationSum.^2)


figure(111);
clf;
subplot(1,3,1);
[afHist,afCent] = hist(afCorrelationSum);
bar(afCent,afHist);
xlabel('Correlation Coefficient');
ylabel('Num Units');
title('Summation Model')
hold on;
plot([mean(afCorrelationSum) mean(afCorrelationSum)],[ 0 max(afHist)],'g','Linewidth',2);
subplot(1,3,2);
[afHist,afCent] = hist(afCorrelationMult);
bar(afCent,afHist);
xlabel('Correlation Coefficient');
ylabel('Num Units');
title('Multiplication Model')
hold on;
plot([mean(afCorrelationMult) mean(afCorrelationMult)],[ 0 max(afHist)],'g','Linewidth',2);
subplot(1,3,3);
[afHist,afCent] = hist(afCorrelationMax);
bar(afCent,afHist);
xlabel('Correlation Coefficient');
ylabel('Num Units');
title('Max Model')
hold on;
plot([mean(afCorrelationMax) mean(afCorrelationMax)],[ 0 max(afHist)],'g','Linewidth',2);

fprintf('Mean Correlation for Sum model: %.2f\n',mean(afCorrelationSum));
fprintf('Mean Correlation for Max model: %.2f\n',mean(afCorrelationMax));
fprintf('Mean Correlation for Mult model: %.2f\n',mean(afCorrelationMult));

 
% Explained Variance ?
% SStot = sum( (afRecordedAvgResponse-mean(afRecordedAvgResponse)).^2);
% SSreg = sum( (afPredictedResponses-mean(afPredictedResponses)).^2);
% SSerr =   sum( (afRecordedAvgResponse-afPredictedResponses').^2);
% fCoefficientOfDetermination = 1 - SSerr/SStot 
% 
% SSE = SSerr
% SST = SStot
% r2 = 1 - SSE/SST % betwen 0 ,, 1
% 
% rPearson = corr(afRecordedAvgResponse', afPredictedResponses); %sum( (afRecordedAvgResponse-mean(afRecordedAvgResponse)) .* (afPredictedResponses-mean(afPredictedResponses))') / ...
%     %    ( (length(afPredictedResponses)-1) * std(afPredictedResponses) * std(afRecordedAvgResponse));
% fFractionOfVarianceUnexplained = 1- rPearson^2;
% fFractionOfVarianceExplained = rPearson^2;

return;






function fnAnalyzeMarginals2D(acUnits)
iNumUnits = length(acUnits);
afCorrelationSum = zeros(1,iNumUnits);
afCorrelationMult =zeros(1,iNumUnits);
afCorrelationMax =zeros(1,iNumUnits);

for k=1:iNumUnits
    fprintf('Unit %d\n',k);
    strctUnit = acUnits{k};
    if strcmp(acUnits{k}.m_strImageListDescrip,'SinhaFOB')
        strctTmp = load('SinhaV1.mat');
        a2iPerm = strctTmp.a2iAllPerm(1:242,:);
    else
        strctTmp = load('SinhaV2.mat');
        a2iPerm = strctTmp.a2iAllPerm;
    end
    iStimOffset = 96;
    
    
    % Variance explained by a linear summation model
    iNumPerm = size(a2iPerm,1);
    iNumParts = 11;
    iNumIntensities = 11;
    
    
    a2iPartRatio = nchoosek(1:11,2);
    
    
    fStartAvgMs = 50;
    fEndAvgMs = 200;
    iStartAvg = find(strctUnit.m_aiPeriStimulusRangeMS >= fStartAvgMs,1,'first');
    iEndAvg = find(strctUnit.m_aiPeriStimulusRangeMS >= fEndAvgMs,1,'first');
    
    
    afOriginalFiringRate = zeros(1,iNumPerm);
    afPredResAdd = zeros(1,iNumPerm);
    for iHoldOneBack=1:iNumPerm
            fprintf(' %d ',iHoldOneBack);
        a3fContrast = ones(11,11,55)*NaN;
        afOriginalFiringRate(iHoldOneBack) = mean(strctUnit.m_a2fAvgFirintRate_Stimulus(iStimOffset+iHoldOneBack,iStartAvg:iEndAvg),2);
        
        for iPairIter=1:55
            iPartA = a2iPartRatio(iPairIter,1);
            iPartB = a2iPartRatio(iPairIter,2);
            for iIntIter1=1:11
                for iIntIter2=1:11
                    aiStimuli = setdiff(find( a2iPerm(:,iPartA) == iIntIter1 & a2iPerm(:,iPartB) == iIntIter2 ), iHoldOneBack);
                    
                    if ~isempty(aiStimuli)
                        a3fContrast(iIntIter1,iIntIter2,iPairIter) = mean(mean(strctUnit.m_a2fAvgFirintRate_Stimulus(iStimOffset+aiStimuli,iStartAvg:iEndAvg),2));
                    end
                end
            end
            
        end
        fprintf('\n');
        % Fill in neirest neighbhor
        [a2fX,a2fY] = meshgrid(1:11,1:11);
        for iFillIter=1:55
            A=a3fContrast(:,:,iFillIter);
            N = isnan(A);
            [aiI,aiJ]=find(N);
            ZI = griddata(a2fX(~N),a2fY(~N),A(~N),aiJ,aiI);
            B=A;
            B(N)=ZI;
            a3fContrast(:,:,iFillIter) = B;
        end
        
        % Can we recover the firing rate from the permutation ?
        afValues = zeros(1, 55);
        for iIter=1:55
            iPartA = a2iPartRatio(iIter,1);
            iPartB = a2iPartRatio(iIter,2);
            iIntensityA = a2iPerm(iHoldOneBack,iPartA);
            iIntensityB = a2iPerm(iHoldOneBack,iPartB);
            afValues(iIter) = a3fContrast(iIntensityA, iIntensityB ,iIter);
        end
        
        afPredResAdd(iHoldOneBack) = sum(afValues);
        afPredResMult(iHoldOneBack) = prod(afValues);
        afPredResMax(iHoldOneBack) = max(afValues);
    end
    
    abValidOut = ~isnan(afPredResAdd);
    afCorrelationSum(k) = corr(afPredResAdd(abValidOut)', afOriginalFiringRate(abValidOut)');
    afCorrelationMult(k) =  corr(afPredResMult(abValidOut)', afOriginalFiringRate(abValidOut)');
    afCorrelationMax(k) = corr(afPredResMax(abValidOut)', afOriginalFiringRate(abValidOut)');
    
end


figure(112);
clf;
subplot(1,3,1);
[afHist,afCent] = hist(afCorrelationSum);
bar(afCent,afHist);
xlabel('Correlation Coefficient');
ylabel('Num Units');
title('Summation Model')
hold on;
plot([mean(afCorrelationSum) mean(afCorrelationSum)],[ 0 max(afHist)],'g','Linewidth',2);
subplot(1,3,2);
[afHist,afCent] = hist(afCorrelationMult);
bar(afCent,afHist);
xlabel('Correlation Coefficient');
ylabel('Num Units');
title('Multiplication Model')
hold on;
plot([mean(afCorrelationMult) mean(afCorrelationMult)],[ 0 max(afHist)],'g','Linewidth',2);
subplot(1,3,3);
[afHist,afCent] = hist(afCorrelationMax);
bar(afCent,afHist);
xlabel('Correlation Coefficient');
ylabel('Num Units');
title('Max Model')
hold on;
plot([mean(afCorrelationMax) mean(afCorrelationMax)],[ 0 max(afHist)],'g','Linewidth',2);


fprintf('Mean Correlation for Sum model: %.2f\n',mean(afCorrelationSum));
fprintf('Mean Correlation for Max model: %.2f\n',mean(afCorrelationMax));
fprintf('Mean Correlation for Mult model: %.2f\n',mean(afCorrelationMult));
 
% Explained Variance ?
% SStot = sum( (afRecordedAvgResponse-mean(afRecordedAvgResponse)).^2);
% SSreg = sum( (afPredictedResponses-mean(afPredictedResponses)).^2);
% SSerr =   sum( (afRecordedAvgResponse-afPredictedResponses').^2);
% fCoefficientOfDetermination = 1 - SSerr/SStot 
% 
% SSE = SSerr
% SST = SStot
% r2 = 1 - SSE/SST % betwen 0 ,, 1
% 
% rPearson = corr(afRecordedAvgResponse', afPredictedResponses); %sum( (afRecordedAvgResponse-mean(afRecordedAvgResponse)) .* (afPredictedResponses-mean(afPredictedResponses))') / ...
%     %    ( (length(afPredictedResponses)-1) * std(afPredictedResponses) * std(afRecordedAvgResponse));
% fFractionOfVarianceUnexplained = 1- rPearson^2;
% fFractionOfVarianceExplained = rPearson^2;

return;




function fnDisplayPairWiseContrastForExampleCell(acUnits)
acPlot = acUnits{1}.m_acSinhaPlots{6};
if ~isfield(acPlot,'m_a2fIntensityResponse')
    return;
end;

fMinY = min(acPlot.m_a2fIntensityResponse(:));
fMaxY = max(acPlot.m_a2fIntensityResponse(:));

figure(10);
clf;
for k=1:11
tightsubplot(2,6,k,'Spacing',0.1);hold on;
afY = acPlot.m_a2fIntensityResponse(k,:);
afX = 1:11;
afSl = acPlot.m_a2iConfidenceIntervalLow(k,:);
afSh = acPlot.m_a2iConfidenceIntervalHigh(k,:);

fill([afX, afX(end:-1:1)],[afSh, afSl(end:-1:1)], [0 0.3 0.3],'Facealpha',0.2,'LineWidth',2);
fill([afX afX(end:-1:1)],[afY, fMinY*ones(size(afY))], [0 0.7 .6]);

set(gca,'xlim',[1 11],'ylim',[fMinY fMaxY]);
%xlabel('
end;


return;


function fnDisplayPairWiseContrast(acUnits)
acPartNames = {'Forehead','L Eye','Nose','R Eye','L Cheek','Up Lip','R Cheek','LL Cheek','Mouth','LR Cheek','Chin'};
a2iPartRatio = nchoosek(1:11,2);


%
iSelectedCell = fnFindExampleCell(acUnits, 'Houdini','26-Jul-2010 09:22:28', 3, 1, 1);
if ~isempty(iSelectedCell)
    strctUnit = acUnits{iSelectedCell};
    a2fAvg = strctUnit.m_acSinhaPlots{2}.m_a2fPartIntensityMean;
    figure(10);clf;
    plot(a2fAvg(1:5,:)','LineWidth',2);hold on;
    plot(a2fAvg(6:11,:)','--','LineWidth',2);
    xlabel('Intensity');
    ylabel('Firing Rate');
    axis([1 11 min(a2fAvg(:))*0.6 max(a2fAvg(:))])
    set(10,'Name','Example Cell : Houdini 29-Jul-2010 10:30:35');
end

iSelectedCell = fnFindExampleCell(acUnits, 'Houdini','29-Jul-2010 10:30:35', 25, 1, 1);
if ~isempty(iSelectedCell)
    strctUnit = acUnits{iSelectedCell};
    a2fAvg = strctUnit.m_acSinhaPlots{2}.m_a2fPartIntensityMean;
    figure(11);clf;
    plot(a2fAvg(1:5,:)','LineWidth',2);hold on;
    plot(a2fAvg(6:11,:)','--','LineWidth',2);
    axis([1 11 min(a2fAvg(:)) max(a2fAvg(:))])
    set(gca,'xticklabel',[])
    ylabel('Firing Rate');
    set(11,'Name','Example Cell : Houdini 26-Jul-2010 09:22:28');

% Display Nose vs R Eye
iPartA = 3;
iPartB = 4;
iPairIndex = find(a2iPartRatio(:,1) == iPartA & a2iPartRatio(:,2) == iPartB | ...
                  a2iPartRatio(:,2) == iPartA & a2iPartRatio(:,1) == iPartB);
              
a3fContrast =strctUnit.m_acSinhaPlots{5}.m_a3fContrast;              
a3fContrast = fnAugmentWithNearestNeighbor(a3fContrast);
a2fTuning = a3fContrast(:,:,iPairIndex);


figure(12);
imagesc(1:11,1:11,a2fTuning);
colorbar 
axis ij
set(gca,'xtickLabel',[],'yticklabel',[]);
set(12,'Name','Nose - R Eye');

iPartA = 2;
iPartB = 4;
iPairIndex = find(a2iPartRatio(:,1) == iPartA & a2iPartRatio(:,2) == iPartB | ...
                  a2iPartRatio(:,2) == iPartA & a2iPartRatio(:,1) == iPartB);
              
a3fContrast = strctUnit.m_acSinhaPlots{5}.m_a3fContrast;              
a3fContrast = fnAugmentWithNearestNeighbor(a3fContrast);
a2fTuning = a3fContrast(:,:,iPairIndex);
figure(13);
imagesc(1:11,1:11,a2fTuning);
colorbar 
axis ij
set(gca,'xtickLabel',[],'yticklabel',[]);
set(13,'Name','R Eye - L Eye');
end
%%
% % iNumUnits = length(acUnits);
% % iNumInt = 11;
% % iNumParts  = 11;
% % 
% % a2fBigPictureTotal = zeros(iNumParts * iNumInt, iNumParts * iNumInt);
% % a2iCount = zeros(iNumParts * iNumInt, iNumParts * iNumInt);
% % for iUnitIter=1:iNumUnits
% %     a2fBigPicture = NaN*ones(iNumParts * iNumInt, iNumParts * iNumInt);
% %     for iRatioIter = 1:size(a2iPartRatio,1)
% %         iPartA = a2iPartRatio(iRatioIter,1);
% %         iPartB = a2iPartRatio(iRatioIter,2);
% %         strNamePartA = acPartNames{iPartA};
% %         strNamePartB = acPartNames{iPartB};
% %         a2fBigPicture( (iPartB-1) * iNumInt + 1:(iPartB) * iNumInt ,...
% %             (iPartA-1) * iNumInt + 1:(iPartA) * iNumInt ) = acUnits{iUnitIter}.m_acSinhaPlots{5}.m_a3fContrast(:,:,iRatioIter);
% %     end
% %     
% %     a2bNotNaN = ~isnan(a2fBigPicture);
% %     a2iCount(a2bNotNaN) = a2iCount(a2bNotNaN) + 1;
% %     
% %     a2fBigPictureNormalized = zeros(iNumParts * iNumInt, iNumParts * iNumInt);
% %     a2fBigPictureNormalized(a2bNotNaN) = a2fBigPicture(a2bNotNaN) / max(a2fBigPicture(:));
% %     
% %     a2fBigPictureTotal(a2bNotNaN) = a2fBigPictureTotal(a2bNotNaN) + a2fBigPictureNormalized(a2bNotNaN);
% % end
% % a2fBigPictureTotalAvg = zeros(iNumParts * iNumInt, iNumParts * iNumInt);
% % a2fBigPictureTotalAvg(a2iCount > 0) = a2fBigPictureTotal(a2iCount > 0) ./ a2iCount(a2iCount > 0);
% % figure(23);
% % clf;
% % imagesc(a2fBigPictureTotalAvg);
% % hold on;
% % for k=0:iNumParts
% %     plot([0, iNumParts * iNumInt + 0.5], 0.5+[(k-1)*iNumInt (k-1)*iNumInt],'w');
% %     plot(0.5+[(k-1)*iNumInt (k-1)*iNumInt],[0, iNumParts * iNumInt + 0.5],'w');
% %     
% % end
% % for k=1:2:10
% %     text(0.5+k,1,num2str(k),'color','w','FontSize',6)
% %     text(1,0.5+k,num2str(k),'color','w','FontSize',6)
% % end
% % axis xy
% % set(gca,'xtick', [0:10] * 11 + 11/2,'xticklabel',acPartNames)
% % set(gca,'ytick', [0:10] * 11 + 11/2,'yticklabel',acPartNames)

return;

function afResponse = fnGenerateCorrectRatioPlot(a2iPerm, strctUnit, iStimulusOffset,a2iCorrectPairALargerB)

% First, show avg response as a function of correct / incorrect number of
% ratios

iNumSinhaRatios = size(a2iCorrectPairALargerB,1);
[abCorrect, aiNumWrongRatios] = fnIsCorrectPerm3(a2iPerm,a2iCorrectPairALargerB);
afResponse = zeros(1,iNumSinhaRatios+1);
for iIter=0:iNumSinhaRatios
    aiInd = find(aiNumWrongRatios == iIter);
    afResponse(iIter+1) =  mean(strctUnit.m_afAvgFirintRate_Stimulus(iStimulusOffset+aiInd));
end


return;

function fnSinhaIncorrectRatioPlotAnalysis(acUnits)
%%
strctTmp = load('SinhaV2.mat');
a2iPerm = strctTmp.a2iAllPerm;

a2iPartRatio = nchoosek(1:11,2);
    
a2iCorrectPairALargerB_Sinha = [...
    1, 2;
    1, 4;
    5, 2;
    7, 4;
    3, 2;
    3, 4;
    3, 6;
    5, 9;
    7, 9;
    8, 9;
    10, 9;
    11, 9];

a2iCorrectPairALargerB_MonkeyBad = zeros(12,2);
a2iCorrectPairALargerB_Monkey = zeros(12,2);
a2iCorrectPairALargerB_Human = zeros(12,2);
strctMonkeyPred = load('D:\Code\Doris\Stimuli_Generating_Code\Sinha\MonkeyInvarianceRatios.mat');
strctShayPred = load('D:\Code\Doris\Stimuli_Generating_Code\Sinha\ShayInvarianceRatios.mat');

for k=1:12
    
    iSelectedPair = strctMonkeyPred.aiInvarianceRatios(k);

    iPartA = a2iPartRatio(iSelectedPair,1);
    iPartB = a2iPartRatio(iSelectedPair,2);
    if strctMonkeyPred.aiSelectivityIndex(iSelectedPair) > 0
        a2iCorrectPairALargerB_Monkey(k,:) = [iPartA,iPartB];
    else
        a2iCorrectPairALargerB_Monkey(k,:) = [iPartB,iPartA];
    end
    
    
    iSelectedPair = strctShayPred.aiInvarianceRatios(56-k);

    iPartA = a2iPartRatio(iSelectedPair,1);
    iPartB = a2iPartRatio(iSelectedPair,2);
    if strctShayPred.aiSelectivityIndex(56-iSelectedPair) > 0
        a2iCorrectPairALargerB_MonkeyBad(k,:) = [iPartA,iPartB];
    else
        a2iCorrectPairALargerB_MonkeyBad(k,:) = [iPartB,iPartA];
    end
        
    
    
    
    iSelectedPair = strctShayPred.aiInvarianceRatios(k);

    iPartA = a2iPartRatio(iSelectedPair,1);
    iPartB = a2iPartRatio(iSelectedPair,2);
    if strctShayPred.aiSelectivityIndex(iSelectedPair) > 0
        a2iCorrectPairALargerB_Human(k,:) = [iPartA,iPartB];
    else
        a2iCorrectPairALargerB_Human(k,:) = [iPartB,iPartA];
    end    
end    



iNumUnits = length(acUnits);
a2fTuning_Sinha = zeros(iNumUnits,13);
a2fTuning_Human = zeros(iNumUnits,13);
a2fTuning_Monkey = zeros(iNumUnits,13);
a2fTuning_Bad = zeros(iNumUnits,13);
for iUnitIter=1:iNumUnits
    strctUnit = acUnits{iUnitIter};
    
    afProfile_Sinha = fnGenerateCorrectRatioPlot(a2iPerm, strctUnit, 96,a2iCorrectPairALargerB_Sinha);
    afProfile_Human = fnGenerateCorrectRatioPlot(a2iPerm, strctUnit, 96,a2iCorrectPairALargerB_Human);
    afProfile_Monkey = fnGenerateCorrectRatioPlot(a2iPerm, strctUnit, 96,a2iCorrectPairALargerB_Monkey);
    afProfile_Bad = fnGenerateCorrectRatioPlot(a2iPerm, strctUnit, 96,a2iCorrectPairALargerB_MonkeyBad);
    a2fTuning_Sinha(iUnitIter,:) = afProfile_Sinha / max(afProfile_Sinha);
    a2fTuning_Human(iUnitIter,:) = afProfile_Human / max(afProfile_Human);
    a2fTuning_Monkey(iUnitIter,:) = afProfile_Monkey / max(afProfile_Monkey);
    a2fTuning_Bad(iUnitIter,:) = afProfile_Bad / max(afProfile_Bad);
end

afX = 0:12;
afY_Sinha = mean(a2fTuning_Sinha,1);
afS_Sinha = std(a2fTuning_Sinha,1)/sqrt(iNumUnits);
afY_Human = mean(a2fTuning_Human,1);
afS_Human = std(a2fTuning_Human,1)/sqrt(iNumUnits);
afY_Monkey = mean(a2fTuning_Monkey,1);
afS_Monkey = std(a2fTuning_Monkey,1)/sqrt(iNumUnits);

afY_Bad = mean(a2fTuning_Bad,1);
afS_Bad = std(a2fTuning_Bad,1)/sqrt(iNumUnits);

figure(8);
clf;hold on;
ahHandles(1) = fill([afX, afX(end:-1:1)],[afY_Sinha+afS_Sinha, afY_Sinha(end:-1:1)-afS_Sinha(end:-1:1)], [0.7 0 0],'FaceAlpha',0.5);
plot(afX,afY_Sinha, 'color', [0.3 0 0],'LineWidth',2);

ahHandles(2) = fill([afX, afX(end:-1:1)],[afY_Human+afS_Human, afY_Human(end:-1:1)-afS_Human(end:-1:1)], [0 0.7 0],'FaceAlpha',0.5);
plot(afX,afY_Human, 'color', [0 0.3 0],'LineWidth',2);

ahHandles(3) = fill([afX, afX(end:-1:1)],[afY_Monkey+afS_Monkey, afY_Monkey(end:-1:1)-afS_Monkey(end:-1:1)], [0 0 0.7],'FaceAlpha',0.5);
plot(afX,afY_Monkey, 'color', [0 0 0.3],'LineWidth',2);

ahHandles(4) = fill([afX(~isnan(afY_Bad)), fliplr(afX(~isnan(afY_Bad)))],[afY_Bad(~isnan(afY_Bad))+afS_Bad(~isnan(afY_Bad)), fliplr(afY_Bad(~isnan(afY_Bad))-afS_Bad(~isnan(afY_Bad)))],[0 0.7 0.7],'FaceAlpha',0.5);
plot(afX,afY_Bad, 'color', [0 0.3 0.3],'LineWidth',2);

set(gca,'xtick',0:12);
grid on
xlabel('Number of Incorrect Polarity Pairs');
ylabel('Normalized Firing Rate');

legend(ahHandles,{'Pred Sinha','Pred Human','Pred Monkey','Pred Worse 12'},'Location','NorthEastOutside');
%title(sprintf('n = %d',iNumUnits));
grid on
%%
return;

function a3bSignificant = fnSignificantContrastRuning(acUnits)
iNumUnits = length(acUnits);
iNumParts = 11;
iNumIntensities = 11;

a3bSignificant = zeros(iNumParts,iNumIntensities, iNumUnits);
for iUnitIter=1:iNumUnits
    a3bSignificant(:,:,iUnitIter) = acUnits{iUnitIter}.m_acSinhaPlots{5}.m_a2bSignificant;
end
acPartNames = {'Forehead','L Eye','Nose','R Eye','L Cheek','Up Lip','R Cheek','LL Cheek','Mouth','LR Cheek','Chin'};
figure(14);
barh( max(sum(a3bSignificant,3) ,[],2));
set(gca,'ytick',1:11,'yticklabel',acPartNames);
 xlabel('Num significant cells tuned for contrast in this part');
 grid on
return;


function fnDisplayPopulationContrastTuningCurve(acUnits)
iNumUnits = length(acUnits);
a2fAvg = zeros(11,11);
for iUnitIter=1:iNumUnits
    M = acUnits{iUnitIter}.m_acSinhaPlots{2}.m_a2fPartIntensityMean;
    Mn = (M-min(M(:))) / (max(M(:))-min(M(:)));
    a2fAvg = a2fAvg + Mn;
end
 a2fAvg = a2fAvg / iNumUnits;
 figure(9); clf;
plot(a2fAvg(1:5,:)','LineWidth',2);hold on;
plot(a2fAvg(6:11,:)','--','LineWidth',2);
xlabel('Intensity');
ylabel('Normalized Firing Rate');
axis([1 11 0 1]);
acPartNames = {'Forehead','L Eye','Nose','R Eye','L Cheek','Up Lip','R Cheek','LL Cheek','Mouth','LR Cheek','Chin'};
legend(acPartNames,'Location','NorthEastOutside');
axis([1 11 0.1 0.7])
set(gca,'xtick',1:11)

return;


function fnDisplayExampleCellContrastTuningCurve(strctUnit)

figure(8); clf;
plot(strctUnit.m_acSinhaPlots{2}.m_a2fPartIntensityMean(1:5,:)','LineWidth',2);hold on;
plot(strctUnit.m_acSinhaPlots{2}.m_a2fPartIntensityMean(6:11,:)','--','LineWidth',2);
xlabel('Intensity');
ylabel('Avg. Firing Rate');
axis([1 11 min(strctUnit.m_acSinhaPlots{2}.m_a2fPartIntensityMean(:))-eps eps+max(strctUnit.m_acSinhaPlots{2}.m_a2fPartIntensityMean(:))]);
acPartNames = {'Forehead','L Eye','Nose','R Eye','L Cheek','Up Lip','R Cheek','LL Cheek','Mouth','LR Cheek','Chin'};
legend(acPartNames,'Location','NorthEastOutside');
grid on
return;


function [a2iSigRatio, acNames, aiSinhaRatio, abASmallerB, aiNumSignificant,a2iSigPair] = fnCalcSigRatiosSinha(acUnits, fPValue)
%a2iSigRatio is a 55 x 2
% where, :,1 is the number of cells tuned for the positive polarity
% and :,2 is the number of cells tuned for the negative polarity

a2iPartRatio = nchoosek(1:11,2);

if strcmp(acUnits{1}.m_strImageListDescrip,'Sinha_Profile')
    strctTmp = load('CorrectRatiosCBCL');
    a2iCorrectEdges = strctTmp.a2iCorrectPairsALargerB(:,[2,1]);
else
    
a2iCorrectEdges = [...
    2, 1;
    4, 1;
    2, 5;
    4, 7;
    2, 3;
    4, 3;
    6, 3;
    9, 5;
    9, 7;
    9, 8;
    9, 10;
    9, 11];
end

iNumRatios = size(a2iCorrectEdges,1);
aiSinhaRatio = zeros(1,iNumRatios);
abASmallerB = zeros(1,iNumRatios) >0;
for k=1:iNumRatios
aiSinhaRatio(k) = find(a2iPartRatio(:,1) == a2iCorrectEdges(k,1) & a2iPartRatio(:,2) == a2iCorrectEdges(k,2) | ...
     a2iPartRatio(:,1) == a2iCorrectEdges(k,2) & a2iPartRatio(:,2) == a2iCorrectEdges(k,1));
 abASmallerB(k) = all(a2iCorrectEdges(k,:) == a2iPartRatio(aiSinhaRatio(k) ,:));
end

iNumUnits = length(acUnits);
aiNumSignificant = zeros(1,iNumUnits);
aiPos = zeros(1,55);
aiNeg = zeros(1,55);
a2iSigPair = zeros(iNumUnits,55)>0;
for iUnitIter=1:iNumUnits
   strctUnit = acUnits{iUnitIter};
   [a2fFiring,afPValue,acNames]= fnGetAllRatios(strctUnit);
   aiSig = find(afPValue <= fPValue);
   a2iSigPair(iUnitIter,:) = afPValue <= fPValue;
   aiNumSignificant(iUnitIter) = length(aiSig);
   abPos = a2fFiring(aiSig,1) > a2fFiring(aiSig,2);
   abNeg = a2fFiring(aiSig,1) < a2fFiring(aiSig,2);   
   aiPos( aiSig(abPos)) =    aiPos( aiSig(abPos)) + 1;
   aiNeg( aiSig(abNeg)) =    aiNeg( aiSig(abNeg)) + 1;   
end
a2iSigRatio = [aiPos;aiNeg]';

return;


function [a2fFiring,afPValue, acNames]= fnGetSinhaRatios(strctUnit)
a2iPartRatio = nchoosek(1:11,2);
a2iCorrectEdges = [...
    2, 1;
    4, 1;
    2, 5;
    4, 7;
    2, 3;
    4, 3;
    6, 3;
    9, 5;
    9, 7;
    9, 8;
    9, 10;
    9, 11];

aiSinhaRatio = zeros(1,12);
for k=1:12
aiSinhaRatio(k) = find(a2iPartRatio(:,1) == a2iCorrectEdges(k,1) & a2iPartRatio(:,2) == a2iCorrectEdges(k,2) | ...
     a2iPartRatio(:,1) == a2iCorrectEdges(k,2) & a2iPartRatio(:,2) == a2iCorrectEdges(k,1));
end

acPartNames = {'Forehead','Left Eye','Nose','Right Eye','Left Cheek','Upper Lip','Right Cheek','Lower Left Cheek','Mouth','Lower Right Cheek','Chin'};

a2fFiring = [strctUnit.m_afAvgFiringRateCategory(aiSinhaRatio+6)',strctUnit.m_afAvgFiringRateCategory(aiSinhaRatio+6+55)'];
afPValue = zeros(1,12);
acNames = cell(1,12);
for k=1:12
    iPartA = a2iCorrectEdges(k,1);
    iPartB = a2iCorrectEdges(k,2);
    afPValue(k)=strctUnit.m_a2fPValueCat(aiSinhaRatio(k)+6, aiSinhaRatio(k)+6+55);
    acNames{k} = [acPartNames{iPartA},'-',acPartNames{iPartB}];
end
return;



function [a2fFiring,afPValue, acNames]= fnGetAllRatios(strctUnit)
a2iPartRatio = nchoosek(1:11,2);
acPartNames = {'Forehead','Left Eye','Nose','Right Eye','Left Cheek','Upper Lip','Right Cheek','Lower Left Cheek','Mouth','Lower Right Cheek','Chin'};
aiAllPairs = 1:55;
a2fFiring = [strctUnit.m_afAvgFiringRateCategory(aiAllPairs+6)',strctUnit.m_afAvgFiringRateCategory(aiAllPairs+6+55)'];
afPValue = zeros(1,55);
acNames = cell(1,55);
for k=1:55
    iPartA = a2iPartRatio(k,1);
    iPartB = a2iPartRatio(k,2);
    afPValue(k)=strctUnit.m_a2fPValueCat((k)+6, (k)+6+55);
    acNames{k} = [acPartNames{iPartA},'-',acPartNames{iPartB}];
end
return;

function aiSelectedUnits = fnFindUnitsWithStandardParam(acUnits)
iNumUnits  = length(acUnits);
afMaxRotation = zeros(1,iNumUnits);
afSize = zeros(1,iNumUnits);
abSinhaExperiment = zeros(1,iNumUnits)>0;
for k=1:iNumUnits 
    abSinhaExperiment(k) = strcmpi(acUnits{k}.m_strParadigmDesc,'Sinha_v2_FOB') || strcmpi(acUnits{k}.m_strParadigmDesc,'Sinha_Edges') || ...
        strcmpi(acUnits{k}.m_strParadigmDesc,'Sinha_v2_FOB_LP_32') || strcmpi(acUnits{k}.m_strParadigmDesc,'Sinha_v2_FOB_LP_16');
    afRot = acUnits{k}.m_strctStimulusParams.m_afRotationAngle;
    afStimSize = acUnits{k}.m_strctStimulusParams.m_afStimulusSizePix;
    if isempty(afStimSize)
        afSize(k) = 128;
    else
        if all(afStimSize == 128)
            afSize(k) = 128;
        else
            afSize(k) = max(setdiff(afStimSize, 128));
        end
    end
    
    if isempty(afRot)
         afMaxRotation(k) = 0;
    else
        afMaxRotation(k) = max(abs(afRot));
    end
end

aiSelectedUnits = find(afMaxRotation == 0 & abSinhaExperiment & afSize == 128);
return;


function [afFaceSelectivityIndex]  = fnComputeFaceSelecitivyIndex(acUnits)
iNumUnits = length(acUnits);
afFaceSelectivityIndex = zeros(1,iNumUnits);
afRatio = zeros(1,iNumUnits);

for iUnitIter=1:iNumUnits
    if ~isfield(acUnits{iUnitIter},'m_acSinhaPlots')
        strctUnit = acUnits{iUnitIter};
        fMaximalResponseForSinha = max(strctUnit.m_afAvgStimulusResponseMinusBaseline(97:end)) / max(strctUnit.m_afAvgStimulusResponseMinusBaseline);
        fMaximalResponseForFace = max(strctUnit.m_afAvgStimulusResponseMinusBaseline(1:16)) / max(strctUnit.m_afAvgStimulusResponseMinusBaseline);
        fFaceRes = fnMyMean(strctUnit.m_afAvgStimulusResponseMinusBaseline(1:16));
        fNonFaceRes = fnMyMean(strctUnit.m_afAvgStimulusResponseMinusBaseline(17:96));
        
        fFaceRes1 = fnMyMean(strctUnit.m_afAvgFirintRate_Stimulus(1:16));
        fNonFaceRes1 = fnMyMean(strctUnit.m_afAvgFirintRate_Stimulus(17:96));
        
        acUnits{iUnitIter}.m_acSinhaPlots{1}.m_fFaceSelectivityIndex =  (fFaceRes - fNonFaceRes) / (fFaceRes + fNonFaceRes+eps);
        acUnits{iUnitIter}.m_acSinhaPlots{1}.m_fFaceSelectivityIndexBounded =  (fFaceRes1 - fNonFaceRes1) / (fFaceRes1 + fNonFaceRes1+eps);
        acUnits{iUnitIter}.m_acSinhaPlots{1}.m_fRatio = fMaximalResponseForSinha/fMaximalResponseForFace;
        
    end
    afFaceSelectivityIndex(iUnitIter) = acUnits{iUnitIter}.m_acSinhaPlots{1}.m_fFaceSelectivityIndexBounded;
    afFaceSelectivityIndexUnBounded(iUnitIter) = acUnits{iUnitIter}.m_acSinhaPlots{1}.m_fFaceSelectivityIndex;
    afRatio(iUnitIter) = acUnits{iUnitIter}.m_acSinhaPlots{1}.m_fRatio;
end
% sum(afFaceSelectivityIndexUnBounded > 0.3 | afFaceSelectivityIndexUnBounded < -0.3) / length(afFaceSelectivityIndexUnBounded) * 100
% 
% sum(afFaceSelectivityIndex < -0.3)
% sum(afFaceSelectivityIndex > 0.3) / length(afFaceSelectivityIndex) * 100

abFaceUnits = afFaceSelectivityIndex >= 0.3;
afRatio = afRatio(abFaceUnits & ~isinf(afRatio));
[afHist,afCent]=hist(afRatio,0:0.1:2);
hFig=figure(1);clf;
bar(afCent,afHist,0.7);
% ylabel('Number of units');
% xlabel('Ratio between max PIP response to max real face response');
axis([0 2.1 0 max(afHist)*1.1])
set(gcf,'Position', [761   945   479   153]);

fprintf('The ratio of maximal PIP response to real face response was %.2f +- %.2f\n',mean(afRatio),std(afRatio));
%saveas(hFig,'D:\Publications\Sinha\MatFigures\Figure1.fig');


afdPrime = zeros(1,iNumUnits);
afPerecentCorrect= zeros(1,iNumUnits);
for k=1:iNumUnits
    strctUnit = acUnits{k};
    
    afResPos =strctUnit.m_afAvgStimulusResponseMinusBaseline(1:16);
    afResPos = afResPos(~isnan(afResPos));
    
    afResNeg =strctUnit.m_afAvgStimulusResponseMinusBaseline(17:96);
    afResNeg = afResNeg(~isnan(afResNeg));
    
    fDeno = sqrt( (std(afResPos).^2+std(afResNeg).^2)/2);
    afdPrime(k) = abs(mean(afResPos) - mean(afResNeg)) / (fDeno+eps);
    afPerecentCorrect(k) = normcdf(afdPrime(k) / sqrt(2)) * 100;
end


return;

function  [aiPeriStimulusMS, a2fAvgFiringCat,acAvgFiringNames] = fnComputePeriAvg(acUnits)
iNumUnits = length(acUnits);
a2fAvgFiringCat = zeros(8, 701);%size(acUnits{aiFOB(1)}.m_a2fAvgFirintRate_Category));
acAvgFiringNames = {'Faces','Bodies','Fruits','Gadgets','Hands','Scrambled','Sinha','Pink Noise'};
aiPeriStimulusMS= acUnits{1}.m_aiPeriStimulusRangeMS;
for iUnitIter=1:iNumUnits
    strctUnit = acUnits{iUnitIter};
    % Re-estimate firing rates....
    a2fAvgFirintRate_Category_Smooth = strctUnit.m_a2fAvgFirintRate_Category / max(strctUnit.m_a2fAvgFirintRate_Category(:));
    aiSinha = find(~ismember(strctUnit.m_acCatNames,    {'Faces','Bodies',    'Fruits',    'Gadgets',    'Hands',    'Scrambled','Uniform','Background'}));
    iPinkNoise= find(ismember(strctUnit.m_acCatNames,   'Background'));
     a2fAvgFiringCat(1:6,:) = ( (iUnitIter-1) * a2fAvgFiringCat(1:6,:) + a2fAvgFirintRate_Category_Smooth(1:6,:)) / iUnitIter;
     a2fAvgFiringCat(7,:) = ( (iUnitIter-1) * a2fAvgFiringCat(7,:) + mean(a2fAvgFirintRate_Category_Smooth(aiSinha,:),1)) / iUnitIter;
     a2fAvgFiringCat(8,:) = ( (iUnitIter-1) * a2fAvgFiringCat(8,:) +  a2fAvgFirintRate_Category_Smooth(iPinkNoise,:)) / iUnitIter;    
end
return;


function fnPlotSigmoidsHistograms(acUnits)
%%
iNumUnits = length(acUnits);
afX = -10:10;
N = length(afX);
strctTmp = load('SinhaV2.mat');
a2iPerm = double(strctTmp.a2iAllPerm);

a2iPartRatio = nchoosek(1:11,2);
iNumPairs = size(a2iPartRatio,1);
a3fTuningCurves = zeros(iNumUnits,iNumPairs, N);
a3fTuningCurvesStdErr = zeros(iNumUnits,iNumPairs, N);
a3fTuningCurvesFitCorr = zeros(iNumUnits,iNumPairs );
a4fTuningCurvesParams = zeros(iNumUnits,iNumPairs, 4);
a2bSignificant = zeros(iNumUnits,iNumPairs) > 0;
f = @(p,x) p(1) + p(2) ./ (1 + exp(-(x-p(3))/p(4)));
warning off
for iUnitIter=1:iNumUnits
    fprintf('Unit Iter %d / %d \n',iUnitIter,iNumUnits);
    for iPairIter=1:iNumPairs
        iPartA = a2iPartRatio(iPairIter,1);
        iPartB = a2iPartRatio(iPairIter,2);

        a2bSignificant(iUnitIter, iPairIter) = acUnits{iUnitIter}.m_acSinhaPlots{3}.m_afPolarDiffPvalue(iPairIter) < 1e-5;
        if a2bSignificant(iUnitIter, iPairIter)
            afAvgFiringRate = NaN*ones(1,N);
            afAvgFiringRateStdErr= NaN*ones(1,N);
            afDiff = a2iPerm(:,iPartA) - a2iPerm(:,iPartB);
            aiCount = zeros(1,N);
            for k=1:N
                aiInd = find(afDiff == afX(k));
                aiCount(k)=length(aiInd);
                if ~isempty(aiInd)
                    [afAvgFiringRate(k),X,afAvgFiringRateStdErr(k)]= fnMyMean(acUnits{iUnitIter}.m_afAvgFirintRate_Stimulus(96+aiInd));
                end
            end
            
            a3fTuningCurvesStdErr(iUnitIter,iPairIter,:) = afAvgFiringRateStdErr;
            a3fTuningCurves(iUnitIter,iPairIter,:) = afAvgFiringRate;
            
            
            p1 = min(afAvgFiringRate);
            p2 = max(afAvgFiringRate)-p1;
            p3 = 0;
            p4 = 3;
            pi = [p1,p2,p3,p4];
            opt=statset('MaxIter',100,'robust','on');
            ppos = nlinfit(afX,afAvgFiringRate,f,pi,opt);
            fpos = f(ppos,afX);
            pi(4) = -3;
            pneg = nlinfit(afX,afAvgFiringRate,f,pi,opt);
            fneg = f(pneg,afX);
            abNonNaNsPos = ~isnan(fpos) & ~isnan(afAvgFiringRate);
            abNonNaNsNeg = ~isnan(fneg) & ~isnan(afAvgFiringRate);
            corpos = corr(fpos(abNonNaNsPos)', afAvgFiringRate(abNonNaNsPos)');
            corneg = corr(fneg(abNonNaNsNeg)', afAvgFiringRate(abNonNaNsNeg)');
            if corneg > corpos
                a4fTuningCurvesParams(iUnitIter,iPairIter, :) = pneg;
                a3fTuningCurvesFitCorr(iUnitIter,iPairIter) = corneg;
            else
                a4fTuningCurvesParams(iUnitIter,iPairIter, :) = ppos;
                a3fTuningCurvesFitCorr(iUnitIter,iPairIter) = corpos;
            end
        end
    end
end
warning on
%%
[T,aiMostSignificant]=sort(sum(a2bSignificant,1),'descend')
 iDisplay = 5;
iSelectedCell2 = fnFindExampleCell(acUnits, 'Houdini','22-Jul-2010 09:34:34', 14, 1, 1);
figure(302);
clf;
for iIter=1:iDisplay 
% Plot curves for four pairs
iSelectedPair = aiMostSignificant(iIter);
acPartNames = {'Forehead','L Eye','Nose','R Eye','L Cheek','Up Lip','R Cheek','LL Cheek','Mouth','LR Cheek','Chin'};

iPartA = a2iPartRatio(iSelectedPair,1);
iPartB = a2iPartRatio(iSelectedPair,2);
strPartA = acPartNames{iPartA};
strPartB = acPartNames{iPartB};
subplot(1,iDisplay,iIter)
hold on;
afY = squeeze(a3fTuningCurves(iSelectedCell2,iSelectedPair,:));
afYFit = f(a4fTuningCurvesParams(iSelectedCell2,iSelectedPair,:),afX);
plot(afX, afY,'bo','LineWidth',2,'MarkerSize',5);
plot(afX,afYFit,'r','LineWidth',2);
errorbar(afX,afY ,a3fTuningCurvesStdErr(iSelectedCell2,iSelectedPair,:),'k');
axis([-11 11 0 20]);
set(gca,'xtick',[-10 -5 0 5 10]);
str1 = '$$\begin{array}{l} {r^2} =';
str2 = '\\ \alpha';
str3 = '\end{array}$$';
fprintf('%.2f %.2f\n',a3fTuningCurvesFitCorr(iSelectedCell2,iSelectedPair).^2,a4fTuningCurvesParams(iSelectedCell2,iSelectedPair,4));
text(-9,2,sprintf('r^2=%.2f, s=%.2f',a3fTuningCurvesFitCorr(iSelectedCell2,iSelectedPair).^2,...
    a4fTuningCurvesParams(iSelectedCell2,iSelectedPair,4)),'fontweight','normal','backgroundcolor','w','fontname','Calibri (Body)');
% text('Interpreter','latex',...
%  'String',sprintf('%s %.2f %s = %.2f %s',str1,a3fTuningCurvesFitCorr(iSelectedCell2,iSelectedPair).^2,str2, a4fTuningCurvesParams(iSelectedCell2,iSelectedPair,4),str3),...
%  'Position',[-1 17 ],...
%  'FontSize',11)
grid on;
box on;
%xlabel('Intensity Diff');
%xlabel(sprintf('%s-%s',strPartA,strPartB));
end
set(gcf,'position',[ 243         453        1060         200]);
%%

figure(303);
clf;
for iIter=1:iDisplay 
% Plot curves for four pairs
iSelectedPair = aiMostSignificant(iIter);
acPartNames = {'Forehead','L Eye','Nose','R Eye','L Cheek','Up Lip','R Cheek','LL Cheek','Mouth','LR Cheek','Chin'};

iPartA = a2iPartRatio(iSelectedPair,1);
iPartB = a2iPartRatio(iSelectedPair,2);
strPartA = acPartNames{iPartA};
strPartB = acPartNames{iPartB};
aiSigUnits = a2bSignificant(:,iSelectedPair)
subplot(1,iDisplay,iIter)
afCorr = a3fTuningCurvesFitCorr(aiSigUnits,iSelectedPair).^2;
abGoodCorr = ~isnan(afCorr) & a3fTuningCurvesFitCorr(aiSigUnits,iSelectedPair) >0;
afCorrFinal = afCorr(abGoodCorr);
afTmp(iIter)=mean(afCorrFinal)
afCent = 0:0.1:1;
afCount = histc(afCorrFinal,afCent);
bar(afCent,afCount)
axis([-0.1 1.1 0 40]);
xlabel('r^2');
end
set(gcf,'position',[ 243         453        1060         200]);
%%
figure(304);
clf;
for iIter=1:iDisplay 
% Plot curves for fpairs
iSelectedPair = aiMostSignificant(iIter);
acPartNames = {'Forehead','L Eye','Nose','R Eye','L Cheek','Up Lip','R Cheek','LL Cheek','Mouth','LR Cheek','Chin'};

iPartA = a2iPartRatio(iSelectedPair,1);
iPartB = a2iPartRatio(iSelectedPair,2);
strPartA = acPartNames{iPartA};
strPartB = acPartNames{iPartB};
aiSigUnits = a2bSignificant(:,iSelectedPair)
subplot(1,iDisplay,iIter)
afCorr = a3fTuningCurvesFitCorr(aiSigUnits,iSelectedPair).^2;
afAlpha = a4fTuningCurvesParams(aiSigUnits,iSelectedPair,4);
abGoodCorr = ~isnan(afCorr) & a3fTuningCurvesFitCorr(aiSigUnits,iSelectedPair) >0;
afAlphaFinal = abs(afAlpha(abGoodCorr));
afTmp2(iIter) = sum(afAlphaFinal >1)/length(afAlphaFinal)*100
afCent = 0:0.2:5;
afCount = hist(afAlphaFinal,afCent);
bar(afCent,afCount,'LineStyle','none');
axis([-0.5 5.1 0 35]);
set(gca,'xtick',0:5);
xlabel('|s| ');
grid off
box on
end
set(gcf,'position',[ 243         453        1060         200]);

%%
% aiSig = find(a2bSignificant(:,iSelectedPair));
% X=squeeze(a3fTuningCurves(aiSig,iSelectedPair,:));
% abOK = a3fTuningCurvesFitCorr(aiSig,iSelectedPair) > 0.3;
% a4fTuningCurvesParams(aiSig(abOK),iSelectedPair,4)
% 

iSelectedPair = 11;
iPartA = a2iPartRatio(iSelectedPair,1);
iPartB = a2iPartRatio(iSelectedPair,2);
strPartA = acPartNames{iPartA};
strPartB = acPartNames{iPartB};
aiSigUnits = find(a2bSignificant(:,iSelectedPair));
afCorr = a3fTuningCurvesFitCorr(aiSigUnits,iSelectedPair).^2;
afAlpha = a4fTuningCurvesParams(aiSigUnits,iSelectedPair,4);
[afSortedAlpha,aiSortInd]=sort(abs(afAlpha),'ascend');
afSortedAlpha([5,(round(length(aiSortInd)/2)),length(aiSortInd)])
aiUnits = [aiSigUnits(aiSortInd(5)),aiSigUnits(aiSortInd(round(length(aiSortInd)/2))),aiSigUnits(aiSortInd(end))];
figure(305);
clf;
hold on;
for k=1:length(aiUnits)
    subplot(1,length(aiUnits),k);
    afAvgFiringRate=squeeze(a3fTuningCurves(aiUnits(k),iSelectedPair,:));
    afY = f(a4fTuningCurvesParams(aiUnits(k),iSelectedPair, :),afX);
    plot(afX,afAvgFiringRate,'b.',afX,afY,'r');
    axis([-10 10 min(afAvgFiringRate)-2,max(afAvgFiringRate)+2])
end    




function [afFaceSelectivityIndex]  = fnComputeFaceSelecitivyIndex2(acUnits)
iNumUnits = length(acUnits);
afFaceSelectivityIndex = zeros(1,iNumUnits);
afRatio = zeros(1,iNumUnits);
aiHowMany= zeros(1,iNumUnits);
for iUnitIter=1:iNumUnits
        strctUnit = acUnits{iUnitIter};
        
        fMaximalResponseForSinha = max(strctUnit.m_afAvgFirintRate_Stimulus(97:529)) / max(strctUnit.m_afAvgFirintRate_Stimulus);
        fMaximalResponseForFace = max(strctUnit.m_afAvgFirintRate_Stimulus(1:16)) / max(strctUnit.m_afAvgFirintRate_Stimulus);
        fMinimalResponseForSinha = min(strctUnit.m_afAvgFirintRate_Stimulus(97:529)) / max(strctUnit.m_afAvgFirintRate_Stimulus);
        aiHowMany(iUnitIter) = sum(strctUnit.m_afAvgFirintRate_Stimulus(97:529)>max(strctUnit.m_afAvgFirintRate_Stimulus(1:16)));
        a2fNormRes(iUnitIter,:) = strctUnit.m_afAvgFirintRate_Stimulus ./ max(strctUnit.m_afAvgFirintRate_Stimulus);
        afMaximalResponseForSinha(iUnitIter) =fMaximalResponseForSinha;
        afMinimalResponseForSinha(iUnitIter) =fMinimalResponseForSinha;
        afMaximalResponseForFace(iUnitIter) =fMaximalResponseForFace;
        
        fFaceRes = fnMyMean(strctUnit.m_afAvgFirintRate_Stimulus(1:16));
        fNonFaceRes = fnMyMean(strctUnit.m_afAvgFirintRate_Stimulus(17:96));
        
        fFaceRes1 = fnMyMean(strctUnit.m_afAvgFirintRate_Stimulus(1:16));
        fNonFaceRes1 = fnMyMean(strctUnit.m_afAvgFirintRate_Stimulus(17:96));
        
        acUnits{iUnitIter}.m_acSinhaPlots{1}.m_fFaceSelectivityIndex =  (fFaceRes - fNonFaceRes) / (fFaceRes + fNonFaceRes+eps);
        acUnits{iUnitIter}.m_acSinhaPlots{1}.m_fFaceSelectivityIndexBounded =  (fFaceRes1 - fNonFaceRes1) / (fFaceRes1 + fNonFaceRes1+eps);
        acUnits{iUnitIter}.m_acSinhaPlots{1}.m_fRatio = fMaximalResponseForSinha/fMaximalResponseForFace;
     afFaceSelectivityIndex(iUnitIter) = acUnits{iUnitIter}.m_acSinhaPlots{1}.m_fFaceSelectivityIndexBounded;
    afRatio(iUnitIter) = acUnits{iUnitIter}.m_acSinhaPlots{1}.m_fRatio;
end
% % aiFaceUnits =find(abFaceUnits);
%figure;bar([afMaximalResponseForSinha-afMinimalResponseForSinha;afMaximalResponseForFace]');
%sum((afMaximalResponseForSinha(abFaceUnits) - afMinimalResponseForSinha(abFaceUnits)) > afMaximalResponseForFace(abFaceUnits))
% 
% aiHowMany(abFaceUnits)
% sum(afMaximalResponseForSinha(abFaceUnits)> afMaximalResponseForFace(abFaceUnits))
% sum(afFaceSelectivityIndexUnBounded > 0.3 | afFaceSelectivityIndexUnBounded < -0.3) / length(afFaceSelectivityIndexUnBounded) * 100
% 
% sum(afFaceSelectivityIndex < -0.3)
% sum(afFaceSelectivityIndex > 0.3) / length(afFaceSelectivityIndex) * 100

abFaceUnits = afFaceSelectivityIndex >= 0.3;
afRatio = afRatio(abFaceUnits & ~isinf(afRatio));
[afHist,afCent]=hist(afRatio,0:0.1:2);
hFig=figure(1);clf;
bar(afCent,afHist,0.7);
ylabel('Number of units');
xlabel('Ratio between max PIP response to max real face response');
axis([0 2.1 0 max(afHist)*1.1])
set(gcf,'Position', [761   945   479   153]);
fprintf('The ratio of maximal PIP response to real face response was %.2f +- %.2f\n',mean(afRatio),std(afRatio));
%saveas(hFig,'D:\Publications\Sinha\MatFigures\Figure1.fig');


afdPrime = zeros(1,iNumUnits);
afPerecentCorrect= zeros(1,iNumUnits);
for k=1:iNumUnits
    strctUnit = acUnits{k};
    
    afResPos =strctUnit.m_afAvgStimulusResponseMinusBaseline(1:16);
    afResPos = afResPos(~isnan(afResPos));
    
    afResNeg =strctUnit.m_afAvgStimulusResponseMinusBaseline(17:96);
    afResNeg = afResNeg(~isnan(afResNeg));
    
    fDeno = sqrt( (std(afResPos).^2+std(afResNeg).^2)/2);
    afdPrime(k) = abs(mean(afResPos) - mean(afResNeg)) / (fDeno+eps);
    afPerecentCorrect(k) = normcdf(afdPrime(k) / sqrt(2)) * 100;
end


return;