function fnMetaAnalysis(acEntries,strctConfig,handles)
iNumEntries = length(acEntries);
acEntriesIDs = cell(0);
aiEntryToUnitIndex = zeros(1,iNumEntries);
astrctUnits = [];
iUnitIndex = 0;
for iIter=1:iNumEntries
    strctEntry = acEntries{iIter};
    strUniqueID = [strctEntry.m_strRecordedTimeDate, ' Exp ',num2str(strctEntry.m_iRecordedSession), ' Ch ',num2str(strctEntry.m_iChannel), ' Unit ',num2str(strctEntry.m_iUnitID)];
    iIndex = find(ismember(acEntriesIDs, strUniqueID));
    if isempty(iIndex)
        iUnitIndex = iUnitIndex + 1;
        acEntriesIDs{iUnitIndex} = strUniqueID;
        aiEntryToUnitIndex(iIter) = iUnitIndex;
        iIndex = iUnitIndex;
        
        astrctUnits(iIndex).m_bRocco = strcmpi(strctEntry.m_strSubject,'Rocco');
        astrctUnits(iIndex).m_iFOB = -1;
        astrctUnits(iIndex).m_iSinha = -1;
        astrctUnits(iIndex).m_iCBCL = -1;
        astrctUnits(iIndex).m_iVJ = -1;
        astrctUnits(iIndex).m_fFaceSelectivity = NaN;
        astrctUnits(iIndex).m_bSigSinha = false;
        astrctUnits(iIndex).m_bSigFaceFiring = false;
        astrctUnits(iIndex).m_bHasTwoScales = false;
        
        astrctUnits(iIndex).m_fDPrimeFOB = NaN;
        astrctUnits(iIndex).m_fDPrimeCBCL = NaN;
        astrctUnits(iIndex).m_fDPrimeVJ = NaN;
        astrctUnits(iIndex).m_fDPrimeFOB_Sinha = NaN;
    else
        aiEntryToUnitIndex(iIter) = iIndex;
    end
    
    switch strctEntry.m_strParadigmDesc
        case 'StandardFOB_v2'
            astrctUnits(iIndex).m_iFOB = iIter;
            if isfield(strctEntry,'m_afAvgStimulusResponseMinusBaseline')
                strctTmp = fnComputeFaceSelecitivyIndex(strctEntry);
                astrctUnits(iIndex).m_fFaceSelectivity = strctTmp.m_fFaceSelectivityIndex;
                astrctUnits(iIndex).m_bSigFaceFiring = strctEntry.m_a2fPValueCat(1,end) < 0.05;
                astrctUnits(iIndex).m_fDPrimeFOB = fnComputeDPrime(strctEntry, 1:16,17:96);
            end
        case 'Sinha_v2_FOB'
            astrctUnits(iIndex).m_iSinha = iIter;
            astrctUnits(iIndex).m_bSigSinha = ~isempty(find(strctEntry.m_acSinhaPlots{3}.m_afPolarDiffPvalue < 1e-5));
            aiUniqueSizes = unique(strctEntry.m_strctStimulusParams.m_afStimulusSizePix);
            astrctUnits(iIndex).m_bHasTwoScales = length(aiUniqueSizes) == 2 && all(aiUniqueSizes == [64, 128]);
            astrctUnits(iIndex).m_fDPrimeFOB_Sinha = fnComputeDPrime(strctEntry, 1:16,17:96);
        case 'CMU_CBCL_Experiment'
            astrctUnits(iIndex).m_iCBCL = iIter;
            if isfield(strctEntry,'m_afAvgStimulusResponseMinusBaseline')
                astrctUnits(iIndex).m_fDPrimeCBCL = fnComputeDPrime(strctEntry, 1:207,208:411);
            end
        case 'ViolaJones'
            astrctUnits(iIndex).m_iVJ = iIter;
            if isfield(strctEntry,'m_afAvgStimulusResponseMinusBaseline')
                astrctUnits(iIndex).m_fDPrimeVJ = fnComputeDPrime(strctEntry, 1:150,151:380);
            end
            
    end
    
end

abHasTwoScales = cat(1,astrctUnits.m_bHasTwoScales);
abSigFace = cat(1,astrctUnits.m_bSigFaceFiring);
abSigSinha = cat(1,astrctUnits.m_bSigSinha);
abHasFOB = cat(1,astrctUnits.m_iFOB) > 0;
abHasSinha = cat(1,astrctUnits.m_iSinha) > 0;
abHasCBCL = cat(1,astrctUnits.m_iCBCL) > 0;
abHasVJ = cat(1,astrctUnits.m_iVJ) > 0;
afFaceSelectivity = cat(1,astrctUnits.m_fFaceSelectivity);
iNumUnits = iUnitIndex;

%% Look at d' 
aiInterstingUnits = find(abHasFOB & abHasCBCL & afFaceSelectivity > 0.3 & abSigFace );
aiFOBExperiments =  cat(1,astrctUnits(aiInterstingUnits).m_iFOB);
aiCBCLExperiments = cat(1,astrctUnits(aiInterstingUnits).m_iCBCL);
aiSinhaExperiments = cat(1,astrctUnits(aiInterstingUnits).m_iSinha);

iExpIter=3;
figure(10);
clf;

plot([acEntries{aiFOBExperiments(iExpIter)}.m_afAvgStimulusResponseMinusBaseline,acEntries{aiCBCLExperiments(iExpIter)}.m_afAvgStimulusResponseMinusBaseline]);
hold on;
plot([16 16],[-0.1 0.1],'r');
plot([96 96],[-0.1 0.1],'g');
plot([96+207 96+207],[-0.1 0.1],'c');
plot([0 560],[0 0],'k--');


figure;
plot(acEntries{aiCBCLExperiments(iExpIter)}.m_afAvgStimulusResponseMinusBaseline)

%% Correlation between CBCL and Sinha ?
iNumExp = length(aiSinhaExperiments);
strctTmp = load('D:\Code\Doris\Stimuli_Generating_Code\CBCL\CBCL_For_Electrophsy_Data.mat','a2fMedIntTrainFace','a2fMedIntTrainNonFace');
strctTmp2 = load('D:\Code\Doris\Stimuli_Generating_Code\CBCL\CBCL_SelectedPerm.mat','aiFace','aiNonFace');

a2fInt = [strctTmp.a2fAvgIntTrainFace(strctTmp2.aiFace,:);strctTmp.a2fAvgIntTrainNonFace(strctTmp2.aiNonFace,:)];
[afDummy,a2iCBCLIntensitiesInd] = sort(a2fInt,2);
    iNumPairs = nchoosek(11,2);
    a2iPairs= nchoosek(1:11,2);

a2fInt = a2fInt ./ repmat(max(a2fInt,[],2),1,11);
V = a2fInt(:,a2iPairs(:,1))-a2fInt(:,a2iPairs(:,2));

[A,B]=kmeans(V,2);

x1 = V * B(1,:)'
x2 = V * B(2,:)'

for iExpIter=1:iNumExp
    iSelectedUnit = aiInterstingUnits(iExpIter)
    strctSinhaStat = acEntries{aiSinhaExperiments(iExpIter)};
    strctCBCLStat = acEntries{aiCBCLExperiments(iExpIter)};
  
    
    [fMeanFace,fStdFace] = fnMyMean(strctCBCLStat.m_afAvgStimulusResponseMinusBaseline(1:207));
    [fMeanNonFace,fStdNonFace] = fnMyMean(strctCBCLStat.m_afAvgStimulusResponseMinusBaseline(208:end));
        
    intersect(find(strctCBCLStat.m_afAvgStimulusResponseMinusBaseline > fMeanFace+fStdFace),208:411)
    
    aiSigSinhaPairs = find(strctSinhaStat.m_acSinhaPlots{3}.m_afPolarDiffPvalue < 1e-5);
    abPolarityDirection = strctSinhaStat.m_acSinhaPlots{3}.m_afPolarityDirection(aiSigSinhaPairs); %+1 A > B, -1 A < B
    iNumSigPairs = length(aiSigSinhaPairs);
    
    % Does this cell fire MORE for a CBCL in which these pairs are correct ?
    
    a2iSelectedPairs = a2iPairs(aiSigSinhaPairs,:);
    a2iSelectedPairs(abPolarityDirection == -1,:) = a2iSelectedPairs(abPolarityDirection == -1,[2,1]);
    
    [abCorrect, aiNumWrongRatios] = fnIsCorrectPerm3(a2iCBCLIntensitiesInd, a2iSelectedPairs);
    aiNumCorrectRatios = iNumSigPairs-aiNumWrongRatios;
    [afDummy,aiSortInd] = sort(aiNumWrongRatios);
    
    
    figure;
    imagesc(mean( X(:,:,intersect(find(strctCBCLStat.m_afAvgFirintRate_Stimulus >15),208:411)), 3))
    
    afWeights = strctCBCLStat.m_afAvgFirintRate_Stimulus/max(strctCBCLStat.m_afAvgFirintRate_Stimulus);
    afWeights = afWeights / sum(afWeights);
   
    A=load('D:\Code\Doris\Stimuli_Generating_Code\CBCL\CBCL_For_Electrophsy_Data.mat');
    X = A.a3fTrainFace(:,:,strctTmp2.aiFace);
    X(:,:,208:208+204-1) = A.a3fTrainNonFace(:,:,strctTmp2.aiNonFace);
    
    W=ones(19,19,411);
    for k=1:411
        W(:,:,k) = afWeights(k);
    end;

    R = W.*X;
    figure;
    imagesc(std(R,[],3))
    
    T = sum(R,3);
    
    for k=1:411
        afM(k) = sum(sum( X(:,:,k).*T));
    end
    
    figure;
    imagesc()
    colormap jet
    
    
    R = robustfit(1:411,strctCBCLStat.m_afAvgFirintRate_Stimulus(aiSortInd));
    figure(21);clf;
    plot(strctCBCLStat.m_afAvgFirintRate_Stimulus(aiSortInd));
    hold on;
    plot(1:411,[1:411] * R(2)+R(1),'r');
    plot(1:411,double(afDummy)/1e3,'g');
    
end




%%

afDPrimeVJ = cat(1,astrctUnits(aiInterstingUnits).m_fDPrimeVJ);
afDPrimeFOB = cat(1,astrctUnits(aiInterstingUnits).m_fDPrimeFOB);
afDPrimeCBCL = cat(1,astrctUnits(aiInterstingUnits).m_fDPrimeCBCL);
T1=robustfit(afDPrimeFOB,afDPrimeCBCL);
T2=robustfit(afDPrimeFOB,afDPrimeVJ);

afX=linspace(0,4,2);
figure(12);
clf;
tightsubplot(2,2,1,'Spacing',0.15);
plot(afDPrimeFOB,afDPrimeCBCL,'.');
xlabel('d'' FOB');
ylabel('d'' CBCL');
hold on;
plot([0 4],[0 4],'k--');
plot(afX, afX*T1(2)+T1(1),'r');

tightsubplot(2,2,2,'Spacing',0.15);
plot(afDPrimeFOB,afDPrimeVJ,'.');
xlabel('d'' FOB');
ylabel('d'' VJ');
hold on;
plot([0 4],[0 4],'k--');
plot(afX, afX*T2(2)+T2(1),'r');

tightsubplot(2,2,3,'Spacing',0.15);
afCent = 0:0.2:4;
afHistFOB = hist(afDPrimeFOB,afCent);
afHistCBCL = hist(afDPrimeCBCL,afCent);
bar(afCent,[afHistFOB;afHistCBCL]');
legend('d'' FOB','d'' CBCL');
xlabel('d''');
ylabel('Num units');


tightsubplot(2,2,4,'Spacing',0.15);
afCent = 0:0.2:4;
afHistFOB = hist(afDPrimeFOB,afCent);
afHistVJ = hist(afDPrimeVJ,afCent);
bar(afCent,[afHistFOB;afHistVJ]');
legend('d'' FOB','d'' VJ');
xlabel('d''');
ylabel('Num units');

%%
set(handles.hUnitsList,'value',aiCBCLExperiments);
setappdata(handles.figure1,'aiSelectedUnits',aiCBCLExperiments);
setappdata(handles.figure1,'aiSelectedDown',1:length(aiCBCLExperiments));


%%

aiInterstingUnits = find(abHasFOB & abSigSinha &  abHasSinha & afFaceSelectivity > 0.3 & abSigFace & abHasTwoScales);
iNumInterestingUnits = length(aiInterstingUnits);

aiSinhaExp = cat(1,astrctUnits(aiInterstingUnits).m_iSinha);
afAvgLarge = zeros(1,iNumInterestingUnits);
afAvgSmall = zeros(1,iNumInterestingUnits);
figure(10);
clf;
hold on;

pThres = 1e-5;

for iIter=1:iNumInterestingUnits
    strctUnit = acEntries{aiSinhaExp(iIter)};
    
    strctUnit.m_acSinhaPlots{8}.m_a2fAvgRes128
    
    strctUnit.m_acSinhaPlots{8}.m_a2fAvgRes64
    
    afAvgLarge(iIter) = fnMyMean(strctUnit.m_acSinhaPlots{8}.m_afAvgRes128(1:16));
    afAvgSmall(iIter) = fnMyMean(strctUnit.m_acSinhaPlots{8}.m_afAvgRes64(1:16)); %97:533
    plot([0 1],[1 afAvgSmall(iIter)./afAvgLarge(iIter) ],'b');
    
    ai128Sig = find(strctUnit.m_acSinhaPlots{8}.m_afSig128<= pThres);
    ai64Sig = find(strctUnit.m_acSinhaPlots{8}.m_afSig64<= pThres);
    afShared(iIter) = length(intersect(ai128Sig,ai64Sig)) / length(union(ai128Sig,ai64Sig));
end


strctUnit = acEntries{aiSinhaExp(6)};
[X,Y]=robustfit(strctUnit.m_acSinhaPlots{8}.m_afAvgRes128,strctUnit.m_acSinhaPlots{8}.m_afAvgRes64);
afX = linspace(0,0.05,1000);

figure(12);
clf;
hold on;
plot(strctUnit.m_acSinhaPlots{8}.m_afAvgRes128,strctUnit.m_acSinhaPlots{8}.m_afAvgRes64,'r.');
plot(afX, afX*X(2)+X(1),'b');


corr(strctUnit.m_acSinhaPlots{8}.m_afAvgRes128',strctUnit.m_acSinhaPlots{8}.m_afAvgRes64')
%%
set(handles.hUnitsList,'value',aiSinhaExp);
setappdata(handles.figure1,'aiSelectedUnits',aiSinhaExp);
setappdata(handles.figure1,'aiSelectedDown',1:length(aiSinhaExp));
return;



function [acPlot0]  = fnComputeFaceSelecitivyIndex(strctUnit)
fMaximalResponseForSinha = max(strctUnit.m_afAvgStimulusResponseMinusBaseline(97:end)) / max(strctUnit.m_afAvgStimulusResponseMinusBaseline);
fMaximalResponseForFace = max(strctUnit.m_afAvgStimulusResponseMinusBaseline(1:16)) / max(strctUnit.m_afAvgStimulusResponseMinusBaseline);
fFaceRes = fnMyMean(strctUnit.m_afAvgStimulusResponseMinusBaseline(1:16));
fNonFaceRes = fnMyMean(strctUnit.m_afAvgStimulusResponseMinusBaseline(17:96));

acPlot0.m_fFaceSelectivityIndex =  (fFaceRes - fNonFaceRes) / (fFaceRes + fNonFaceRes+eps);
acPlot0.m_fRatio = fMaximalResponseForSinha/fMaximalResponseForFace;
return;

function [dPrime,fPerecentCorrect] = fnComputeDPrime(strctUnit, aiPosInd, aiNegInd)
afResPos = strctUnit.m_afAvgStimulusResponseMinusBaseline(aiPosInd);
afResPos = afResPos(~isnan(afResPos));

afResNeg = strctUnit.m_afAvgStimulusResponseMinusBaseline(aiNegInd);
afResNeg = afResNeg(~isnan(afResNeg));

fDeno = sqrt( (std(afResPos).^2+std(afResNeg).^2)/2);
dPrime = abs(mean(afResPos) - mean(afResNeg)) / (fDeno+eps);
fPerecentCorrect = normcdf(dPrime / sqrt(2)) * 100;

return;
