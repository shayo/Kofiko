function fnSinhaEdgePopulationAnalysis(acUnits,strctConfig)

%% Face Selectivity Index
[aiFaceSelectivityIndex]  = fnComputeFaceSelecitivyIndex(acUnits);
aiSubSet=1:length(acUnits);
[afH,afX]= hist(aiFaceSelectivityIndex,-1:0.1:1);
figure(1);
clf
bar(afX,afH);
hold on;
plot([0.3 0.3],[0 max(afH)],'g');
xlabel('Face Selectivity Index');
ylabel('# Units');
title(sprintf('n = %d (%d > 0.3)', length(aiFaceSelectivityIndex),length(aiSubSet)));


%% Avg Firing Rate per Category 

[aiPeriStimulusMS, a2fAvgFiringNorm,acAvgFiringNames] = fnComputePeriAvg(acUnits);
 if isempty(aiPeriStimulusMS)
     h=msgbox('Could on find any sinha experiments!');
     waitfor(h)
     return;
 end;
 
figure(2);
clf;
plot(aiPeriStimulusMS, a2fAvgFiringNorm(1:7,:)','LineWidth',2);
% hold on;
% plot([0 0],[min(a2fAvgFiringNorm(:)) max(a2fAvgFiringNorm(:))],'k');
xlabel('Time (ms)');
ylabel('Normalized Firing Rate');
legend(acAvgFiringNames(1:7),'Location','NorthEastOutside');
title(sprintf('n = %d',length(acUnits)));
grid on
fPValue = 10^-5;
[a2iSigRatio, acNames, aiSinhaRatio,abASmallerB, aiNumSignificant] = fnCalcSigRatiosSinha(acUnits, fPValue);

iNumUnits = length(acUnits);
figure(4);
clf;
hold on;
bar(a2iSigRatio(:,1));
bar(-a2iSigRatio(:,2),'facecolor','r');
ylabel('Unit Count');
xlabel('Ratio Pair');
aiPos = aiSinhaRatio(~abASmallerB);
aiNeg = aiSinhaRatio(abASmallerB);
for k=1:length(aiPos)
    arrow([aiPos(k) 0],[aiPos(k) iNumUnits/2],'facecolor','g');
end
for k=1:length(aiNeg)
    arrow([aiNeg(k) 0],[aiNeg(k) -iNumUnits/2],'facecolor','g');
end
legend('Int Part A < Int Part B','Int Part A > Int Part B','Sinha''s Proposed Ratios','Location','NorthEastOutside');
%plot(aiPos, a2iSigRatio(aiPos,1),'g*');
%plot(aiNeg, -a2iSigRatio(aiNeg,2),'g*');
axis([0 56 -iNumUnits iNumUnits]);

xlabel('Pair Index');
ylabel('Number of Units');
title(sprintf('n= %d, log_{10}(p-Value) < %.1f',iNumUnits,log10(fPValue)));

figure(12);
clf;
hist(aiNumSignificant,0:35);
grid on
xlabel('Num Significant Pairs');
ylabel('Num Cells');
title(sprintf('n= %d, log_{10}(p-Value) < %.1f',iNumUnits,log10(fPValue)));


X = abs(a2iSigRatio(:,1)-a2iSigRatio(:,2));
[afNumSig, aiSortInd] = sort(X,'descend');

figure(10);
clf;
plot(afNumSig /iNumUnits,'LineWidth',3)
xlabel('Part Pairs');
ylabel('Percent of cells tuned for this ratio');
grid on
title(sprintf('n = %d, log10(p) < %d ',iNumUnits,log10(fPValue)));
iNumDisplay = 15;
abInSinhaSet = ismember(aiSortInd(1:iNumDisplay),intersect(aiSinhaRatio, aiSortInd(1:iNumDisplay)));

aiSinhaSubset = find(abInSinhaSet);

figure(11);
clf;hold on;
barh(afNumSig(1:iNumDisplay) /iNumUnits,'LineWidth',3)
h2=plot(afNumSig(aiSinhaSubset)/iNumUnits * 1.1, aiSinhaSubset,'g*');
axis ij
set(gca,'yticklabel',acNames(aiSortInd(1:iNumDisplay)));
set(gca,'ytick',1:iNumDisplay);
xlabel('Percent of cells tuned for this ratio');
legend(h2,'Sinha Proposed Ratio' ,'Location','NorthEastOutside');
grid on

%% Draw Number of incorrect sinha ratios (population)
fnSinhaIncorrectRatioPlotAnalysis(acUnits);

%% Display Part contrast tuning for example cell
if iSelectedCell > 0
    fnDisplayExampleCellContrastTuningCurve(acUnits{iSelectedCell});
end
%% Draw Pair-wise contrast tuning for population
fnDisplayPairWiseContrast(acUnits);
title(sprintf('n = %d', length(acUnits)))
colormap  hot


%% Display part contrast tuning for populat
 fnDisplayPopulationContrastTuningCurve(acUnits)

%% Determine significance of tuning
 fnSignificantContrastRuning(acUnits);

 %% Draw Pair-wise contrast tuning for example cell
 if iSelectedCell > 0
    fnDisplayPairWiseContrastForExampleCell(acUnits(iSelectedCell));
 end



return;

function fnDisplayPairWiseContrastForExampleCell(acUnits)
acPlot = acUnits{1}.m_acSinhaPlots{5};
fMinY = min(acPlot.m_a2fIntensityResponse(:));
fMaxY = max(acPlot.m_a2fIntensityResponse(:));

figure(21);
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


function a2fBigPictureTotalAvg=fnDisplayPairWiseContrast(acUnits)
iNumUnits = length(acUnits);
acPartNames = {'Forehead','L Eye','Nose','R Eye','L Cheek','Up Lip','R Cheek','LL Cheek','Mouth','LR Cheek','Chin'};
a2iPartRatio = nchoosek(1:11,2);
iNumInt = 11;
iNumParts  = 11;

a2fBigPictureTotal = zeros(iNumParts * iNumInt, iNumParts * iNumInt);
a2iCount = zeros(iNumParts * iNumInt, iNumParts * iNumInt);
for iUnitIter=1:iNumUnits
    a2fBigPicture = NaN*ones(iNumParts * iNumInt, iNumParts * iNumInt);
    for iRatioIter = 1:size(a2iPartRatio,1)
        iPartA = a2iPartRatio(iRatioIter,1);
        iPartB = a2iPartRatio(iRatioIter,2);
        strNamePartA = acPartNames{iPartA};
        strNamePartB = acPartNames{iPartB};
        a2fBigPicture( (iPartB-1) * iNumInt + 1:(iPartB) * iNumInt ,...
            (iPartA-1) * iNumInt + 1:(iPartA) * iNumInt ) = acUnits{iUnitIter}.m_acSinhaPlots{4}.m_a3fContrast(:,:,iRatioIter);
    end
    
    a2bNotNaN = ~isnan(a2fBigPicture);
    a2iCount(a2bNotNaN) = a2iCount(a2bNotNaN) + 1;
    
    a2fBigPictureNormalized = zeros(iNumParts * iNumInt, iNumParts * iNumInt);
    a2fBigPictureNormalized(a2bNotNaN) = a2fBigPicture(a2bNotNaN) / max(a2fBigPicture(:));
    
    a2fBigPictureTotal(a2bNotNaN) = a2fBigPictureTotal(a2bNotNaN) + a2fBigPictureNormalized(a2bNotNaN);
end
a2fBigPictureTotalAvg = zeros(iNumParts * iNumInt, iNumParts * iNumInt);
a2fBigPictureTotalAvg(a2iCount > 0) = a2fBigPictureTotal(a2iCount > 0) ./ a2iCount(a2iCount > 0);
figure(23);
clf;
imagesc(a2fBigPictureTotalAvg);
hold on;
for k=0:iNumParts
    plot([0, iNumParts * iNumInt + 0.5], 0.5+[(k-1)*iNumInt (k-1)*iNumInt],'w');
    plot(0.5+[(k-1)*iNumInt (k-1)*iNumInt],[0, iNumParts * iNumInt + 0.5],'w');
    
end
for k=1:2:10
    text(0.5+k,1,num2str(k),'color','w','FontSize',6)
    text(1,0.5+k,num2str(k),'color','w','FontSize',6)
end
axis xy
set(gca,'xtick', [0:10] * 11 + 11/2,'xticklabel',acPartNames)
set(gca,'ytick', [0:10] * 11 + 11/2,'yticklabel',acPartNames)

return;


function fnSinhaIncorrectRatioPlotAnalysis(acUnits)
iNumUnits = length(acUnits);
a2fTuning = zeros(iNumUnits,13);
for iUnitIter=1:iNumUnits
    strctUnit = acUnits{iUnitIter};
    afProfile = strctUnit.m_acSinhaPlots{3}.m_afIncorrectRatioResponse;
    a2fTuning(iUnitIter,:) = afProfile / max(afProfile);
end

afX = 0:12;
afY = mean(a2fTuning,1);
afS = std(a2fTuning,1)/sqrt(iNumUnits);
figure(8);
clf;
hold on;
fill([afX, afX(end:-1:1)],[afY+afS, afY(end:-1:1)-afS(end:-1:1)], [0 1 1]);
plot(afX,afY, 'color', [0 0.3 0.3],'LineWidth',2);
set(gca,'xtick',0:12);
xlabel('Number of incorrect ratio pairs');
ylabel('Normalized firing rate');
text( max(afX)*0.8, max(afY+afS),sprintf('n = %d', iNumUnits));
legend('SEM','Mean','Location','NorthEastOutside');
%title(sprintf('n = %d',iNumUnits));
grid on
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
    M = acUnits{iUnitIter}.m_acSinhaPlots{1}.m_a2fPartIntensityMean;
    Mn = (M-min(M(:))) / (max(M(:))-min(M(:)));
    a2fAvg = a2fAvg + Mn;
end
 a2fAvg = a2fAvg / iNumUnits;
 figure(6); clf;
plot(a2fAvg(1:5,:)','LineWidth',2);hold on;
plot(a2fAvg(6:11,:)','--','LineWidth',2);
xlabel('Intensity');
ylabel('Normalized Firing Rate');
axis([1 11 0 1]);
acPartNames = {'Forehead','L Eye','Nose','R Eye','L Cheek','Up Lip','R Cheek','LL Cheek','Mouth','LR Cheek','Chin'};
legend(acPartNames,'Location','NorthEastOutside');
grid on
title(sprintf('Population Analysis. n = %d',iNumUnits));


return;


function fnDisplayExampleCellContrastTuningCurve(strctUnit)

figure(5); clf;
plot(strctUnit.m_acSinhaPlots{1}.m_a2fPartIntensityMean(1:5,:)','LineWidth',2);hold on;
plot(strctUnit.m_acSinhaPlots{1}.m_a2fPartIntensityMean(6:11,:)','--','LineWidth',2);
xlabel('Intensity');
ylabel('Avg. Firing Rate');
axis([1 11 min(strctUnit.m_acSinhaPlots{1}.m_a2fPartIntensityMean(:))-eps eps+max(strctUnit.m_acSinhaPlots{1}.m_a2fPartIntensityMean(:))]);
acPartNames = {'Forehead','L Eye','Nose','R Eye','L Cheek','Up Lip','R Cheek','LL Cheek','Mouth','LR Cheek','Chin'};
legend(acPartNames,'Location','NorthEastOutside');
grid on
title(sprintf('Cell %s, Exp %d, Ch %d, Unit %d',strctUnit.m_strRecordedTimeDate,...
    strctUnit.m_iRecordedSession,strctUnit.m_iChannel,strctUnit.m_iUnitID));
return;


function [a2iSigRatio, acNames, aiSinhaRatio, abASmallerB, aiNumSignificant] = fnCalcSigRatiosSinha(acUnits, fPValue)
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
abASmallerB = zeros(1,12) >0;
for k=1:12
aiSinhaRatio(k) = find(a2iPartRatio(:,1) == a2iCorrectEdges(k,1) & a2iPartRatio(:,2) == a2iCorrectEdges(k,2) | ...
     a2iPartRatio(:,1) == a2iCorrectEdges(k,2) & a2iPartRatio(:,2) == a2iCorrectEdges(k,1));
 abASmallerB(k) = all(a2iCorrectEdges(k,:) == a2iPartRatio(aiSinhaRatio(k) ,:));
end

iNumUnits = length(acUnits);
aiNumSignificant = zeros(1,iNumUnits);
aiPos = zeros(1,55);
aiNeg = zeros(1,55);
for iUnitIter=1:iNumUnits
   strctUnit = acUnits{iUnitIter};
   [a2fFiring,afPValue,acNames]= fnGetAllRatios(strctUnit);
   aiSig = find(afPValue <= fPValue);
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

a2fFiring = [strctUnit.m_afAvgFiringSamplesCategory(aiSinhaRatio+6),strctUnit.m_afAvgFiringSamplesCategory(aiSinhaRatio+6+55)];
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
a2fFiring = [strctUnit.m_afAvgFiringSamplesCategory(aiAllPairs+6),strctUnit.m_afAvgFiringSamplesCategory(aiAllPairs+6+55)];
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
for k=1:iNumUnits 
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

aiSelectedUnits = find(afMaxRotation == 0 & afSize == 128);
return;



function [aiFaceSelectivityIndex]  = fnComputeFaceSelecitivyIndex(acUnits)
% Compute Face Selectivity index
aiSelectedUnits = 1:length(acUnits);
iNumSelectedUnits= length(aiSelectedUnits);
aiFaceSelectivityIndex = zeros(1,iNumSelectedUnits);


fStartAvgMs = 50;
fEndAvgMs = 200;

for iUnitIter=1:iNumSelectedUnits
    fprintf('%d out of %d\n',iUnitIter,iNumSelectedUnits);
    strctUnit = acUnits{aiSelectedUnits(iUnitIter)};
    
    if ~isfield(strctUnit.m_strctStatParams,'m_fStartAvgMS')
        strctUnit.m_strctStatParams.m_fStartAvgMS = strctUnit.m_strctStatParams.m_iStartAvgMS
        strctUnit.m_strctStatParams.m_fEndAvgMS = strctUnit.m_strctStatParams.m_iEndAvgMS;
        
    end    
    
    iFaceGroup = find(ismember(strctUnit.m_acCatNames,'Faces'));
    aiNonFaceGroups = find(ismember(strctUnit.m_acCatNames,    {'Bodies',    'Fruits',    'Gadgets',    'Hands',    'Scrambled'}));
    if strctUnit.m_strctStatParams.m_fStartAvgMS == fStartAvgMs && ...
            strctUnit.m_strctStatParams.m_fEndAvgMS == fEndAvgMs 
        
        fFaceRes = strctUnit.m_afAvgFiringSamplesCategory(iFaceGroup);
        fNonFaceRes = mean(strctUnit.m_afAvgFiringSamplesCategory(aiNonFaceGroups)); 
    else
        % Re-estimate firing rates....
        iStartAvg = find(strctUnit.m_aiPeriStimulusRangeMS >= fStartAvgMs,1,'first');
        iEndAvg = find(strctUnit.m_aiPeriStimulusRangeMS >= fEndAvgMs,1,'first');

        a2fAvgFirintRate_Category_NoSmooth = 1e3 * fnAverageBy(strctUnit.m_a2bRaster_Valid, strctUnit.m_aiStimulusIndexValid, strctUnit.m_a2bStimulusCategory,0);
        afAvgFiringSamplesCategory = mean(a2fAvgFirintRate_Category_NoSmooth(:,iStartAvg:iEndAvg),2);

        fFaceRes = afAvgFiringSamplesCategory(iFaceGroup);
        fNonFaceRes = mean(afAvgFiringSamplesCategory(aiNonFaceGroups));
    end
    aiFaceSelectivityIndex(iUnitIter) =  (fFaceRes - fNonFaceRes) / (fFaceRes + fNonFaceRes);
end

return;


function  [aiPeriStimulusMS, a2fAvgFiringCat,acAvgFiringNames] = fnComputePeriAvg(acUnits)
% Compute Face Selectivity index
aiSelectedUnits = 1:length(acUnits);
iNumSelectedUnits= length(aiSelectedUnits);

a2fAvgFiringCat = zeros(8, 701);%size(acUnits{aiFOB(1)}.m_a2fAvgFirintRate_Category));

%a2fAvgFiringNorm = zeros(8, 701);%size(acUnits{aiFOB(1)}.m_a2fAvgFirintRate_Category));


acAvgFiringNames = {'Faces','Bodies','Fruits','Gadgets','Hands','Scrambled','Sinha','Pink Noise'};
fTimeSmoothingMS = 30;

for iUnitIter=1:iNumSelectedUnits
    fprintf('%d out of %d\n',iUnitIter,iNumSelectedUnits);
    strctUnit = acUnits{aiSelectedUnits(iUnitIter)};
    % Re-estimate firing rates....
%     a2fAvgFirintRate_Category_Smooth = 1e3 *  fnAverageBy(strctUnit.m_a2bRaster_Valid, ...
%         strctUnit.m_aiStimulusIndexValid, strctUnit.m_a2bStimulusCategory,fTimeSmoothingMS);
    a2fAvgFirintRate_Category_Smooth = strctUnit.m_a2fAvgFirintRate_Category / max(strctUnit.m_a2fAvgFirintRate_Category(:));
    aiSinha = find(~ismember(strctUnit.m_acCatNames,    {'Faces','Bodies',    'Fruits',    'Gadgets',    'Hands',    'Scrambled','Uniform','Background'}));
    iPinkNoise= find(ismember(strctUnit.m_acCatNames,   'Background'));
    
     a2fAvgFiringCat(1:6,:) = ( (iUnitIter-1) * a2fAvgFiringCat(1:6,:) + a2fAvgFirintRate_Category_Smooth(1:6,:)) / iUnitIter;
     a2fAvgFiringCat(7,:) = ( (iUnitIter-1) * a2fAvgFiringCat(7,:) + mean(a2fAvgFirintRate_Category_Smooth(aiSinha,:),1)) / iUnitIter;
     a2fAvgFiringCat(8,:) = ( (iUnitIter-1) * a2fAvgFiringCat(8,:) +  a2fAvgFirintRate_Category_Smooth(iPinkNoise,:)) / iUnitIter;    
     
%     fMaxRes = max(a2fAvgFirintRate_Category_Smooth(:));
%     a2fAvgFiringNorm(1:6,:) = ( (iUnitIter-1) * a2fAvgFiringNorm(1:6,:) + a2fAvgFirintRate_Category_Smooth(1:6,:)/fMaxRes) / iUnitIter;
%     a2fAvgFiringNorm(7,:) = ( (iUnitIter-1) * a2fAvgFiringNorm(7,:) + mean(a2fAvgFirintRate_Category_Smooth(aiSinha,:)/fMaxRes,1)) / iUnitIter;
%     a2fAvgFiringNorm(8,:) = ( (iUnitIter-1) * a2fAvgFiringNorm(8,:) +  a2fAvgFirintRate_Category_Smooth(iPinkNoise,:)/fMaxRes) / iUnitIter;    
     
     aiPeriStimulusMS= strctUnit.m_aiPeriStimulusRangeMS;
end

return;

