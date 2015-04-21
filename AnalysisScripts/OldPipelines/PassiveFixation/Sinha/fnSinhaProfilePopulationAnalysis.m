function fnSinhaProfilePopulationAnalysis(acUnits,strctConfig)

%% Face Selectivity Index
bUseStandardParamOnly = true;
bAnalyzeOnlySubSet = true;

aiNumSpikes = zeros(1,length(acUnits));
for k=1:length(acUnits)
    aiNumSpikes(k) = length(acUnits{k}.m_afSpikeTimes);
end
acUnits = acUnits(aiNumSpikes > 500);
[aiFaceSelectivityIndex]  = fnComputeFaceSelecitivyIndex(acUnits);


aiSubSet = find(aiFaceSelectivityIndex > 0.3 );
fprintf('%.2f %% face selective cells\n',sum(aiFaceSelectivityIndex>0.3)/length(aiFaceSelectivityIndex)*100);

%acUnits = fnDropFaceBias(acUnits);

[afH,afX]= hist(aiFaceSelectivityIndex,-1:0.1:1);
figure(1);
clf
bar(afX,afH);
hold on;
plot([0.3 0.3],[0 max(afH)],'g');
xlabel('Face Selectivity Index');
ylabel('# Units');
title(sprintf('n = %d (%d > 0.3)', length(aiFaceSelectivityIndex),length(aiSubSet)));



if bAnalyzeOnlySubSet
    acUnits = acUnits(aiSubSet);
end

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
acAvgFiringNames{7} = 'Part Intensity';
legend(acAvgFiringNames(1:7),'Location','NorthEastOutside');
title(sprintf('n = %d',length(acUnits)));
axis([-100 400 0.1 0.6])
grid on

%% Significant Ratios
fPValue = 10^-5;
[a2iSigRatio, acNames, aiSinhaRatio,abASmallerB, aiNumSignificant] = fnCalcSigRatiosSinha(acUnits, fPValue);

strctTmp = load('CorrectRatiosCBCL');
a2iCorrectEdges = strctTmp.a2iCorrectPairsALargerB(:,[2,1]);
acPartNames = strctTmp.acPartNames;

%%
iNumUnits = length(acUnits);
figure(4);
clf;
hold on;
ahHandles(1) = bar(a2iSigRatio(:,1));
ahHandles(2) = bar(-a2iSigRatio(:,2),'facecolor','r');
ylabel('Number of units');
xlabel('Pair Index');
fMax = max(abs(a2iSigRatio(:)));
plot([0 55],[fMax+5 fMax+5],'k--');
plot([0 55],[-fMax-5 -fMax-5],'k--');

 % Draw Predictions from monkey
 fMarkerSizeW = 0.3;
 fMarkerSizeH = 4;
 afR = linspace(0.5,1,12);
 afColors1 = [zeros(12,1),afR',afR'];

for k=1:12
    iPairIndex = aiSinhaRatio(k);
    if ~abASmallerB(k) > 0
        ahHandles(3) = fnPlotFilledTriangle(0,iPairIndex,fMax+10,fMarkerSizeW,fMarkerSizeH, afColors1(k,:));
    else
        ahHandles(3) = fnPlotFilledTriangle(1,iPairIndex,-fMax-10,fMarkerSizeW,fMarkerSizeH,afColors1(k,:));
    end

    
end

legend(ahHandles,{'Part A < Part B','Part A > Part B','Pred Profile'},'Location','NorthEastOutside');
axis([0 56 -fMax-15 fMax+15])
set(gca,'yticklabel',num2str(abs(str2num(get(gca,'ytickLabel')))));
box on
title(sprintf('n= %d, log_{10}(p-Value) < %.1f',iNumUnits,log10(fPValue)));
%%
iNumDisplay = 10;
figure(11);
clf;hold on;
a2iPartRatio = nchoosek(1:11,2);
[aiNumUnitsTuned,aiSortInd] = sort(max(a2iSigRatio,[],2),'descend');

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

barh(aiNumUnitsTuned(1:iNumDisplay) /iNumUnits);
axis ij
set(gca,'yticklabel',acTunedPairs);
set(gca,'ytick',1:iNumDisplay);
xlabel('Percent of cells with siginifcant tuning');
%legend(h2,'Sinha Proposed Ratio' ,'Location','NorthEastOutside');
grid on
axis([0 0.7 0 11])
box on


fnDisplayPopulationContrastTuningCurve(acUnits)

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
 
acPartNamesFrontal = {'Forehead','L Eye','Nose','R Eye','L Cheek','Up Lip','R Cheek','LL Cheek','Mouth','LR Cheek','Chin'};
acPartNamesProfile = {'Nose'    'Mouth'    'Up Lip'    'Forehead'    'Chin'    'L Cheek'    'R Cheek'    'R Eye'    'L Eye'    'L Eyebrow'    'R Eyebrow'};
aiFrontalToProfileIndex = zeros(1,11);
for k=1:length(acPartNamesFrontal)
    iIndex= find(ismember(acPartNamesProfile,acPartNamesFrontal{k}));
    if ~isempty(iIndex)
        aiFrontalToProfileIndex(k) = iIndex;
    end;
end 
figure(6);
clf;
hold on;
aiColors = lines(6);
for j=1:5
    plot(1:11,a2fAvg(aiFrontalToProfileIndex(j),:),'Color',aiColors(j,:),'LineWidth',2)
end
for j=1:6
    if aiFrontalToProfileIndex(5+j) ~= 0
        plot(1:11,a2fAvg(aiFrontalToProfileIndex(5+j),:),'Color',aiColors(j,:),'LineWidth',2,'LineStyle','--')
    end
end
xlabel('Intensity');
ylabel('Normalized Firing Rate');
axis([1 11 0.1 0.7]);
legend(acPartNamesFrontal(aiFrontalToProfileIndex~=0),'Location','NorthEastOutside');
axis([1 11 0.1 0.7])
set(gca,'xtick',1:11)

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


function [a2iSigRatio, acNames, aiSinhaRatio, abASmallerB, aiNumSignificant] = fnCalcSigRatiosSinha(acUnits, fPValue)
%a2iSigRatio is a 55 x 2
% where, :,1 is the number of cells tuned for the positive polarity
% and :,2 is the number of cells tuned for the negative polarity

a2iPartRatio = nchoosek(1:11,2);

strctTmp = load('CorrectRatiosCBCL');
a2iCorrectEdges = strctTmp.a2iCorrectPairsALargerB(:,[2,1]);

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


function [aiFaceSelectivityIndex]  = fnComputeFaceSelecitivyIndex(acUnits)

iNumExperiments = length(acUnits);
abSinhaFOBExperiments = zeros(1,iNumExperiments) > 0;
abSinhaFOBv2Experiments = zeros(1,iNumExperiments) > 0;
for k=1:iNumExperiments
    abSinhaFOBExperiments(k) =  strcmp(acUnits{k}.m_strImageListDescrip,'SinhaFOB');
    abSinhaFOBv2Experiments(k) =  strcmp(acUnits{k}.m_strImageListDescrip,'Sinha_v2_FOB') || ...
        strcmp(acUnits{k}.m_strImageListDescrip,'Sinha_v2_FOB_SecondTemplate')|| ...
        strcmp(acUnits{k}.m_strImageListDescrip,'Sinha_v2_FOB_LP_16')|| ...
        strcmp(acUnits{k}.m_strImageListDescrip,'Sinha_Profile')|| ...
    strcmp(acUnits{k}.m_strImageListDescrip,'Sinha_v2_FOB_LP_32');
    
    
end

abSelectedUnits = abSinhaFOBv2Experiments | abSinhaFOBExperiments;
% Compute Face Selectivity index
aiSelectedUnits = find(abSelectedUnits);
iNumSelectedUnits= length(aiSelectedUnits);
aiFaceSelectivityIndex = zeros(1,iNumSelectedUnits);


fStartAvgMs = 50;
fEndAvgMs = 200;
afMaximalResponseForSinha = zeros(1,iNumSelectedUnits);
afMaximalResponseForFace = zeros(1,iNumSelectedUnits);
for iUnitIter=1:iNumSelectedUnits
    fprintf('%d out of %d\n',iUnitIter,iNumSelectedUnits);
    strctUnit = acUnits{aiSelectedUnits(iUnitIter)};
    
    afMaximalResponseForSinha(iUnitIter) = max(strctUnit.m_afAvgFirintRate_Stimulus(97:end)) / max(strctUnit.m_afAvgFirintRate_Stimulus);
    afMaximalResponseForFace(iUnitIter) = max(strctUnit.m_afAvgFirintRate_Stimulus(1:16)) / max(strctUnit.m_afAvgFirintRate_Stimulus);
    
    iFaceGroup = find(ismember(strctUnit.m_acCatNames,'Faces'));
    aiNonFaceGroups = find(ismember(strctUnit.m_acCatNames,    {'Bodies',    'Fruits',    'Gadgets',    'Hands',    'Scrambled'}));
    if ~isfield(strctUnit.m_strctStatParams,'m_iStartAvgMS')
        strctUnit.m_strctStatParams.m_iStartAvgMS = strctUnit.m_strctStatParams.m_fStartAvgMS;
        strctUnit.m_strctStatParams.m_iEndAvgMS = strctUnit.m_strctStatParams.m_fEndAvgMS;
    end
    
    if strctUnit.m_strctStatParams.m_iStartAvgMS == fStartAvgMs && ...
            strctUnit.m_strctStatParams.m_iEndAvgMS == fEndAvgMs 
        
        fFaceRes = strctUnit.m_afAvgFiringSamplesCategory(iFaceGroup);
        fNonFaceRes = mean(strctUnit.m_afAvgFiringSamplesCategory(aiNonFaceGroups)); 
    else
        % Re-estimate firing rates....
        iStartAvg = find(strctUnit.m_aiPeriStimulusRangeMS >= fStartAvgMs,1,'first');
        iEndAvg = find(strctUnit.m_aiPeriStimulusRangeMS >= fEndAvgMs,1,'first');

        
        afAvgFiringSamplesCategory = mean(strctUnit.m_a2fAvgFirintRate_Category(:,iStartAvg:iEndAvg),2);
        
%        a2fAvgFirintRate_Category_NoSmooth = 1e3 * fnAverageBy(strctUnit.m_a2bRaster_Valid, strctUnit.m_aiStimulusIndexValid, strctUnit.m_a2bStimulusCategory,0);
%        afAvgFiringSamplesCategory = mean(a2fAvgFirintRate_Category_NoSmooth(:,iStartAvg:iEndAvg),2);

        fFaceRes = afAvgFiringSamplesCategory(iFaceGroup);
        fNonFaceRes = mean(afAvgFiringSamplesCategory(aiNonFaceGroups));
    end
    aiFaceSelectivityIndex(iUnitIter) =  (fFaceRes - fNonFaceRes) / (fFaceRes + fNonFaceRes);
end
abFaceUnits = aiFaceSelectivityIndex>=0.3;
return;

function  [aiPeriStimulusMS, a2fAvgFiringCat,acAvgFiringNames] = fnComputePeriAvg(acUnits)

iNumExperiments = length(acUnits);
abSinhaFOBExperiments = zeros(1,iNumExperiments) > 0;
abSinhaFOBv2Experiments = zeros(1,iNumExperiments) > 0;
for k=1:iNumExperiments
    abSinhaFOBExperiments(k) =  strcmp(acUnits{k}.m_strImageListDescrip,'SinhaFOB');
    abSinhaFOBv2Experiments(k) =  strcmp(acUnits{k}.m_strImageListDescrip,'Sinha_v2_FOB') || ...
        strcmp(acUnits{k}.m_strImageListDescrip,'Sinha_v2_FOB_SecondTemplate')|| ...
        strcmp(acUnits{k}.m_strImageListDescrip,'Sinha_v2_FOB_LP_16')|| ...
        strcmp(acUnits{k}.m_strImageListDescrip,'Sinha_Profile')|| ...
        strcmp(acUnits{k}.m_strImageListDescrip,'Sinha_v2_FOB_LP_32');
    
end

abSelectedUnits = abSinhaFOBv2Experiments | abSinhaFOBExperiments;
if all(abSelectedUnits == 0)
    aiPeriStimulusMS = [];
    a2fAvgFiringCat = [];
    acAvgFiringNames = [];
    return;
end;
% Compute Face Selectivity index
aiSelectedUnits = find(abSelectedUnits);
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

