function fnFinalScriptToGenerateFiguresForNeuronPaper()
%% Final script to generate figures for the neuron paper.

global g_strctTmp1 g_strctTmp2
if isempty(g_strctTmp1)
    g_strctTmp1 = load('D:\Data\Doris\Data For Publications\Sinha\Final Data For Revised Neuron Paper\Rocco_and_Houdini.mat');
end
if isempty(g_strctTmp2)
        g_strctTmp2 = load('D:\Data\Doris\Data For Publications\Sinha\Final Data For Revised Neuron Paper\Julien.mat');
end

    [abFaceSelective1, abFaceSelective2,afdPrimeBaselineSub]=fnPlotFigure1(false);
  
     fnFigure8B(abFaceSelective2);
     fnPlotFigure2(abFaceSelective1, abFaceSelective2,afdPrimeBaselineSub);
     
fnFigure8A();

    [a2fTuning, acSubjects]=fnPlotFigure3and4(abFaceSelective1, abFaceSelective2);

fnPlotFigure5(abFaceSelective1, abFaceSelective2,a2fTuning, acSubjects)

    
       


fnFigure7C();

 fnFigure7A();
 
 fnFigure7B();
 
fnPlotFigure6();


return;


function fnFigureSup7()
astrctFiles = dir('D:\Data\Doris\Stimuli\Sinha_Exp\SinhaParts\sinha_parts*');
figure(700);clf;
for k=1:127
    tightsubplot(10,13,k);
    I=imread(['D:\Data\Doris\Stimuli\Sinha_Exp\SinhaParts\',astrctFiles(k).name]);
    imshow(I);
end;
astrctFiles = dir('D:\Data\Doris\Stimuli\Sinha_Exp\SinhaPartsInv\inv_sinha_parts*');
figure(701);clf;
for k=1:127
    tightsubplot(10,13,k);
    I=imread(['D:\Data\Doris\Stimuli\Sinha_Exp\SinhaPartsInv\',astrctFiles(k).name]);
    imshow(I);
end;
astrctFiles = dir('D:\Data\Doris\Stimuli\Cartoon_And_Tuning\im1\*bmp');
figure(702);clf;
for k=1:127
    tightsubplot(10,13,k);
    I=imread(['D:\Data\Doris\Stimuli\Cartoon_And_Tuning\im1\',astrctFiles(k).name]);
    imshow(I);
end;

function fnFigure8A()
load('D:\Data\Doris\Data For Publications\Sinha\Final Data For Revised Neuron Paper\HairComparison');
iNumUnits = length(acUnits);


% 8 parts sinha parts ANOVA analysis
acFactorNames = {'Forehead','Hair','Bounding Ellipse','Irises','Eyes','EyeBrow','Nose','Mouth'};
iNumFactors = length(acFactorNames);
 iNumStimuli = 2^iNumFactors;
a2bFactorMatrix = zeros(iNumStimuli, iNumFactors);
 for k=1:iNumStimuli
     strBinary = dec2bin(k-1,iNumFactors);
     a2bFactorMatrix(k,:) = strBinary == '1';
  end
% 
% strctUnit.m_strctSinhaPartsIncorrectFeaturesANOVA= fnPartsANOVA(strctUnit, 900:1155,acFactorNames);
aiRangeCorrectANOVA_NoForehead = 644:771;
aiRangeCorrectANOVA_WithForehead = 772:899;
aiRangeIncorrectANOVA_NoForehead = 900:1027;
aiRangeIncorrectANOVA_WithForehead = 1028:1155;
aiRangeCartoon = 1156:1283;
acCartoonFactorNames = {'Hair','Bounding Ellipse','Irises','Eyes','EyeBrow','Nose','Mouth'};
% 17, 27, %35
iSelectedCell = 35;
X1=acUnits{iSelectedCell}.m_a2fAvgFirintRate_Stimulus(aiRangeCorrectANOVA_NoForehead,:);
X2=acUnits{iSelectedCell}.m_a2fAvgFirintRate_Stimulus(aiRangeIncorrectANOVA_NoForehead,:);
X3=acUnits{iSelectedCell}.m_a2fAvgFirintRate_Stimulus(aiRangeCartoon,:);
figure(80);
clf;
imagesc(a2bFactorMatrix(1:128,2:end))
colormap gray
set(gca,'ytickLabel',[]);
set(gca,'xtickLabel',[]);
set(gcf,'position',[ 547   614   164   267]);
set(gca,'xtick',1:7);
set(gca,'xticklabel',acCartoonFactorNames);
xticklabel_rotate
figure(81);
clf;
imagesc(-200:500,1:128,X1,[0 95]);
axis([0 200 0 128]);
colormap jet
set(gcf,'position',[547   614   121   267]);
set(gca,'ytickLabel',[]);
set(gca,'xtick',[0,80,150]);
figure(82);
clf;
imagesc(-200:500,1:128,X2,[0 95]);
axis([0 200 0 128]);
colormap jet
set(gcf,'position',[547   614   121   267]);
set(gca,'ytickLabel',[]);
set(gca,'xtick',[0,80,150]);
figure(83);
clf;
imagesc(-200:500,1:128,X3,[0 95]);
axis([0 200 0 128]);
colormap jet
set(gcf,'position',[547   614   121   267]);
set(gca,'ytickLabel',[]);
set(gca,'xtick',[0,80,150]);
imagesc([X1,X2,X3]);



% Sinha parts (correct contrast)
clear a2fSinhaPartSig a2fSinhaPartSigInv a2bSinhaFeatureTuning a2bCartoonFeatureTuning a2fCartoonPartSig
for k=1:iNumUnits
    a2bSinhaFeatureTuning(k,:) = acUnits{k}.m_strctSinhaFeatureTuning.m_afSigTuning < 0.05;
    a2bCartoonFeatureTuning(k,:) = acUnits{k}.m_strctCartoonFeatureTuning.m_afSigTuning< 0.05;
    a2fCartoonPartSig(k,:) = (diag(acUnits{k}.m_strctCartoonANOVA.m_a2fPValue) < 0.005)';
    a2fSinhaPartSig(k,:) = (diag(acUnits{k}.m_strctSinhaPartsCorrectFeaturesANOVA.m_a2fPValue) < 0.005)';
    a2fSinhaPartSigInv(k,:) = (diag(acUnits{k}.m_strctSinhaPartsIncorrectFeaturesANOVA.m_a2fPValue) < 0.005)';
end



 mean(sum(a2fSinhaPartSig(:,2:end) == 1 & a2fCartoonPartSig == 1,2))
mean(sum(a2fSinhaPartSigInv(:,2:end) == 1 & a2fCartoonPartSig == 1,2))

[p,h]=signtest( sum(a2fSinhaPartSig(:,2:end) == 1 & a2fCartoonPartSig == 1,2),  sum(a2fSinhaPartSigInv(:,2:end) == 1 & a2fCartoonPartSig == 1,2))


figure(200);clf;


subplot(1,2,1);
subplot(1,2,2);
hold on;
bar(sum(a2fSinhaPartSig(:,2:end) == a2fSinhaPartSigInv(:,2:end),1)+sum(a2fSinhaPartSig(:,2:end) ~= a2fSinhaPartSigInv(:,2:end),1)); 
h=bar(sum(a2fSinhaPartSig(:,2:end) == a2fSinhaPartSigInv(:,2:end),1)); 
set(h,'facecolor','r');


sum(a2fSinhaPartSig(:,2:end) == a2fCartoonPartSig,1)
sum(a2fSinhaPartSig(:,2:end) ~= a2fCartoonPartSig,1)


% figure(11);
% clf;hold on;
% afHist1=hist(sum(a2fSinhaPartSig(:,2:end) ~= a2fCartoonPartSig,2),0:7);
% afHist2=hist(sum(a2fSinhaPartSigInv(:,2:end) ~= a2fCartoonPartSig,2),0:7);
% afHist3=hist(sum(a2fSinhaPartSigInv(:,2:end) ~= a2fSinhaPartSig(:,2:end),2),0:7);
% bar([afHist1;afHist2;afHist3]');
% [p,h]=ttest(sum(a2fSinhaPartSig(:,2:end) ~= a2fCartoonPartSig,2), sum(a2fSinhaPartSigInv(:,2:end) ~= a2fCartoonPartSig,2))
% 
acUnits{1}.m_strctSinhaPartsCorrectFeaturesANOVA.m_acFactorNames{4} = 'Irises';
acUnits{1}.m_strctCartoonANOVA.m_acFactorNames{3} = 'Irises';
figure(84);
clf;
imagesc(1:7,1:35,a2fSinhaPartSig(:,2:end));
colormap gray
set(gca,'xtick',1:7,'xticklabel',acUnits{1}.m_strctSinhaPartsCorrectFeaturesANOVA.m_acFactorNames(2:end));
set(gca,'ytick',[1,5:5:35])
set(gcf,'position',  [418   579   204   377]);
xticklabel_rotate

figure(85);clf;
imagesc(1:7,1:35,a2fSinhaPartSigInv(:,2:end));
colormap gray
set(gca,'xtick',1:7,'xticklabel',acUnits{1}.m_strctSinhaPartsCorrectFeaturesANOVA.m_acFactorNames(2:end));
set(gca,'ytick',[1,5:5:35])
set(gcf,'position',  [418   579   204   377]);
xticklabel_rotate
set(gca,'yticklabel',[]);

figure(86);clf;
imagesc(1:7,1:35,a2fCartoonPartSig);
colormap gray
set(gca,'xtick',1:7,'xticklabel',acUnits{1}.m_strctCartoonANOVA.m_acFactorNames);
set(gca,'ytick',[1,5:5:35])
set(gcf,'position',  [418   579   204   377]);
xticklabel_rotate
set(gca,'yticklabel',[]);


%%
figure(88);
clf;
subplot(1,2,1);
imagesc(1:7,1:35,a2fSinhaPartSig(:,2:end));
colormap gray
set(gca,'xtick',1:7,'xticklabel',acUnits{1}.m_strctSinhaPartsCorrectFeaturesANOVA.m_acFactorNames(2:end));
set(gca,'ytick',[1,5:5:35])
xticklabel_rotate
title('Correct Contrast');
ylabel('Unit');
subplot(1,2,2);
imagesc(1:7,1:35,a2fCartoonPartSig);
colormap gray
set(gca,'xtick',1:7,'xticklabel',acUnits{1}.m_strctCartoonANOVA.m_acFactorNames);
set(gca,'ytick',[1,5:5:35])
xticklabel_rotate
set(gca,'yticklabel',[]);
title('Cartoon');


figure(89);
clf;
subplot(1,2,1);
imagesc(1:7,1:35,a2fSinhaPartSig(:,2:end));
colormap gray
set(gca,'xtick',1:7,'xticklabel',acUnits{1}.m_strctSinhaPartsCorrectFeaturesANOVA.m_acFactorNames(2:end));
set(gca,'ytick',[1,5:5:35])
xticklabel_rotate
title('Correct Contrast');
ylabel('Unit');
subplot(1,2,2);
imagesc(1:7,1:35,a2fSinhaPartSigInv(:,2:end));
colormap gray
set(gca,'xtick',1:7,'xticklabel',acUnits{1}.m_strctCartoonANOVA.m_acFactorNames);
set(gca,'ytick',[1,5:5:35])
xticklabel_rotate
set(gca,'yticklabel',[]);
title('Incorrect Contrast');

tightsubplot(1,3,3,'Spacing',0.1);
hold on;
%bar(1:7,sum(a2fSinhaPartSig(:,2:end) == a2fCartoonPartSig,1)+sum(a2fSinhaPartSig(:,2:end) ~= a2fCartoonPartSig,1)); 


h=bar(1:7,sum(a2fSinhaPartSig(:,2:end) == a2fCartoonPartSig,1)); 
set(h,'facecolor','b');
set(gca,'xtick',1:7,'xticklabel',acUnits{1}.m_strctSinhaPartsCorrectFeaturesANOVA.m_acFactorNames(2:end));
xticklabel_rotate
set(gca,'xlim',[0 8])
box on
title('Agree by both');
ylabel('Number of units');
%%
return;

%%

function strctFiringRatePred = fnAddCartoonTuningSigUsingSurrogateTests(strctUnit,iNumSurrogateTests)

aiAllRelevantStimuli = 545:6556;
abRelevantStimuli = ismember(strctUnit.m_aiStimulusIndexValid,  aiAllRelevantStimuli);
aiRelevantStimuli = find(abRelevantStimuli);
aiStimuli = strctUnit.m_aiStimulusIndexValid(abRelevantStimuli);
%iNumSurrogateTests =  100;% 5016;
iBeforeMS = 0;
iAfterMS = 300;
iPSTH_Len = iAfterMS-iBeforeMS+1;
iNumFeatures = 21;
iOffset = 544;
iNumFeatureValues = 11;
 strctCartoon = load('D:\Data\Doris\Stimuli\cartoon\a2iCartoonMatrix.mat');
a2iCartoonMatrix = strctCartoon.a2iCartoonMatrix;
iTimeSmoothingMS = 5;

    
% Build the conditions....
a2cConditions = cell(iNumFeatures,iNumFeatureValues); 
 for iFeatureIter=1:iNumFeatures
     for iFeatureValue = 0:10
        %a2cConditions{iFeatureIter,1+iFeatureValue} = iOffset+find(a2iCartoonMatrix(:,1+iFeatureIter) == iFeatureValue);
        aiStimuliForThisCondition = iOffset+find(a2iCartoonMatrix(:,1+iFeatureIter) == iFeatureValue);
        a2cConditions{iFeatureIter,1+iFeatureValue} = find(ismember(aiStimuli, aiStimuliForThisCondition));
     end
 end
 acConditions = a2cConditions(:);
iNumConditions = length(acConditions);
% Build the averaging indices for fast computation 
 
 
a2bRasterCartoonOnly = fnRasterAux(strctUnit.m_afSpikeTimes, strctUnit.m_afStimulusONTime(aiRelevantStimuli), iBeforeMS, iAfterMS);  
iRaster_Length = size(a2bRasterCartoonOnly,2);

afSmoothingKernelMS = fspecial('gaussian',[1 7*iTimeSmoothingMS],iTimeSmoothingMS);
fprintf('Surrogate tests...\n');
a3fMeanTuning = zeros(iNumFeatures, 11,iPSTH_Len);
iNumSurrogateTests = 100;
 for iSurrogateIter=1:iNumSurrogateTests
     iNumAppear = size(a2bRasterCartoonOnly,1);
     aiPerm = randperm(iNumAppear);
     %aiPerm = circshift(1:iNumAppear,[1,iSurrogateIter]);
     a2bRasterShifted = a2bRasterCartoonOnly(aiPerm  ,:);
     
     a2fAvg = NaN*ones(iNumConditions, iRaster_Length);
     for iConditionIter=1:iNumConditions
         a2fAvg(iConditionIter,:) = mean(a2bRasterShifted(acConditions{iConditionIter}  ,:),1);
     end
     a2fAvg = conv2(a2fAvg,afSmoothingKernelMS ,'same');
     a2fTemp  = 1e3 * a2fAvg;
     
     a3fTuning = reshape(a2fTemp,  iNumFeatures, iNumFeatureValues,  iPSTH_Len);
     a3fMeanTuning = a3fMeanTuning + a3fTuning;
 end
 a3fMeanTuning = a3fMeanTuning / iNumSurrogateTests;
 
 for iFeatureIter=1:iNumFeatures
     Tmp=squeeze(a3fMeanTuning(iFeatureIter,:,:));
    afRampMean = mean(Tmp(:,80:220),2);
    afRampMin = min(Tmp(:,80:220),[],2);
    afRampMax = max(Tmp(:,80:220),[],2);
    strctFiringRatePred.m_a2fMean(iFeatureIter,:) = afRampMean;
    strctFiringRatePred.m_a2fMin(iFeatureIter,:) = afRampMin;
    strctFiringRatePred.m_a2fMax(iFeatureIter,:) = afRampMax;
 end


return;


%%
function fnFigure8B(abFaceSelective2)
global  g_strctTmp2
% first, show an example cell tuning curve
aiUnits2=find(abFaceSelective2);

iSelectedUnit = 3;

%% Add firing rate predicted from shift predicators:

strctFiringRatePred = fnAddCartoonTuningSigUsingSurrogateTests(g_strctTmp2.acUnits{aiUnits2(iSelectedUnit)},5000)

%%
iFeature = 1;
afRange = 300:400;
Tmp = squeeze(g_strctTmp2.acUnits{aiUnits2(iSelectedUnit)}.m_strctCartoonTuningPSTH.m_a3fPSTH(:,:,iFeature));
figure(88);
imagesc(-200:500,1:11,Tmp)
axis([-100 300  0.5 11.5])
set(gca,'ytick',1:2:11,'yticklabel',-5:2:5)
set(gca,'xtick',[0 100 200 ])

afRamp1 = mean(Tmp(:,280:420),2);

%%
iFeature = 4;
afRange = 300:400;
Tmp = squeeze(g_strctTmp2.acUnits{aiUnits2(iSelectedUnit)}.m_strctCartoonTuningPSTH.m_a3fPSTH(:,:,iFeature));
figure(88);
imagesc(-200:500,1:11,Tmp)
axis([-100 300  0.5 11.5])
set(gca,'ytickLabel',[]);
set(gca,'xtick',[0 100 200 ])
afRamp2 = mean(Tmp(:,280:420),2);
%%
afDarkPink = [22,16,84]/255 % Dark pink
afBrightPink = [178,177,217]/255 % light pink

afBrightGray = [234,234,234]/255 % light gray
afDarkGray = [201,201,201]/255 % dark gray


figure(99);clf;
subplot(1,2,1); hold on;

afX = -5:5;
afY = afRamp1;
afY1 = afY;
hHandle=fill([afX, afX(end:-1:1)],[afY', ones(size(afY'))*min(afY)], afBrightPink,'edgecolor','none');
plot(afX,afY,'color',afDarkPink,'linewidth',2);

afYmin = strctFiringRatePred.m_a2fMin(1,:);
afYmax = strctFiringRatePred.m_a2fMax(1,:);
hHandle=fill([afX, afX(end:-1:1)],[afYmax, afYmin], afBrightGray,'facealpha',0.5,'edgecolor','none');
plot(afX,afYmin,'color',afDarkGray,'linewidth',2);
plot(afX,afYmax,'color',afDarkGray,'linewidth',2);
plot(afX,strctFiringRatePred.m_a2fMean(1,:),'color',afDarkGray,'linewidth',2);
axis([-5 5 16 30 ]);
set(gca,'yticklabel',[])
set(gca,'xticklabel',[])

subplot(1,2,2); hold on;

afX = -5:5;
afY = afRamp2;
hHandle=fill([afX, afX(end:-1:1)],[afY', ones(size(afY'))*min(afY1)], afBrightPink,'edgecolor','none');
plot(afX,afY,'color',afDarkPink,'linewidth',2);

afYmin = strctFiringRatePred.m_a2fMin(4,:);
afYmax = strctFiringRatePred.m_a2fMax(4,:);
hHandle=fill([afX, afX(end:-1:1)],[afYmax, afYmin], afBrightGray,'facealpha',0.5,'edgecolor','none');
plot(afX,afYmin,'color',afDarkGray,'linewidth',2);
plot(afX,afYmax,'color',afDarkGray,'linewidth',2);
plot(afX,strctFiringRatePred.m_a2fMean(4,:),'color',afDarkGray,'linewidth',2);
axis([-5 5 16 30 ]);
set(gca,'yticklabel',[])
set(gca,'xticklabel',[])

%set(gca,'ytick',1:2:11,'yticklabel',-5:2:5)
%%
iFeature=3;


figure(89);
clf;hold on;
afX = 0:300;
afY = g_strctTmp2.acUnits{aiUnits2(iSelectedUnit)}.m_strctCartoonTuning.m_a2fHetroNoShuffle(iFeature,:);
plot(afX,afY,'color','k','LineWidth',2)
box on
set(gca,'yticklabel',[])
afY = g_strctTmp2.acUnits{aiUnits2(iSelectedUnit)}.m_strctCartoonTuning.m_a2fHetroThreshold(iFeature,:);
plot(afX,afY,'r','LineWidth',2);
set(gca,'xlim',[10 290],'xtick',[50,150,250],'ylim',[0 2.5*1e-3])
%%
iFeature=4;
figure(90);
clf;hold on;
afX = 0:300;
afY = g_strctTmp2.acUnits{aiUnits2(iSelectedUnit)}.m_strctCartoonTuning.m_a2fHetroNoShuffle(iFeature,:);
plot(afX,afY,'color','k','LineWidth',2)
box on
set(gca,'yticklabel',[])
afY = g_strctTmp2.acUnits{aiUnits2(iSelectedUnit)}.m_strctCartoonTuning.m_a2fHetroThreshold(iFeature,:);
plot(afX,afY,'r','LineWidth',2);
set(gca,'xlim',[10 290],'xtick',[50,150,250],'ylim',[0 2.5*1e-3])
%%

% Now, build the big matrix showing tuning for geometrical features and for
% contrast features.


iNumUnits = length(aiUnits2);
a2fTuningSinha = zeros(iNumUnits,55);
for iUnitIter=1:iNumUnits
    if iUnitIter == 16
        continue;
    end
      strctUnit = g_strctTmp2.acUnits{aiUnits2(iUnitIter)};
    a2fTuningSinha(iUnitIter,:) = strctUnit.m_strctContrastPair11Parts.m_afTuning;
end

% Now, look at cartoons
iNumContinuousBinsForSignificanceTuning = 15;

iNumFeatures = 21;
a2bTuningCartoon = zeros(iNumUnits, iNumFeatures);
for iUnitIter=1:iNumUnits
    strctUnit = g_strctTmp2.acUnits{aiUnits2(iUnitIter)};
    
        a2bAboveShufflePredicator = strctUnit.m_strctCartoonTuning.m_a2fHetroNoShuffle > strctUnit.m_strctCartoonTuning.m_a2fHetroThreshold;
        afMaxNumTimeBinsAbovePredicator = zeros(1,iNumFeatures);
        for iFeatureIter=1:iNumFeatures
            astrctIntervals = fnGetIntervals(a2bAboveShufflePredicator(iFeatureIter,:));
            if ~isempty(astrctIntervals)
                afMaxNumTimeBinsAbovePredicator(iFeatureIter) = max( cat(1,astrctIntervals.m_iLength));
            end
        end
        a2bTuningCartoon(iUnitIter,:) = afMaxNumTimeBinsAbovePredicator > iNumContinuousBinsForSignificanceTuning;
end
%%

acFeatureNames = {'Aspect Ratio','Face Direction','Assembly Height Height','Inter Eye Distance','Eye Eccentricity','Eye Size','Irises Size','Gaze Direction','Face roundness','Eyebrow slant','Angle of eyebrows',...
    'Width of eyebrows','Eyebrows Vertical Offset','Nose Base','Nose Altitude','Mouth Size','Mouth Top','Mouth Bottom','Mouth To Nose Distance','Hair Thickness','Hair Length'};
aiRetainFeatures = setdiff(1:21,[9,11]);
figure(91);
clf;
imagesc(1:19,1:35,a2bTuningCartoon(:,aiRetainFeatures));
colormap gray
set(gca,'ytick',[1,5:5:35],'xtick',1:19,'xticklabel',acFeatureNames(aiRetainFeatures));
% 
% xlabel('Cells');
% ylabel('Feature Dimension');
% set(gca,'ytick',1:19,'yticklabel',acFeatureNames(aiRetainFeatures));
% set(gca,'xtick',1:iNumUnits);
xticklabel_rotate



afBlue =     1.2*[74,126,187]/255;
afRed = 1.2*[190,75,72]/255;
a3fTuningRedBlue = zeros(iNumUnits,55,3);
for k=1:3
    a2fTmp = a3fTuningRedBlue(:,:,k);
    a2fTmp(a2fTuningSinha > 0) = afBlue(k);
    a2fTmp(a2fTuningSinha < 0) =  afRed(k);
    a3fTuningRedBlue(:,:,k) = a2fTmp;
end
figure(93);
imagesc(a3fTuningRedBlue)
set(gca,'yticklabel',[],'xtick',[1 5:10:55])
figure(94);
pie([17,10,1,7],[1 1 1 1])

colormap jet
figure(94);
aiNumCartoonFeatures = sum(a2bTuningCartoon,2);
mean(aiNumCartoonFeatures(aiNumCartoonFeatures>0))
std(aiNumCartoonFeatures(aiNumCartoonFeatures>0))
xlabel('Number of significant feature dimensions');
ylabel('Number of cells');


hist(aiNumCartoonFeatures,0:10)
axis([-0.5 10 0 8])

[afDummy, aiInd]=sort(sum(a2bTuningCartoon,1))
%Supplementary figure 7
figure(95);
bar(1:21,sum(a2bTuningCartoon,1))
set(gca,'xtick',1:21,'xticklabel',acFeatureNames)
xticklabel_rotate
ylabel('Number of cells');
figure(96);
plot(sum(a2bTuningCartoon,2), sum(abs(a2fTuningSinha)>0,2),'ob');
xlabel('Number of significant geometrical features');
ylabel('Number of significant contrast features');
[o,h]=corr(sum(a2bTuningCartoon,2), sum(abs(a2fTuningSinha)>0,2))

%%


sum(sum(abs(a2fTuningSinha) ,2) > 0 & sum(a2bTuningCartoon,2) > 0)

sum(sum(abs(a2fTuningSinha) ,2) > 0 & sum(a2bTuningCartoon,2) == 0)

sum(sum(abs(a2fTuningSinha) ,2) == 0 & sum(a2bTuningCartoon,2) == 0)
sum(sum(abs(a2fTuningSinha) ,2) == 0 & sum(a2bTuningCartoon,2) >0)
return;


function fnFigure7C(abFaceSelective2)

load('D:\Data\Doris\Data For Publications\Sinha\Final Data For Revised Neuron Paper\HairComparison');
iNumUnits = length(acUnits);
a3fFullResNorm = zeros(1682,701,  iNumUnits);
fPThres=1e-5;
for iIter=1:iNumUnits
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
         nanmean(nanmean(a3fFullResNorm(aiBlackHairIncorrectFeatures,:,:),3),1);
         ];

     
figure(75);
clf; hold on;
plot(-200:500,T(1:end,:)','LineWidth',2.5);
legend(acLegend(1:end),'Location','northeastoutside');
%xlabel('Time (ms)');
%ylabel('Avg. normalized response');
axis([0 350 0 0.26])
box on     



figure(78);
clf; hold on;
plot(-200:500,T(2:end,:)','LineWidth',2.5);
legend(acLegend(2:end),'Location','northeastoutside');
%xlabel('Time (ms)');
%ylabel('Avg. normalized response');
axis([0 350 0 0.12])
box on     

clear a2fNorm
for j=1:length(acUnits)
    a2fNorm(j,:) = acUnits{j}.m_strctHairComparison.m_afAvgFiringCondition / max(acUnits{j}.m_strctHairComparison.m_afAvgFiringCondition);
end

figure(76);

clf;
bar(1:4,nanmean(a2fNorm(:,1:4)));
set(gca,'xticklabel',acUnits{1}.m_strctHairComparison.m_acConditionNames(1:4));
xticklabel_rotate
[p,h]=ttest(a2fNorm(:,6),a2fNorm(:,4))
[p,h]=ttest(a2fNorm(:,1),a2fNorm(:,2))
[p,h]=ttest(a2fNorm(:,1),a2fNorm(:,3))
[p,h]=ttest(a2fNorm(:,4),a2fNorm(:,5)) % 0.3
[p,h]=ttest(a2fNorm(:,1),a2fNorm(:,4)) % 0.7

%%
figure(77);

aiIncorrectPermutations = 1670:1682;
aiCorrectPermutations = 1657:1669;
aiBlackHairCorrectFeatures = 550:562;
aiBlackHairIncorrectFeatures = 563:575;
aiWhiteHairCorrectFeatures = 576:588;
aiWhiteHairIncorrectFeatures = 589:601;
aiFaces = 1:16;
aiNonFaces = 17:96;
acLegend = {'Faces','Objects','Correct contrast no hair','Incorrect conrast no hair','Correct contrast with black hair','Incorrect contrast with black hair','correct contrast with white hair','incorrect contrast with white hair'};
T = [ nanmean(nanmean(a3fFullResNorm(aiFaces,:,:),3),1);
         nanmean(nanmean(a3fFullResNorm(aiNonFaces,:,:),3),1);
         nanmean(nanmean(a3fFullResNorm(aiCorrectPermutations,:,:),3),1);
         nanmean(nanmean(a3fFullResNorm(aiIncorrectPermutations,:,:),3),1);
         nanmean(nanmean(a3fFullResNorm(aiBlackHairCorrectFeatures,:,:),3),1);
         nanmean(nanmean(a3fFullResNorm(aiBlackHairIncorrectFeatures,:,:),3),1);
         nanmean(nanmean(a3fFullResNorm(aiWhiteHairCorrectFeatures,:,:),3),1);
         nanmean(nanmean(a3fFullResNorm(aiWhiteHairIncorrectFeatures,:,:),3),1);
         ];

     
clf; hold on;
plot(-200:500,T(1:end,:)','LineWidth',2.5);
legend(acLegend(1:end),'Location','northeastoutside');
%xlabel('Time (ms)');
%ylabel('Avg. normalized response');
axis([0 350 0 0.26])
box on     



figure(78);
clf; hold on;
plot(-200:500,T(2:end,:)','LineWidth',2.5);
legend(acLegend(2:end),'Location','northeastoutside');
%xlabel('Time (ms)');
%ylabel('Avg. normalized response');
axis([0 350 0 0.12])
box on     

return;


function fnPlotFigure6()
load('D:\Data\Doris\Data For Publications\Sinha\Final Data For Revised Neuron Paper\CBCL.mat');
iNumUnits=length(acUnits);
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
iSelectedCell = fnFindExampleCell(acUnits, 'Rocco','30-Apr-2010 17:29:57',18, 1, 2);

[afFaceSel, afNonFaceSel, Dummy1, Dummy2, Dummy3, Dummy4, afStdFaceSel, afStdNonFaceSel] = ...
            fnFiringRateNumberOfCorrectRatios(acUnits{iSelectedCell}, aiNumCorrectPairsInFaces_Sinha,aiNumCorrectPairsInNonFaces_Sinha,false,false);

figure(60);clf;hold on;
ahHandle(1) = fnFancyPlot2(0:12, afFaceSel, afStdFaceSel, [79,129,189]/255,0.5*[79,129,189]/255);
ahHandle(2) = fnFancyPlot2(0:12, afNonFaceSel, afStdNonFaceSel, [192,80,77]/255,0.5*[192,80,77]/255);
box on
set(gca,'xtick',0:12);
set(gca,'xlim',[0 12]);
grid on
figure(61);clf;
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

figure(63);
clf;
imagesc(acUnits{iSelectedCell}.m_aiPeriStimulusRangeMS, 1:411, acUnits{iSelectedCell}.m_a2fAvgFirintRate_Stimulus(1:411,:))
set(gca,'ytick',X,'yticklabel',acName);
hold on;
plot([-200 500],[208 208],'w');
xlabel('Time (ms)');
colorbar
set(gcf,'color',[1 1 1])
%ylabel('Number of incorrect pairs');

return;


function fnPlotFigure5(abFaceSelective1, abFaceSelective2,a2fTuning, acSubjects)
global g_strctTmp1 g_strctTmp2


aiUnits1=find(abFaceSelective1);
aiUnits2=find(abFaceSelective2);

aiUnits1Tuned = aiUnits1(sum( abs(a2fTuning(1:length(aiUnits1),:)),2) > 0);
aiUnits2Tuned = aiUnits2(sum( abs(a2fTuning(length(aiUnits1)+[1:length(aiUnits2)],:)),2) > 0);
strctTmp3=load('D:\Data\Doris\Stimuli\Sinha_Exp\Sinha_v2_FOB\SelectedPerm.mat');

iNumSubsetUnits =  length(aiUnits1Tuned)+length(aiUnits2Tuned);
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
[abCorrect, aiNumWrongRatios] = fnIsCorrectPerm3(strctTmp3.a2iAllPerm, a2iCorrectPairALargerB_Sinha);

afMeanCorrect = zeros(1, iNumSubsetUnits);
afMeanIncorrect = zeros(1, iNumSubsetUnits);
a2fRes = zeros(13, iNumSubsetUnits);
afMeanEdgesDark = zeros(1, iNumSubsetUnits);
afMeanEdgesBright = zeros(1, iNumSubsetUnits);
afMeanEdges = zeros(1, iNumSubsetUnits);
afMeanObject= zeros(1, iNumSubsetUnits);
afMeanRealFace = zeros(1, iNumSubsetUnits);
for iUnitIter=1:iNumSubsetUnits
    if iUnitIter <= length(aiUnits1Tuned)
        strctUnit = g_strctTmp1.acUnits{aiUnits1Tuned(iUnitIter)};
    else
        strctUnit = g_strctTmp2.acUnits{aiUnits2Tuned(iUnitIter-length(aiUnits1Tuned))};
    end
    
    
    
    afResponsesRAW = strctUnit.m_afAvgFirintRate_Stimulus;
    fMin = min(afResponsesRAW([1:528,534:544]));
    fMax = max(afResponsesRAW([1:528,534:544]));
    afResponses = (afResponsesRAW- fMin)/(fMax-fMin);
    
    afResponsesSinha = afResponses(97:528);
    afResponseEdgesDark = afResponses(534:535);
    afResponseEdgesBright = afResponses(543:544);
    afResponseEdges = afResponses(534:544);
    afRealFaces = afResponses(1:16);
    afObject = afResponses(17:96);
    afCorrect = afResponsesSinha(aiNumWrongRatios == 0);
    afIncorrect = afResponsesSinha(aiNumWrongRatios == 12);

    for k=0:12
        a2fRes(k+1,iUnitIter) = nanmean(afResponsesSinha(aiNumWrongRatios==k ));
    end
    afMeanRealFace(iUnitIter) = nanmean(afRealFaces);
    afMeanObject(iUnitIter) = nanmean(afObject);
    afMeanCorrect(iUnitIter) = nanmean(afCorrect);
    afMeanIncorrect(iUnitIter) = nanmean(afIncorrect);
    afMeanEdgesDark(iUnitIter) = nanmean(afResponseEdgesDark);
    afMeanEdgesBright(iUnitIter) = nanmean(afResponseEdgesBright);
    afMeanEdges(iUnitIter) = nanmean(afResponseEdges);
    a2fMeanEdges(iUnitIter,:) = afResponseEdges;
end

figure(50);
clf;
errorbar(1:11,nanmean(a2fMeanEdges),nanstd(a2fMeanEdges)/sqrt(119));
box on;
axis([0 12 0.18 0.28]);
set(gca,'xtick',1:11);
set(gca,'ytick',[0.18,0.22,0.26]);

figure(51);
clf;hold on;
h1=bar(0,mean(afMeanRealFace),'facecolor',[74,126,187]/255,'EdgeColor','none');
plot([0 0],[mean(afMeanRealFace)-std(afMeanRealFace)/sqrt(iNumSubsetUnits),mean(afMeanRealFace)+std(afMeanRealFace)/sqrt(iNumSubsetUnits)],'k','LineWidth',2);
h2=bar(1:13,mean(a2fRes'),'facecolor',0.9*[70,170,197]/255,'EdgeColor','none');
for k=1:13
    plot([k k],mean(a2fRes(k,:))+[-std(a2fRes(k,:))/sqrt(iNumSubsetUnits),std(a2fRes(k,:))/sqrt(iNumSubsetUnits)],'k','LineWidth',2);
end
h3=bar(14,mean(afMeanEdges),'facecolor',0.9*[190,75,72]/255,'EdgeColor','none');
plot([14 14],[mean(afMeanEdges)-std(afMeanEdges)/sqrt(iNumSubsetUnits),mean(afMeanEdges)+std(afMeanEdges)/sqrt(iNumSubsetUnits)],'k','LineWidth',2);
h4=bar(15,mean(afMeanObject),'facecolor',0.9*[152,185,84]/255,'EdgeColor','none');
plot([15 15],[mean(afMeanObject)-std(afMeanObject)/sqrt(iNumSubsetUnits),mean(afMeanObject)+std(afMeanObject)/sqrt(iNumSubsetUnits)],'k','LineWidth',2);
axis([-1 16 0.1 0.6])
set(gca,'xtick',[]);%[0 1 13 14 15]);
%set(gca,'xticklabel',{'Real Faces','12 Correct features','0 Correct features','Edges only','Objects'});
%xticklabel_rotate;
grid on
set(gca,'XMinorGrid','off')
set(gca,'XGrid','off')
box on
%%


figure(52);
clf;hold on;
h1=bar(0,mean(afMeanRealFace),'facecolor',0.9*[74,126,187]/255,'EdgeColor','none');
plot([0 0],[mean(afMeanRealFace)-std(afMeanRealFace)/sqrt(iNumSubsetUnits),mean(afMeanRealFace)+std(afMeanRealFace)/sqrt(iNumSubsetUnits)],'k','LineWidth',2);
h2=bar(1:13,mean(a2fRes'),'facecolor',0.9*[74,126,187]/255,'EdgeColor','none');
for k=1:13
    plot([k k],mean(a2fRes(k,:))+[-std(a2fRes(k,:))/sqrt(iNumSubsetUnits),std(a2fRes(k,:))/sqrt(iNumSubsetUnits)],'k','LineWidth',2);
end
h3=bar(14,mean(afMeanEdges),'facecolor',0.9*[74,126,187]/255,'EdgeColor','none');
plot([14 14],[mean(afMeanEdges)-std(afMeanEdges)/sqrt(iNumSubsetUnits),mean(afMeanEdges)+std(afMeanEdges)/sqrt(iNumSubsetUnits)],'k','LineWidth',2);
h4=bar(15,mean(afMeanObject),'facecolor',0.9*[74,126,187]/255,'EdgeColor','none');
plot([15 15],[mean(afMeanObject)-std(afMeanObject)/sqrt(iNumSubsetUnits),mean(afMeanObject)+std(afMeanObject)/sqrt(iNumSubsetUnits)],'k','LineWidth',2);
axis([-1 16 0 0.65])
set(gca,'xtick',[]);%[0 1 13 14 15]);
%set(gca,'xticklabel',{'Real Faces','12 Correct features','0 Correct features','Edges only','Objects'});
%xticklabel_rotate;
grid on
set(gca,'XMinorGrid','off')
set(gca,'XGrid','off')
box on
%%
return;

function [a2fTuning, acSubjects]=fnPlotFigure3and4(abFaceSelective1, abFaceSelective2)
global g_strctTmp1 g_strctTmp2




% Build the feature polarity matrices
aiUnits1=find(abFaceSelective1);
aiUnits2=find(abFaceSelective2);
iNumUnits = length(aiUnits1)+length(aiUnits2);

acSubjects = [fnCellStructToArray(g_strctTmp1.acUnits(aiUnits1),'m_strSubject'), repmat({'Julien'},1,35)];
abRocco = strcmp(acSubjects,'Rocco');
abHoudini = strcmp(acSubjects,'Houdini');
abJulien = strcmp(acSubjects,'Julien');

fPThres=  1e-5;

a2iPairs = nchoosek(1:11,2);
acPartNames = {'Forehead','Left Eye','Nose','Right Eye','Left Cheek','Upper Lip','Right Cheek','Lower Left Cheek','Mouth','Lower Right Cheek','Chin'};
for k=1:55
    iPartA = a2iPairs(k,1);
    iPartB = a2iPairs(k,2);
    acPairName{k} = [acPartNames{iPartA},' > ',acPartNames{iPartB}];
end
clear a2fResponses a2fPValue a2fTuning

a2fTuning = zeros(iNumUnits, 55);
fPValue=1e-5;
a2fTuning = fnCalcSigRatiosSinha(g_strctTmp1.acUnits(abFaceSelective1), fPValue);

for iIter=1:length(aiUnits2)
    if iIter==16
        continue;
    end;
    afPValues =g_strctTmp2.acUnits{aiUnits2(iIter)}.m_strctContrastPair11Parts.m_afPvalue;
    abLarger = g_strctTmp2.acUnits{aiUnits2(iIter)}.m_strctContrastPair11Parts.m_a2fAvgFiring(:,1) > g_strctTmp2.acUnits{aiUnits2(iIter)}.m_strctContrastPair11Parts.m_a2fAvgFiring(:,2) ;
    afTuning = zeros(1,55);
    afTuning(abLarger' &   (afPValues<fPThres)) = 1;
    afTuning(~abLarger' & (afPValues<fPThres)) = -1;
    a2fTuning(245+iIter,:) = afTuning;
end

afBlue =     1.2*[74,126,187]/255;
afRed = 1.2*[190,75,72]/255;
a3fTuningRedBlue = zeros(iNumUnits,55,3);
for k=1:3
    a2fTmp = a3fTuningRedBlue(:,:,k);
    a2fTmp(a2fTuning > 0) = afBlue(k);
    a2fTmp(a2fTuning < 0) =  afRed(k);
    a3fTuningRedBlue(:,:,k) = a2fTmp;
end
%%
if 0
iSelectedCell = fnFindExampleCell(acUnits, 'Rocco','19-Jul-2010 17:50:06', 8, 1, 1);
   [a2fFiring,afPValue,acNames,a2fStdErr,a2fStd]= fnGetAllRatios(acUnits{iSelectedCell});
   afMaxFir = max(a2fFiring,[],2);
    
    hFig=figure(4);
    clf;
    
    h=bar(1:55,1e3*a2fFiring);
    hold on;
    set(h(1),'FaceColor',[74,126,187]/255,'EdgeColor','none');
    set(h(2),'FaceColor',0.9*[190,75,72]/255,'EdgeColor','none');
     aiSig = find(afPValue < 1e-5);
    plot(aiSig,1e3*max(afMaxFir(aiSig))*1.1,'k*');
    axis([0 56 0 38]);
     set(gca,'xtick',1:3:55)
     box on
end
     


%%
% Consistency index
for k=1:55
    iNumPos = sum(a2fTuning(:,k)==1);
    iNumNeg = sum(a2fTuning(:,k)==-1);
    afRatio(k) = abs(iNumPos-iNumNeg) / (iNumPos+iNumNeg);
    aiNumTuned(k) = iNumPos+iNumNeg;
end
mean(afRatio(aiNumTuned>3))
std(afRatio(aiNumTuned>3))

%%  percent of cells encoding features involving eyes
abFeaturesInvolvingEyes = (a2iPairs(:,1) == 2 | a2iPairs(:,2) == 2 | a2iPairs(:,1) == 4 | a2iPairs(:,2) == 4 );

aiTunedCells = find(sum(abs(a2fTuning),2) > 0)
for k=1:length(aiTunedCells)
    afTuning = a2fTuning(aiTunedCells(k),:);
    aiNumFeaturesWithEyes(k) = sum(abs(afTuning(abFeaturesInvolvingEyes)));
    aiNumFeaturesWithoutEyes(k) = sum(abs(afTuning(~abFeaturesInvolvingEyes)));
end
mean(aiNumFeaturesWithEyes) / sum(abFeaturesInvolvingEyes) * 1e2

mean(aiNumFeaturesWithoutEyes)/ sum(~abFeaturesInvolvingEyes) * 1e2
%%
fnPlotPolarityHistogram(a2fTuning,true)

a2iRocco = fnPlotPolarityHistogram(a2fTuning(abRocco,:),false);
set(gca,'xtick',[]);
set(gca,'yticklabel',num2str(abs(str2num(get(gca,'ytickLabel')))));
set(gcf,'Position',[  680   988   328   110]);
a2iHoudini = fnPlotPolarityHistogram(a2fTuning(abHoudini,:),false);
set(gca,'xtick',[]);
set(gca,'yticklabel',num2str(abs(str2num(get(gca,'ytickLabel')))));
set(gcf,'Position',[  680   988   328   110]);

a2iJulien = fnPlotPolarityHistogram(a2fTuning(abJulien,:),false);
set(gca,'yticklabel',num2str(abs(str2num(get(gca,'ytickLabel')))));
set(gca,'xtick',[1,5:5:55]);
% set(gcf,'position',[   486   700   858   331]);
% set(gca,'position',[0.1300    0.1100    0.5839    0.8150]);
%% Correlations between matrices
corr([a2iRocco(:,1);a2iRocco(:,2)],[a2iHoudini(:,1);a2iHoudini(:,2)]).^2
corr([a2iRocco(:,1);a2iRocco(:,2)],[a2iJulien(:,1);a2iJulien(:,2)]).^2
corr([a2iHoudini(:,1);a2iHoudini(:,2)],[a2iJulien(:,1);a2iJulien(:,2)]).^2
%%
figure;
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
acPartNames11 = {'Forehead','Left Eye','Nose','Right Eye','Left Cheek','Upper Lip','Right Cheek','LL Cheek','Mouth','LR Cheek','Chin'};
%%
figure(1000);
clf;
a2bParts = zeros(11,55);
a2iPairs11 = nchoosek(1:11,2);
for k=1:55
    a2bParts(a2iPairs11(k,1),k) = 0.5;
    a2bParts(a2iPairs11(k,2),k) = 1;
end
imagesc(a2bParts);
colormap gray
set(gca,'ytick',1:11);
acPartNames11 = {'Forehead','Left Eye','Nose','Right Eye','Left Cheek','Upper Lip','Right Cheek','LL Cheek','Mouth','LR Cheek','Chin'};


%%
set(gca,'yticklabel',acPartNames11);
set(gca,'xtick',1:2:55);
%%

%%



figure(30);
imagesc(1:sum(abRocco), 1:55,fnTransRGB(a3fTuningRedBlue(abRocco,:,:)));
%set(30,'position',[231,746,489,265])
set(gca,'xtick',[1,20:20:120],'xticklabel',[1,20:20:120],'ytick',[1,5:5:55])

figure(31);
imagesc(1:sum(abHoudini),1:55,fnTransRGB(a3fTuningRedBlue(abHoudini,:,:)));

%set(31,'position',[231,746,489,265]);
set(gca,'xtick',[1,20:20:120],'xticklabel',[1,20:20:120])
set(gca,'ytick',[]);
figure(32);
imagesc(1:sum(abJulien),1:55,fnTransRGB(a3fTuningRedBlue(abJulien,:,:)));
%set(32,'position',[231,746,198,265])
set(gca,'ytick',[]);
%%
iNumTuned = sum(sum(abs(a2fTuning),2)>0);
[aiNumUnits, aiSortInd]=sort(sum(abs(a2fTuning),1),'descend');
figure;
barh(fliplr(aiNumUnits(1:10))/iNumTuned)
grid off
box on
set(gca,'ylim',[0 11],'xlim',[0 0.8],'xtick',[0:0.2:0.8])
set(gca,'ytick',[])
%acPairName(aiSortInd(1:10))

%% Plot tuning on sinha....
aiSinhaPredicted = [  1     3    13    30    11    20    22    38    47    50    53    54];
for k=1:55
    a2iSigRatio(k,1) = sum(a2fTuning(:,k) == 1);
    a2iSigRatio(k,2) = sum(a2fTuning(:,k) == -1);
end
a2iSigRatio(aiSinhaPredicted,:)
%%
figure(39);
hist(sum(abs(a2fTuning),2),1:55)
set(gca,'ylim',[0 30])
set(gca,'xlim',[0 35])
X=fnCharToCell(get(gca,'yticklabel'));
X{end}='140';
set(gca,'ytickLabel',X);
return;


function a2iSigRatio=fnPlotPolarityHistogram(a2fTuning,bPlotPred)


for k=1:55
    a2iSigRatio(k,1) = sum(a2fTuning(:,k) == 1);
    a2iSigRatio(k,2) = sum(a2fTuning(:,k) == -1);
end
%%


figure;
clf;
hold on;
ahHandles(1) = bar(a2iSigRatio(:,1),'facecolor',[79,129,189]/255);
ahHandles(2) = bar(-a2iSigRatio(:,2),'facecolor',[192,80,77]/255);
 %ylabel('Number of units');
fMax = 1*max(abs(a2iSigRatio(:)));

if bPlotPred
%strctCBCL_Pred = load('D:\Code\Doris\Stimuli_Generating_Code\Sinha\CBCLInvarianceRatios.mat');
strctMonkeyPred = load('D:\Code\Doris\Stimuli_Generating_Code\Sinha\MonkeyInvarianceRatios.mat');
strctShayPred = load('D:\Code\Doris\Stimuli_Generating_Code\Sinha\ShayInvarianceRatios.mat');


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
iNumRatios = size(a2iCorrectEdges,1);
aiSinhaRatio = zeros(1,iNumRatios);
abASmallerB = zeros(1,iNumRatios) >0;
a2iPairs = nchoosek(1:11,2);
for k=1:iNumRatios
aiSinhaRatio(k) = find(a2iPairs(:,1) == a2iCorrectEdges(k,1) & a2iPairs(:,2) == a2iCorrectEdges(k,2) | ...
     a2iPairs(:,1) == a2iCorrectEdges(k,2) & a2iPairs(:,2) == a2iCorrectEdges(k,1));
 abASmallerB(k) = all(a2iCorrectEdges(k,:) == a2iPairs(aiSinhaRatio(k) ,:));
 
end

plot([0 55],[fMax+5 fMax+5],'k--');
plot([0 55],[-fMax-5 -fMax-5],'k--');

 % Draw Predictions from monkey
 fMarkerSizeW = 0.5;
 fMarkerSizeH = 10;
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
        ahHandles(3) = fnPlotFilledTriangle(0,iPairIndex,10+fMax+fMarkerSizeH,fMarkerSizeW,fMarkerSizeH, afColors1);
    else
        ahHandles(3) = fnPlotFilledTriangle(1,iPairIndex,-10+-fMax-fMarkerSizeH,fMarkerSizeW,fMarkerSizeH,afColors1);
    end
      set(ahHandles(3),'edgecolor','none');
    
    iPairIndex = strctShayPred.aiInvarianceRatios(k);
    if strctShayPred.aiSelectivityIndex(iPairIndex) > 0
        ahHandles(4) = fnPlotFilledTriangle(0,iPairIndex,10+fMax+2*fMarkerSizeH,fMarkerSizeW,fMarkerSizeH, afColors2);
    else
        ahHandles(4) = fnPlotFilledTriangle(1,iPairIndex,-10+-fMax-2*fMarkerSizeH,fMarkerSizeW,fMarkerSizeH, afColors2);
    end
        set(ahHandles(4),'edgecolor','none');
  
    iPairIndex = aiSinhaRatio(k);
    if ~abASmallerB(k)
        ahHandles(5) = fnPlotFilledTriangle(0,iPairIndex,-10+fMax+3*fMarkerSizeH,fMarkerSizeW,fMarkerSizeH, afColors3);

    else
        ahHandles(5) = fnPlotFilledTriangle(1,iPairIndex,-10+-fMax-3*fMarkerSizeH,fMarkerSizeW,fMarkerSizeH, afColors3);

    end
       set(ahHandles(5),'edgecolor','none');
     
end


%legend(ahHandles,{'Part A > Part B','Part A < Part B','Pred Monkey','Pred Human','Pred Sinha'},'Location','NorthEastOutside');
axis([0.5 55.5 -fMax-45 fMax+45])
set(gca,'xtick',1:2:55);
set(gca,'yticklabel',num2str(abs(str2num(get(gca,'ytickLabel')))));
else
axis([0.5 55.5 -fMax-10 fMax+10])
end
box on
return;

function J=fnTransRGB(I)
J=zeros(size(I,2),size(I,1),3);
for k=1:3
    J(:,:,k) = I(:,:,k)';
end
return;

function fnPlotFigure2(abFaceSelective1, abFaceSelective2,afdPrimeBaselineSub)
global g_strctTmp1 g_strctTmp2
fnPlotFigure2_PlotExampleCell();
fnPlotFigure2_SortedFiringRate(abFaceSelective1, abFaceSelective2,afdPrimeBaselineSub);
return;

function fnPlotFigure2_SortedFiringRate(abFaceSelective1, abFaceSelective2,afdPrimeBaselineSub)
global g_strctTmp1 g_strctTmp2

aiUnits1=find(abFaceSelective1);
aiUnits2=find(abFaceSelective2);
abSel  = [abFaceSelective1,abFaceSelective2];

iNumUnits = length(aiUnits1)+length(aiUnits2);
a2fMatrix = zeros(iNumUnits,528);
a2fMatrixSub = zeros(iNumUnits,528);
a3fPSTH = zeros(iNumUnits,528,701);
for iUnitIter=1:length(aiUnits1)
    a2fMatrix(iUnitIter,:) = g_strctTmp1.acUnits{aiUnits1(iUnitIter)}.m_afAvgFirintRate_Stimulus(1:528);
    a3fPSTH(iUnitIter,:,:) = g_strctTmp1.acUnits{aiUnits1(iUnitIter)}.m_a2fAvgFirintRate_Stimulus(1:528,:);
    a2fMatrixSub(iUnitIter,:) = g_strctTmp1.acUnits{aiUnits1(iUnitIter)}.m_afAvgStimulusResponseMinusBaseline(1:528);
end
for iUnitIter2=1:length(aiUnits2)
    a2fMatrix(iUnitIter+iUnitIter2,:) = g_strctTmp2.acUnits{aiUnits2(iUnitIter2)}.m_afAvgFirintRate_Stimulus(1:528);
     a3fPSTH(iUnitIter+iUnitIter2,:,:)  = g_strctTmp2.acUnits{aiUnits2(iUnitIter2)}.m_a2fAvgFirintRate_Stimulus(1:528,:);
    a2fMatrixSub(iUnitIter+iUnitIter2,:) = g_strctTmp2.acUnits{aiUnits2(iUnitIter2)}.m_afAvgStimulusResponseMinusBaseline(1:528);
end

a2fMatrixNorm = a2fMatrix ./ repmat(max(a2fMatrix,[],2),1,528);


 %Compute sparseness measure

afSparsenessFace = fnSparsenessIndex(a2fMatrixNorm(:,1:16));
afSparsenessObject = fnSparsenessIndex(a2fMatrixNorm(:,17:96));
afSparsenessSinha = fnSparsenessIndex(a2fMatrixNorm(:,97:end));
afResFace = nanmean( a2fMatrixNorm(:,1:16),2);
afResObj = nanmean( a2fMatrixNorm(:,17:96),2);
afResSinha = nanmean( a2fMatrixNorm(:,97:end),2);

figure(2000);
clf;
plot(afSparsenessSinha, afdPrimeBaselineSub(abSel ), 'b.');
xlabel('Sinha Sparseness');
ylabel('d''');

figure(1000);clf;
subplot(3,2,1);
plot(afSparsenessSinha,afSparsenessObject, '.');
xlabel('Sparseness index for sinha');
ylabel('Sparseness index for objects');
hold on;
[o,h]=robustfit(afSparsenessSinha,afSparsenessObject)
afX=linspace(0,1,10);
plot(afX,o(2)*afX+o(1),'r');
axis equal
axis([0 1 0 1]);
subplot(3,2,2);
 %fnCorrectContrastAnalysis(a3fPSTH);
[rho,pval]=corr(afResObj,afResSinha)
 plot(afResObj,afResSinha,'.');
 xlabel('Normalized Response to Objects');
 ylabel('Normalized Response to Sinha');
q= robustfit(afResObj,afResSinha);
hold on;
afX=linspace(0,0.7,10);
plot( afX, q(2)*afX+q(1),'r');
 axis equal
axis([0 1 0 1]);
subplot(3,2,3);
plot(afSparsenessSinha,afSparsenessFace, '.');
xlabel('Sparseness index for sinha');
ylabel('Sparseness index for Faces');
hold on;
[o,h]=robustfit(afSparsenessSinha,afSparsenessFace)
afX=linspace(0,1,10);
plot(afX,o(2)*afX+o(1),'r');
axis equal
axis([0 1 0 1]);
subplot(3,2,4);
 %fnCorrectContrastAnalysis(a3fPSTH);
[rho,pval]=corr(afResFace,afResSinha)
 plot(afResFace,afResSinha,'.');
 xlabel('Normalized Response to Faces');
 ylabel('Normalized Response to Sinha');
q= robustfit(afResFace,afResSinha);
hold on;
afX=linspace(0,0.7,10);
plot( afX, q(2)*afX+q(1),'r');
axis equal
axis([0 1 0 1]);



subplot(3,2,5);
plot(afSparsenessObject,afSparsenessFace, '.');
xlabel('Sparseness index for Objects');
ylabel('Sparseness index for Faces');
hold on;
[o,h]=robustfit(afSparsenessObject,afSparsenessFace)
afX=linspace(0,1,10);
plot(afX,o(2)*afX+o(1),'r');
axis equal
axis([0 1 0 1]);
subplot(3,2,6);
 %fnCorrectContrastAnalysis(a3fPSTH);
[rho,pval]=corr(afResFace,afResObj)
 plot(afResFace,afResObj,'.');
 xlabel('Normalized Response to Faces');
 ylabel('Normalized Response to Objects');
q= robustfit(afResFace,afResObj);
hold on;
afX=linspace(0,0.7,10);
plot( afX, q(2)*afX+q(1),'r');
axis equal
axis([0 1 0 1]);

%%
a2fMatrixNormSorted = zeros(iNumUnits, 528);
for k=1: iNumUnits
   F = a2fMatrixNorm(k,1:16);
   NF = a2fMatrixNorm(k,17:96);
   S = a2fMatrixNorm(k,97:end);
   
   
   a2fMatrixNormSorted(k,:) = [....
       circshift(sort(F), [1, sum(isnan(F))]),...
       circshift(sort(NF), [1, sum(isnan(NF))]),...
       circshift(sort(S), [1, sum(isnan(S))])];
end

figure(23);imagesc(a2fMatrixNormSorted(:,1:16),[0 1]);set(gca,'xtick',[]);set(gca,'ytick',0:40:280)
figure(24);imagesc(a2fMatrixNormSorted(:,98:end),[0 1]);set(gca,'ytick',[]);set(gca,'xtick',[]);
figure(25);imagesc(a2fMatrixNormSorted(:,17:96),[0 1.2]);set(gca,'ytick',[]);set(gca,'xtick',[]);

% Supplementary figure 2
for k=1:iNumUnits
    afRatio(k)=max(a2fMatrix(k,97:end))/max(a2fMatrix(k,1:16));
    afMinimalResponse(k)=min(a2fMatrixSub(k,97:end));
    afMaxObject(k)=max(a2fMatrixSub(k,17:96));
    afRatioSub(k)=max(a2fMatrixSub(k,97:end))/max(a2fMatrixSub(k,1:16));
    aiNumLargerThanFace(k) = sum(a2fMatrixSub(k,97:end) > mean(a2fMatrixSub(k,1:16)));
end;
sum(afMinimalResponse < afMaxObject & afRatioSub > 1 )
%sum(afRatioSub > 1 & afMinimalResponse == 0)
std(aiNumLargerThanFace)
figure(26);clf;
[afHist,afCent]=hist(afRatioSub,linspace(0,2,20));
bar(afCent,afHist,'FaceColor',[74,126,187]/255,'EdgeColor','none');
axis([0 2.05  0 40]);
return;




function fnCorrectContrastAnalysis(a3fPSTH)
aiCorrectContrastInd = [23,43,44,105,121,162,203,206,237,270,327,409,426];
global g_strctTmp1 g_strctTmp2
% Normalize PSTH
iNumUnits = size(a3fPSTH,1);
a3fPSTH_Norm = zeros(iNumUnits,528,701);
for iUnitIter=1:iNumUnits
    a2fPSTH = squeeze(a3fPSTH(iUnitIter,:,:));
    a3fPSTH_Norm(iUnitIter,:,:) = a2fPSTH/max(a2fPSTH(:));
end
A=squeeze(nanmean(a3fPSTH_Norm(:,aiCorrectContrastInd+96,:),2));
B=mean(A,1)
C=squeeze(nanmean(a3fPSTH_Norm(:,1:16,:),2));

D=mean(C,1)
figure(900);clf;
plot(-200:500,B);hold on; plot(-200:500,D,'r');
legend('Average real face','Average "correct" contrast');

function fnPlotFigure2_PlotExampleCell()
global g_strctTmp1 g_strctTmp2
%% Show example cell
iSelectedCell = fnFindExampleCell(g_strctTmp1.acUnits, 'Rocco','19-Jul-2010 17:50:06', 8, 1, 1);

    strctUnit = g_strctTmp1.acUnits{iSelectedCell};
    
    A = strctUnit.m_a2fAvgFirintRate_Stimulus(97:528,:);
    [Temp,indA]=sort(strctUnit.m_afAvgFirintRate_Stimulus(97:528),'descend');
    A = A(indA,:);
    
    B = strctUnit.m_a2fAvgFirintRate_Stimulus(1:16,:);
    [Temp,indB]=sort(strctUnit.m_afAvgFirintRate_Stimulus(1:16),'descend');
    B = B(indB,:);
    
    C = strctUnit.m_a2fAvgFirintRate_Stimulus(17:96,:);
    [Temp,indC]=sort(strctUnit.m_afAvgFirintRate_Stimulus(17:96),'descend');
    C = C(indC,:);
    
    figure(20);
    clf;
    imagesc(strctUnit.m_aiPeriStimulusRangeMS(101:601),1:16,B(:,101:601),[0 140]);
    axis xy
    set(gca,'ytick',[1 16])
    set(gcf,'Position',[1155        1000         318         101])
    figure(21);
    clf;
    imagesc(strctUnit.m_aiPeriStimulusRangeMS(101:601),17:96,C(:,101:601),[0 140]);
    axis xy
    set(gca,'ytick',[17 96])
    set(21,'Position',[ 1152         789         318         101])
    set(gca,'xticklabel','');
    
    figure(22);
    clf;
    imagesc(strctUnit.m_aiPeriStimulusRangeMS(101:601),97:528,A(:,101:601),[0 140]);
    axis xy
    set(gca,'ytick',[97 528])
    set(gcf,'Position',[ 1152         675         318         215])
    set(gca,'xticklabel','');


return;


 
function [abFaceSelective1, abFaceSelective2,afdPrimeBaselineSub]=fnPlotFigure1(bQuickReturn)
global g_strctTmp1 g_strctTmp2
%acAllUnits = [g_strctTmp1.acUnits,g_strctTmp2.acUnits];
%[afFaceSelectivityIndex,afFaceSelectivityIndexUnBounded,afdPrime,afdPrimeBaselineSub,afDPrimeAllTrials, afAUC,afAUCBaselineSub,afPvalue_AUC,afPvalue_AUC_BaslineSub]  = fnComputeFaceSelecitivyIndex();
bPermutationTest = false;
if ~isempty(g_strctTmp1)
     [afdPrime1,afdPrimeBaselineSub1,afdPrimeAllTrials1,afAUC1,afAUCBaselineSub1,afPvalue_AUC1,afPvalue_AUC_BaslineSub1, afFSI1,afFSI_Sub1 ]=fnComputeDPrime(g_strctTmp1.acUnits, bPermutationTest);
    abFaceSelective1 = afdPrimeBaselineSub1>0.5;
else
    abFaceSelective1 = [];
end

if ~isempty(g_strctTmp2)
 [afdPrime2,afdPrimeBaselineSub2,afdPrimeAllTrials2,afAUC2,afAUCBaselineSub2,afPvalue_AUC2,afPvalue_AUC_BaslineSub2, afFSI2,afFSI_Sub2]=fnComputeDPrime(g_strctTmp2.acUnits, bPermutationTest);
     abFaceSelective2 = afdPrimeBaselineSub2>0.5;
else
     abFaceSelective2 = [];
end
 if bQuickReturn 
     return;
 end
 acSubject = [fnCellStructToArray(g_strctTmp1.acUnits,'m_strSubject'), repmat({'Julien'},1,42)];


afPValuesAUC = [afPvalue_AUC_BaslineSub1,afPvalue_AUC_BaslineSub2];
sum(afPValuesAUC<0.05)
abRocco = (strcmpi(acSubject,'Rocco'));
abHoudini = (strcmpi(acSubject,'Houdini'));
abJulien = (strcmpi(acSubject,'Julien'));
afdPrimeBaselineSub = [afdPrimeBaselineSub1,afdPrimeBaselineSub2];
afFSI_Sub = [afFSI_Sub1,afFSI_Sub2];

afFSI = [afFSI1,afFSI2];
 afAUC = [afAUC1, afAUC2];
 afAUCBaselineSub = [afAUCBaselineSub1, afAUCBaselineSub2];
 
 abFaceUnits = afdPrimeBaselineSub > 0.5;
 sum(abFaceUnits(abRocco))
 sum(abFaceUnits(abHoudini))
 sum(abFaceUnits(abJulien)) 
 
[afHist, afCent] = hist(afdPrimeBaselineSub,0:0.2:6);

figure(10);
clf;
bar(afCent,afHist,'FaceColor',[74,126,187]/255,'EdgeColor','none');
axis([-0.5 6.5 0 max(afHist)*1.1]);
[afDummy, aiInd] = sort(abs(afdPrimeBaselineSub-0.5));
iIndex = aiInd(4);

figure(11);
clf;
imagesc(-200:500,1:96,g_strctTmp1.acUnits{iIndex}.m_a2fAvgFirintRate_Stimulus(1:96,:));
set(gca,'ytick',[],'xlim',[-100 300]);

figure(12);
[afHist, afCent] = hist(afAUC,0.5:0.05:1);

bar(afCent,afHist,'FaceColor',[74,126,187]/255,'EdgeColor','none');
set(gca,'xlim',[0.45 1.05]);

figure(13);
[afHist, afCent] = hist(afFSI,-1:0.1:1);
bar(afCent,afHist,'FaceColor',[74,126,187]/255,'EdgeColor','none');
set(gca,'xlim',[-1 1.05]);



return; 
 
function [afdPrime,afdPrimeBaselineSub,afdPrimeAllTrials,afAUC,afAUCBaselineSub,afPvalue_AUC,afPvalue_AUC_BaslineSub, afFSI,afFSI_Sub ]=fnComputeDPrime(acUnits,bPermutationTest)
iNumUnits = length(acUnits);
afdPrime = zeros(1,iNumUnits);
afdPrimeBaselineSub = zeros(1,iNumUnits);
afdPrimeAllTrials= zeros(1,iNumUnits);
afAUC = zeros(1,iNumUnits);
afAUCBaselineSub= zeros(1,iNumUnits);
afPvalue_AUC_BaslineSub = zeros(1,iNumUnits);
afPvalue_AUC= zeros(1,iNumUnits);
 afFSI = zeros(1,iNumUnits);
 afFSI_Sub = zeros(1,iNumUnits);
% Proper d' is :Z(hit rate)-Z(false alarm rate)
% since we don't know the optimal threshold, we can test for all possible
% ones and take the maximal (!)
%norminv(0.8)5
for k=1:iNumUnits
    fprintf('%d out of %d\n',k,iNumUnits);
    strctUnit = acUnits{k};
    
    afResPos =strctUnit.m_afAvgStimulusResponseMinusBaseline(1:16);
    afResPos = afResPos(~isnan(afResPos));
    
    afResNeg =strctUnit.m_afAvgStimulusResponseMinusBaseline(17:96);
    afResNeg = afResNeg(~isnan(afResNeg));
    
afFSI_Sub(k) = (mean(afResPos) - mean(afResNeg))/(mean(afResPos) + mean(afResNeg));
        
    [afdPrimeBaselineSub(k),afAUCBaselineSub(k),afPvalue_AUC_BaslineSub(k)] = fnDPrimeROC(afResPos, afResNeg,bPermutationTest);
    
    afResPos =strctUnit.m_afAvgFirintRate_Stimulus(1:16);
    afResPos = afResPos(~isnan(afResPos));
    
    afResNeg =strctUnit.m_afAvgFirintRate_Stimulus(17:96);
    afResNeg = afResNeg(~isnan(afResNeg));
    
    
    afFSI(k) = (mean(afResPos) - mean(afResNeg))/(mean(afResPos) + mean(afResNeg));
    
    [afdPrime(k), afAUC(k),afPvalue_AUC(k)] = fnDPrimeROC(afResPos, afResNeg);
    
    afResPos = strctUnit.m_afStimulusResponseMinusBaseline(strctUnit.m_aiStimulusIndexValid >= 1 & strctUnit.m_aiStimulusIndexValid <= 16);
    afResNeg = strctUnit.m_afStimulusResponseMinusBaseline(strctUnit.m_aiStimulusIndexValid >= 17 & strctUnit.m_aiStimulusIndexValid <= 96);
    afdPrimeAllTrials(k) = fnDPrimeROC(afResPos, afResNeg);
end
return;

function [afFaceSelectivityIndex,afFaceSelectivityIndexUnBounded,afdPrime,afdPrimeBaselineSub,afDPrimeAllTrials, afAUC,afAUCBaselineSub,afPvalue_AUC,afPvalue_AUC_BaslineSub]  = fnComputeFaceSelecitivyIndex(acUnits)
iNumUnits = length(acUnits);
afFaceSelectivityIndex = zeros(1,iNumUnits);
afRatio = zeros(1,iNumUnits);
abVisuallyResponsive= zeros(1,iNumUnits)>0;

fDprimeWindowMS = 51;

for iUnitIter=1:iNumUnits
    
        strctUnit = acUnits{iUnitIter};

        afMaximalResponseForSinha(iUnitIter) = max(strctUnit.m_afAvgStimulusResponseMinusBaseline(97:end)) / max(strctUnit.m_afAvgStimulusResponseMinusBaseline);
        afMaximalResponseForFace(iUnitIter) = max(strctUnit.m_afAvgStimulusResponseMinusBaseline(1:16)) / max(strctUnit.m_afAvgStimulusResponseMinusBaseline);
        
        fMeanFaceResponse = mean(strctUnit.m_afAvgStimulusResponseMinusBaseline(1:16));
        aiNumberOfStimuliGreaterThanMean(iUnitIter) = sum(strctUnit.m_afAvgStimulusResponseMinusBaseline(97:end) > fMeanFaceResponse);
        
        afMinimalResponseForSinha(iUnitIter) = min(strctUnit.m_afAvgStimulusResponseMinusBaseline(97:end)) / max(strctUnit.m_afAvgStimulusResponseMinusBaseline);
        afMinimalResponseForFace(iUnitIter) = min(strctUnit.m_afAvgStimulusResponseMinusBaseline(1:16)) / max(strctUnit.m_afAvgStimulusResponseMinusBaseline);
    
    if ~isfield(acUnits{iUnitIter},'m_acSinhaPlots')
        strctUnit = acUnits{iUnitIter};
        
        afMinimalResponseForSinha = min(strctUnit.m_afAvgStimulusResponseMinusBaseline(97:end)) / max(strctUnit.m_afAvgStimulusResponseMinusBaseline);
        afMinimalResponseForFace = min(strctUnit.m_afAvgStimulusResponseMinusBaseline(1:16)) / max(strctUnit.m_afAvgStimulusResponseMinusBaseline);
        
        
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
  
    % Compute a running window d' per cell
    fprintf('Processing %d out of %d \n',iUnitIter,length(acUnits));
 if 0
    aiPeriStimulusRangeMS = acUnits{iUnitIter}.m_strctStatParams.m_iBeforeMS:acUnits{iUnitIter}.m_strctStatParams.m_iAfterMS;
    acUnits{iUnitIter}.m_afRunningDPrime = ones(1,length(aiPeriStimulusRangeMS))*NaN;
    iHalfWindow = (fDprimeWindowMS-1)/2;
    afSmoothingKernelMS = fspecial('gaussian',[1 7*acUnits{iUnitIter}.m_strctStatParams.m_iTimeSmoothingMS],acUnits{iUnitIter}.m_strctStatParams.m_iTimeSmoothingMS);
    a2fSmoothRaster = conv2(double(acUnits{iUnitIter}.m_a2bRaster_Valid),afSmoothingKernelMS ,'same');
    abPos = acUnits{iUnitIter}.m_aiStimulusIndexValid >= 1 & acUnits{iUnitIter}.m_aiStimulusIndexValid <= 16; 
    abNeg = acUnits{iUnitIter}.m_aiStimulusIndexValid >= 17 & acUnits{iUnitIter}.m_aiStimulusIndexValid <= 96; 
    for iIter=iHalfWindow+1: length(aiPeriStimulusRangeMS)-iHalfWindow
        afResPos = mean(a2fSmoothRaster(abPos, iIter-iHalfWindow:iIter+iHalfWindow),2);
        afResNeg = mean(a2fSmoothRaster(abNeg, iIter-iHalfWindow:iIter+iHalfWindow),2);
        acUnits{iUnitIter}.m_afRunningDPrime(iIter) = fnDPrimeROC(afResPos, afResNeg);
    end
    
 end
    
    if 0
            
        fprintf('Processing %d out of %d \n',iUnitIter,length(acUnits));
        strctUnit = acUnits{iUnitIter};
        
        strctUnit.m_strctStatParams.m_iStartBaselineAvgMS = 20;
        strctUnit.m_strctStatParams.m_iEndBaselineAvgMS = 60;
        
        iNumStimuli = 549;
        aiPeriStimulusRangeMS = strctUnit.m_strctStatParams.m_iBeforeMS:strctUnit.m_strctStatParams.m_iAfterMS;
        iStartBaselineAvg = find(aiPeriStimulusRangeMS>=strctUnit.m_strctStatParams.m_iStartBaselineAvgMS,1,'first');
        iEndBaselineAvg = find(aiPeriStimulusRangeMS>=strctUnit.m_strctStatParams.m_iEndBaselineAvgMS,1,'first');
        
        
        afSmoothingKernelMS = fspecial('gaussian',[1 7*strctUnit.m_strctStatParams.m_iTimeSmoothingMS],strctUnit.m_strctStatParams.m_iTimeSmoothingMS);
        a2fSmoothRaster = conv2(double(strctUnit.m_a2bRaster_Valid),afSmoothingKernelMS ,'same');
        
        
      
        a2bStimulusCategory = strctUnit.m_a2bStimulusCategory(:,1:6);
        a2fAvgRasterCat = zeros(6,701);
        a2fAvgStdRasterCat = zeros(6,701);
        for iCatIter=1:6
            abSamplesCat = ismember(strctUnit.m_aiStimulusIndexValid, find(a2bStimulusCategory(:, iCatIter)));
            if sum(abSamplesCat) > 0
                a2fAvgRasterCat(iCatIter,:) = mean(a2fSmoothRaster(abSamplesCat,:));
                a2fAvgStdRasterCat(iCatIter,:) = std(a2fSmoothRaster(abSamplesCat,:),[],1);
            end
        end
        strctUnit.m_a2fAvgRasterCat = a2fAvgRasterCat;
        %figure;imagesc(-200:500,1:6,a2fAvgRasterCat);
        
        afBaselineRes = mean(a2fSmoothRaster(strctUnit.m_aiStimulusIndexValid>=1&strctUnit.m_aiStimulusIndexValid<=96,iStartBaselineAvg:iEndBaselineAvg),2);
        
        fMeanBaseline = mean(afBaselineRes);
        fStdBaseline= std(afBaselineRes);
     
        fMedianBaseline = median(afBaselineRes);
        fMedianAbsoluteDeviation = median( abs(afBaselineRes - fMedianBaseline));
        % Find Latency ?

        hold on;
        plot([-200 500],[fMeanBaseline fMeanBaseline],'g');
        plot([-200 500],[fMeanBaseline+2*fStdBaseline fMeanBaseline+2*fStdBaseline],'r');
        hold on;
        plot([-200 500],[fMedianBaseline fMedianBaseline],'g--');
        plot([-200 500],[fMedianBaseline+2*fMedianAbsoluteDeviation fMedianBaseline+2*fMedianAbsoluteDeviation],'r--');
           
        
        afCatMaxRes = zeros(1,6);
        afCatMaxLatencyMS = zeros(1,6);
        for iCatIter=1:6
            abAboveBaseline = a2fAvgRasterCat(iCatIter,iEndBaselineAvg:end) >= fMedianAbsoluteDeviation+2*fMedianAbsoluteDeviation;
            abBelowBaseline = a2fAvgRasterCat(iCatIter,iEndBaselineAvg:end) <= fMedianAbsoluteDeviation-2*fMedianAbsoluteDeviation;
           astrctIntervals = fnGetIntervals(abAboveBaseline|abBelowBaseline);
           if ~isempty(astrctIntervals)
               aiLengthMS = cat(1,astrctIntervals.m_iLength);
               [fDummy,iIndex]=max(aiLengthMS);
               afCatMaxRes(iCatIter) = fDummy;
               afCatMaxLatencyMS(iCatIter) = aiPeriStimulusRangeMS(astrctIntervals(iIndex).m_iStart)+strctUnit.m_strctStatParams.m_iEndBaselineAvgMS;
           end
        end
        acUnits{iUnitIter}.m_a2fAvgRasterCat = a2fAvgRasterCat;
        abVisuallyResponsive(iUnitIter) = sum(afCatMaxRes > 15) >0;
        

        
    end
    
   % 
    %i.e. g 2 std deviations above baseline to at least one category)

    % Randomly pick 16 PIP images and find whether there is one that is
    % larger than the faces.
    % Repeat this and obtain the statistic, how many times, on average,
    % from this process, elicit one that was higher.
% %     iNumRepeats = 1000;
% %     
% %     fHighestRealFaceResponse = max(acUnits{iUnitIter}.m_afAvgStimulusResponseMinusBaseline( 1:16));
% %     abResult = zeros(1,iNumRepeats)>0;
% %     for k=1:iNumRepeats
% %         % Randomly pick 16 PIP
% %         aiRandPerm = randperm(432);
% %        abResult(k) = max( acUnits{iUnitIter}.m_afAvgStimulusResponseMinusBaseline( 96+aiRandPerm(1:16))) >=fHighestRealFaceResponse;
% %     end
% %     afPercHigher(iUnitIter) = sum(abResult)/iNumRepeats * 100;
end

% % % % % % 
% % % % % % 
% % % % % % a2fTmp= zeros(300,701);
% % % % % % for k=1:300
% % % % % %     a2fTmp(k,:) = acUnits{k}.m_afRunningDPrime;
% % % % % % end
% % % % % % [afMaxDPrime,aiInd] = max(a2fTmp,[],2);
% % % % % % afLatencyToPeakMS = aiPeriStimulusRangeMS(aiInd);


% figure;hist(afPercHigher(afFaceSelectivityIndex > 0.3),0:2:100)
% aiNonResponsive = find(~abVisuallyResponsive);
% for k=1:length(aiNonResponsive)
%    figure;
%    imagesc(-200:500,1:6,acUnits{aiNonResponsive(k)}.m_a2fAvgRasterCat);
%    title(sprintf('Cell %d',aiNonResponsive(k)));
% end
% sum(afFaceSelectivityIndexUnBounded > 0.3 | afFaceSelectivityIndexUnBounded < -0.3) / length(afFaceSelectivityIndexUnBounded) * 100
% 
% sum(afFaceSelectivityIndex < -0.3)
% sum(afFaceSelectivityIndex > 0.3) / length(afFaceSelectivityIndex) * 100
[afdPrime,afdPrimeBaselineSub,afDPrimeAllTrials, afAUC,afAUCBaselineSub,afPvalue_AUC,afPvalue_AUC_BaslineSub ]=fnComputeDPrime(acUnits);
%abFaceUnits = afFaceSelectivityIndex >= 0.3;
abFaceUnits = afdPrimeBaselineSub > 0.5;
afRatio = afRatio(abFaceUnits & ~isinf(afRatio));
[afHist,afCent]=hist(afRatio,0:0.1:2);
hFig=figure(1);clf;
bar(afCent,afHist,0.7);
% ylabel('Number of units');
% xlabel('Ratio between max PIP response to max real face response');
axis([0 2.1 0 max(afHist)*1.1])
set(gcf,'Position', [761   945   479   153]);


sum(afMinimalResponseForSinha(abFaceUnits) < afMinimalResponseForFace(abFaceUnits))


fprintf('The ratio of maximal PIP response to real face response was %.2f +- %.2f\n',mean(afRatio),std(afRatio));
%saveas(hFig,'D:\Publications\Sinha\MatFigures\Figure1.fig');


return;
















function a2fTuning = fnCalcSigRatiosSinha(acUnits, fPValue)
iNumUnits = length(acUnits);
a2fTuning = zeros(iNumUnits,55);
for iUnitIter=1:iNumUnits
   strctUnit = acUnits{iUnitIter};
   [afPValue, abLarger]= fnGetAllRatios(strctUnit);
   abSig = afPValue <= fPValue;
   
   a2fTuning(iUnitIter,abSig & abLarger) =1;
   a2fTuning(iUnitIter,abSig & ~abLarger) =-1;
end
return;

function [afPValue, abLarger]= fnGetAllRatios(strctUnit)
aiAllPairs = 1:55;
a2fFiring = [strctUnit.m_afAvgFiringRateCategory(aiAllPairs+6)',strctUnit.m_afAvgFiringRateCategory(aiAllPairs+6+55)'];
afPValue = zeros(1,55);
abLarger = zeros(1,55) > 0;
for k=1:55
    afPValue(k)=strctUnit.m_a2fPValueCat((k)+6, (k)+6+55);
    abLarger(k) = a2fFiring(k,1) > a2fFiring(k,2);
end
return;





%%
function fnFigure7B()
load('D:\Data\Doris\Data For Publications\Sinha\Final Data For Revised Neuron Paper\Inverted_FullFaces');
iNumUnits=length(acUnits);

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
    
    for k=1:iNumQuat-1
        aiIndK = find(aiInd == k);
        a3fMean(k,:,iUnitIter) = mean(a2fFiringRateNormal(aiIndK,:),1);
        a3fMeanInv(k,:,iUnitIter) = mean(a2fFiringRateInv(aiIndK,:),1);
      end
      
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
Tmp = (a2fPopObjHands + a2fPopObjBodies + a2fPopObjGadgets + a2fPopObjFruits)/4;
TmpInv = (a2fPopObjHandsInv + a2fPopObjBodiesInv + a2fPopObjGadgetsInv + a2fPopObjFruitsInv)/4;

figure(70);
clf;
hold on;
grid on 
box on
plot(-200:500,  mean(a2fPopFOB),'k','LineWidth',3);
plot(-200:500,  mean(a2fPopFOBInv),'k--','LineWidth',3);
plot(-200:500, mean(Tmp),'color',[0.7 0.5 0.3],'LineWidth',3);
plot(-200:500, mean(TmpInv),'color',[0.7 0.5 0.3],'LineWidth',3,'LineStyle','--');
%xlabel('Time (ms)');
set(gca,'yticklabel',[]);

axis([-100 300 0 0.8]);
%ylabel('Normalized Average Firing Rate (Hz)');
%legend('Faces with external features (normal contrast)','Faces with external features (inverted Contrast)','Objects (normal contrast)','Objects (inverted contrast)','Location','northeastoutside');    
%set(gca,'yticklabel',[]);

return;



function fnFigure7A()
load('D:\Data\Doris\Data For Publications\Sinha\Final Data For Revised Neuron Paper\Inverted_CroppedFaces')

iNumUnits = length(acFOBEntries);

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
%%
figure(72);
clf;
hold on;
grid on 
box on
plot(-200:500,  mean(a2fPopFOB),'color',[0.4 0.4 0.4],'LineWidth',3);
plot(-200:500,  mean(a2fPopFOBInv),'color',[0.4 0.4 0.4],'LineWidth',3,'LineStyle','--');

P = [a2fPopObjHands;
     a2fPopObjBodies;
     a2fPopObjFruits;
     a2fPopObjGadgets;];
N = [a2fPopObjHandsInv;
     a2fPopObjBodiesInv;
     a2fPopObjFruitsInv;
     a2fPopObjGadgetsInv;];

plot(-200:500, mean(P,1),'LineWidth',3,'Color',1.2*[0.7 0.5 0.3]);
plot(-200:500, mean(N,1),'LineWidth',3,'Color',1.2*[0.7 0.5 0.3],'LineStyle','--');

% plot(-200:500, mean(a2fPopObjEdges),'LineWidth',3,'Color',[0.7 0.5 0.3],'LineStyle','-');

axis([-100 300 0 0.8]);
% xlabel('Time (ms)');
% ylabel('Average Normalized Firing Rate (Hz)');
grid on
box on
set(gca,'yticklabel',[]);
xlabel('Time (ms)');
%%
%legend('Faces (normal contrast)','Faces (inverted contrast)','Objects (normal contrast)','Objects (inverted contrast)','Location','NorthEastOutside');
%set(gcf,'position',[1051         485         560         368]);
%%
figure(73);
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

figure(74);
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