function fnStandardPopulationAnalysis(acUnits, strctConfig)
%%
%pThreshold = 1e-8;

iNumExperiments = length(acUnits);
abFOBExperiments = zeros(1,iNumExperiments) > 0;
for k=1:iNumExperiments
    abFOBExperiments(k) =  strcmp(acUnits{k}.m_strImageListDescrip,'FOB');
end

% Compute Face Selectivity index
aiFOB = find(abFOBExperiments);
iNumFOBExperiments = length(aiFOB);
aiFaceSelectivityIndex = zeros(1,iNumFOBExperiments);


a2fAvgFiringCat = zeros(6, 701);%size(acUnits{aiFOB(1)}.m_a2fAvgFirintRate_Category));

for iExpIter=1:iNumFOBExperiments
    iFaceGroup = find(ismember(acUnits{aiFOB(iExpIter)}.m_acCatNames,'Faces'));
    aiNonFaceGroups = find(ismember(acUnits{aiFOB(iExpIter)}.m_acCatNames,    {'Bodies',    'Fruits',    'Gadgets',    'Hands',    'Scrambles'}));
    fFaceRes = acUnits{aiFOB(iExpIter)}.m_afAvgFiringSamplesCategory(iFaceGroup);
    fNonFaceRes = mean(acUnits{aiFOB(iExpIter)}.m_afAvgFiringSamplesCategory(aiNonFaceGroups));
    aiFaceSelectivityIndex(iExpIter) =  (fFaceRes - fNonFaceRes) / (fFaceRes + fNonFaceRes);
    a2fAvgFiringCat(1:6,:) = ( (iExpIter-1) * a2fAvgFiringCat(1:6,:) + acUnits{aiFOB(iExpIter)}.m_a2fAvgFirintRate_Category(1:6,:)) / iExpIter;
    
%     aiPeriStimulusRangeMS = acUnits{aiFOB(iExpIter)}.m_strctStatParams.m_fBeforeMS:acUnits{aiFOB(iExpIter)}.m_strctStatParams.m_fAfterMS;
%     iStartAvg = find(aiPeriStimulusRangeMS>=acUnits{aiFOB(iExpIter)}.m_strctStatParams.m_fStartAvgMS,1,'first');
%     iEndAvg = find(aiPeriStimulusRangeMS>=acUnits{aiFOB(iExpIter)}.m_strctStatParams.m_fEndAvgMS,1,'first');
% 
% 
%     a2fAvgFiringCat(7,:) = ( (iExpIter-1) * a2fAvgFiringCat(7,:) + mean(acUnits{aiFOB(iExpIter)}.m_a2fAvgFirintRate_Stimulus(97:338,:),1)) / iExpIter;
%     a2fAvgFiringCat(8,:) = ( (iExpIter-1) * a2fAvgFiringCat(8,:) + mean(acUnits{aiFOB(iExpIter)}.m_a2fAvgFirintRate_Stimulus(96+243:96+25,:),1)) / iExpIter;
%     a2fAvgFiringCat(9,:) = ( (iExpIter-1) * a2fAvgFiringCat(9,:) + mean(acUnits{aiFOB(iExpIter)}.m_a2fAvgFirintRate_Stimulus(96+253:96+255,:),1)) / iExpIter;
end



figure;
clf;
subplot(1,2,1);
[aiCount, afCent] = hist(aiFaceSelectivityIndex);
bar(afCent,aiCount)
grid on
hold on;
plot([1/3 1/3],[0 max(aiCount)],'g','linewidth',2);
axis([-1 1 0 max(aiCount)]);
title('Face Selectivity Index');
xlabel('Index');
ylabel('# Cells');

subplot(1,2,2);
plot(acUnits{aiFOB(1)}.m_aiPeriStimulusRangeMS, a2fAvgFiringCat','LineWidth',2);
legend([acUnits{aiFOB(1)}.m_acCatNames(1:6)]);%,'Sinha','Sinha Scrambled','Pink Noise'],'FontSize',6);
xlabel('Time (ms)');
ylabel('Firing Rate (Hz)');
title('Average Firing Rate');
grid on


return;


% % % % %% Sinha Population Anaylsis
% % % % global g_a3iAllSinhaStimuli
% % % % if isempty(g_a3iAllSinhaStimuli)
% % % %     strImageList = 'C:\Shay\Data\StimulusSet\Sinha_randbackAndControl\128x128\List.txt';
% % % %     if ~exist(strImageList)
% % % %         strImageList= 'D:\Data\Doris\Stimuli\Sinha_randbackAndControl\128x128\List.txt';
% % % %     end
% % % %     [acFileNames] = fnReadImageList(strImageList);
% % % %     I = imread(acFileNames{1});
% % % %     g_a3iAllSinhaStimuli = zeros([size(I), length(acFileNames)]);
% % % %     for k=1:length(acFileNames)
% % % %         g_a3iAllSinhaStimuli(:,:,k) = imread(acFileNames{k});
% % % %     end
% % % % 
% % % % end
% % % % 
% % % % abSinhaExperiments = zeros(1,iNumExperiments) > 0;
% % % % for k=1:iNumExperiments
% % % %     abSinhaExperiments(k) =  strcmp(acUnits{k}.m_strImageListDescrip,'SinhaFOB');
% % % % end
% % % % 
% % % % aiSinha= find(abSinhaExperiments);
% % % % 
% % % % 
% % % % 
% % % % %% Which ratios are most likely to be significant?
% % % % iNumRatios = nchoosek(11,2);
% % % % aiSigCat = zeros(1,iNumRatios);
% % % % aiSigCatCorr = zeros(1,iNumRatios);
% % % % aiNumSignificant = zeros(1,length(aiSinha));
% % % % aiNumSignificantCorr= zeros(1,length(aiSinha));
% % % % for iExpIter=1:length(aiSinha)
% % % %     iExperiment = aiSinha(iExpIter);
% % % %     switch acUnits{iExperiment}.m_strImageListDescrip
% % % %         case 'SinhaFOB'
% % % %             aiCatInd = 7:7+iNumRatios-1;
% % % %         case 'Sinha'
% % % %             aiCatInd = 1:iNumRatios;
% % % %     end
% % % %     aiY = aiCatInd;
% % % %     aiX = aiCatInd+iNumRatios;
% % % %     aiInd = sub2ind(size(acUnits{iExperiment}.m_a2bSignificantCat), aiY,aiX);
% % % %     afPvalues = acUnits{iExperiment}.m_a2fPValueCat(aiInd);
% % % %     
% % % %     abSigCat = acUnits{iExperiment}.m_a2bSignificantCat(aiInd);
% % % %     abSigCatCorr = acUnits{iExperiment}.m_a2bSignificantCat_BCorr(aiInd);
% % % %     aiSigCat = aiSigCat + double(abSigCat);
% % % %     aiSigCatCorr = aiSigCatCorr + double(abSigCatCorr);
% % % %     aiNumSignificant(iExpIter) = sum(afPvalues <= pThreshold) ; %sum(abSigCat);
% % % %     
% % % % %    pThreshold
% % % %     
% % % %     aiNumSignificantCorr(iExpIter) = sum(abSigCatCorr);
% % % %    
% % % % end
% % % % 
% % % % % subplot(2,3,3);cla;hold on;
% % % % % h1=bar(1:iNumRatios,aiSigCat/length(aiSinha) * 100);
% % % % % hold on;
% % % % % h2=bar(1:iNumRatios,aiSigCatCorr/length(aiSinha) * 100,'faceColor','r');
% % % % % legend([h1,h2],{'p = 5e-2','p = 1e-5'});
% % % % % xlabel('Ratio Category');
% % % % % ylabel('Percentage of units');
% % % % % title(sprintf('Significant Categories (100%% = %d)',length(aiSinha)));
% % % % subplot(2,3,4);
% % % % [afH,afC]=hist(aiNumSignificantCorr,1:55);
% % % % bar(afC,afH);
% % % % xlabel(sprintf('No. Significant ratios with p < 1e^{%d} ',log10(pThreshold)));
% % % % ylabel('Num Units');
% % % % set(gca,'ytick',[1:max(afH)]);
% % % % grid on
% % % % %iNumUnitsWithSignificantAct = sum(aiNumSignificant>0);
% % % % %iNumUnitsWithoutSignificantAct = sum(aiNumSignificant==0);
% % % % 
% % % % %iNumUnitsWithSignificantActCorr = sum(aiNumSignificantCorr>0);
% % % % %iNumUnitsWithoutSignificantActCorr = sum(aiNumSignificantCorr==0);
% % % % 
% % % % %bar([iNumUnitsWithSignificantAct, iNumUnitsWithoutSignificantAct;iNumUnitsWithSignificantActCorr,iNumUnitsWithoutSignificantActCorr])
% % % % %legend({'+ Has sig'' cat','- No Sig'});
% % % % %set(gca,'Xticklabel',{'p<5e-2','p<1e-5'})
% % % % %%
% % % % strctTmp = load('SelectedPerm');
% % % % a2iEdges = double([strctTmp.a2iCorrectPerm;strctTmp.a2iSelectedIncorrectPerm]);
% % % % a2iPartRatio = nchoosek(1:11,2);
% % % % afHistCent = -10:10;
% % % % 
% % % % aiRatioLinear = [];
% % % % aiRatioEdge= [];
% % % % aiLinearEdge = [];
% % % % 
% % % % abRight = afHistCent > 0;
% % % % abLeft = afHistCent < 0;
% % % % 
% % % % afConsistencyPos = zeros(1, iNumRatios);
% % % % afConsistencyNeg = zeros(1, iNumRatios);
% % % % iNumParts = 11;
% % % % a2fAvgResPartPop = zeros(iNumParts,iNumParts);
% % % % a3fAvgResPart= zeros(iNumParts,iNumParts,length(aiSinha));
% % % % 
% % % % for iExpIter=1:length(aiSinha)
% % % %     iExperiment = aiSinha(iExpIter);
% % % %     switch acUnits{iExperiment}.m_strImageListDescrip
% % % %         case 'SinhaFOB'
% % % %             aiCatInd = 7:7+iNumRatios-1;
% % % %             iOffset = 96;
% % % %         case 'Sinha'
% % % %             aiCatInd = 1:iNumRatios;
% % % %             iOffset = 0;
% % % %     end
% % % %     aiY = aiCatInd;
% % % %     aiX = aiCatInd+iNumRatios;
% % % %     aiInd = sub2ind(size(acUnits{iExperiment}.m_a2bSignificantCat), aiY,aiX);
% % % %     [afPValue, aiSortInd] = sort(acUnits{iExperiment}.m_a2fPValueCat(aiInd));
% % % %     aiPeriStimulusRangeMS = acUnits{iExperiment}.m_strctStatParams.m_iBeforeMS:acUnits{iExperiment}.m_strctStatParams.m_iAfterMS;
% % % %     iStartAvg = find(aiPeriStimulusRangeMS>=acUnits{iExperiment}.m_strctStatParams.m_fStartAvgMS,1,'first');
% % % %     iEndAvg = find(aiPeriStimulusRangeMS>=acUnits{iExperiment}.m_strctStatParams.m_fEndAvgMS,1,'first');
% % % %     afAvgStimulusResponse = mean(acUnits{iExperiment}.m_a2fAvgFirintRate_Stimulus(:,iStartAvg:iEndAvg),2);
% % % % 
% % % %     aiSigRatios = aiSortInd(afPValue<=pThreshold);
% % % % 
% % % %     % Average part intensity profile
% % % %     
% % % %     iStartBaseAvg = find(aiPeriStimulusRangeMS>=acUnits{iExperiment}.m_strctStatParams.m_fStartBaselineAvgMS,1,'first');
% % % %     iEndBaseAvg = find(aiPeriStimulusRangeMS>=acUnits{iExperiment}.m_strctStatParams.m_fEndBaselineAvgMS,1,'first');
% % % %     afBaseline = median(acUnits{iExperiment}.m_a2fAvgFirintRate_Stimulus(:,iStartBaseAvg:iEndBaseAvg),2);
% % % %     
% % % %     a2fAvgResPart = zeros(iNumParts,iNumParts);
% % % %     for iPartIter=1:iNumParts
% % % %         for iIntIter=1:iNumParts
% % % %             aiRelevant = find(a2iEdges(:,iPartIter) == iIntIter);
% % % %             a2fAvgResPart(iPartIter, iIntIter) = median(afAvgStimulusResponse(iOffset + aiRelevant)-afBaseline(iOffset + aiRelevant));
% % % %         end
% % % %     end
% % % %     a3fAvgResPart(:,:, iExpIter) = a2fAvgResPart;
% % % %     a2fAvgResPartPop = a2fAvgResPartPop + a2fAvgResPart;
% % % %     %
% % % %     for iRatioIter= 1:length(aiSigRatios);
% % % %         iRatio=aiSigRatios(iRatioIter);
% % % %         iPartA = a2iPartRatio(iRatio,1);
% % % %         iPartB = a2iPartRatio(iRatio,2);
% % % % 
% % % %         %
% % % %         
% % % %         
% % % %         
% % % %         %
% % % % 
% % % %         aiAB = find(a2iEdges(:,iPartA)>a2iEdges(:,iPartB));
% % % %         aiBA = find(a2iEdges(:,iPartA)<a2iEdges(:,iPartB)) ;
% % % %         if mean(afAvgStimulusResponse(iOffset+aiAB)) > mean(afAvgStimulusResponse(iOffset+aiBA))
% % % %             afConsistencyPos(iRatio) = afConsistencyPos(iRatio) + 1;
% % % %         else
% % % %             afConsistencyNeg(iRatio) = afConsistencyNeg(iRatio) + 1;
% % % %         end;
% % % % 
% % % % 
% % % %         %      aiAB = find(a2iEdges(:,iPartA)>a2iEdges(:,iPartB));
% % % %         %      aiBA = find(a2iEdges(:,iPartA)<a2iEdges(:,iPartB)) ;
% % % %         %      ranksum(afAvgStimulusResponse(iOffset+aiBA),afAvgStimulusResponse(iOffset+aiAB))
% % % %         %
% % % %         afAvgRes = NaN*ones(1,length(afHistCent));
% % % %         afAvgResStd = NaN*ones(1,length(afHistCent));
% % % %         for k=1:length(afHistCent)
% % % %             aiInd = find(a2iEdges(:,iPartA)-a2iEdges(:,iPartB) ==  afHistCent(k));
% % % %             if ~isempty(aiInd)
% % % %                 afAvgRes(k) = median(afAvgStimulusResponse(iOffset+aiInd));
% % % %                 afAvgResStd(k) = std(afAvgStimulusResponse(iOffset+aiInd));
% % % %             end;
% % % %         end
% % % %         abValid = ~isnan(afAvgRes);
% % % %         [afCurve]=robustfit(afHistCent(abValid), afAvgRes(abValid));
% % % %         aiRatioLinear(end+1) = corr(afAvgRes(abValid)', afCurve(2)*afHistCent(abValid)'+afCurve(1));
% % % %         afModel = [ones(1,10)*median(afAvgRes(1:10)), NaN, ones(1,10)*median(afAvgRes(12:end))];
% % % %         aiRatioEdge(end+1) = corr(afAvgRes(abValid)',afModel(abValid)');
% % % % 
% % % %         [afCurveR]=robustfit(afHistCent(abRight & abValid), afAvgRes(abRight & abValid));
% % % %         [afCurveL]=robustfit(afHistCent(abLeft & abValid), afAvgRes(abLeft & abValid));
% % % % 
% % % %         afModel1 = [ones(1,10)*median(afAvgRes(1:10)), NaN, [12:21] *afCurveR(2) + afCurveR(1) ];
% % % %         afModel2 = [[1:10] *afCurveL(2) + afCurveL(1), NaN, ones(1,10)*median(afAvgRes(12:21))];
% % % %         fCorr1 = corr(afAvgRes(abValid)',afModel1(abValid)');
% % % %         fCorr2 = corr(afAvgRes(abValid)',afModel2(abValid)');
% % % %         aiLinearEdge(end+1) = max(fCorr1,fCorr2) ;
% % % % 
% % % % 
% % % %     end
% % % % end
% % % % 
% % % % subplot(2,3,5);cla;
% % % % [afH1,afC]=hist(aiRatioLinear.^2,0:0.1:1);
% % % % bar(afC,afH1);
% % % % hold on;
% % % % [afH2,afC]=hist(aiRatioEdge.^2,0:0.1:1);
% % % % bar(afC,-afH2,'facecolor','r');
% % % % axis([0 1, -max(afH2) max(afH1)]);
% % % % xlabel('R^2 ');
% % % % %ylabel('R^2 Edge model');
% % % % ylabel('Number of ratios');
% % % % title(sprintf('Model fit for ratios with p < 1e^{%d} ',log10(pThreshold)));
% % % % legend({'Linear','Edge'},'FontSize',5);
% % % % 
% % % % subplot(2,3,3);cla;hold on;
% % % % bar(afConsistencyPos,'FaceColor','b'); hold on;
% % % % bar(-afConsistencyNeg,'FaceColor','r')
% % % % xlabel('Ratio Category');
% % % % ylabel('Number of units');
% % % % title(sprintf('Contrast Consistency for significant Ratios with p < 1e^{%d} ',log10(pThreshold)));
% % % % 
% % % % aiAB = find(afConsistencyPos > 0);
% % % % aiBA = find(afConsistencyNeg > 0);
% % % % 
% % % % %%
% % % % % addpath('D:\Code\Doris\Stimuli_Generating_Code\');
% % % % % load('D:\Code\Doris\Stimuli_Generating_Code\AllPerm');
% % % % % abInCorrect = zeros(1,size(P,1),'uint8') > 0;
% % % % % for k=1:length(aiAB)
% % % % %     abInCorrect(P(:,a2iPartRatio(aiAB(k),1)) < P(:,a2iPartRatio(aiAB(k),2))) = 1;
% % % % % end
% % % % % for k=1:length(aiBA)
% % % % %     abInCorrect(P(:,a2iPartRatio(aiBA(k),1)) > P(:,a2iPartRatio(aiBA(k),2))) = 1;
% % % % % end
% % % % % load('D:\Code\Doris\Stimuli_Generating_Code\a3bPartMasks');
% % % % % aiCorrect = find(~abInCorrect);
% % % % % afPartIntensities  = linspace(0.1,0.9, 11);
% % % % % figure(10);
% % % % % a2AvgfImage = zeros(613,613);
% % % % % for j=1:length(aiCorrect)
% % % % %     a2fImage = fnGenSinhaAux( a3bPartMasks, afPartIntensities(P(aiCorrect(j),:)));
% % % % %     a2AvgfImage = a2AvgfImage + a2fImage;
% % % % % end
% % % % % 
% % % % % figure;
% % % % % imshow(a2fImage,[]);
% % % % 
% % % % %%
% % % % subplot(2,3,6);
% % % % a2iContastRatioMatrix = zeros(11,11)*NaN;
% % % % 
% % % % for iRatioIter=1:55
% % % %     a2iContastRatioMatrix(a2iPartRatio(iRatioIter,1),a2iPartRatio(iRatioIter,2)) = ...
% % % %         afConsistencyPos(iRatioIter)>0;
% % % %     a2iContastRatioMatrix(a2iPartRatio(iRatioIter,2),a2iPartRatio(iRatioIter,1)) = ...
% % % %         -(afConsistencyNeg(iRatioIter)>0);
% % % % end;
% % % % acPartNames = {'1 Forehead','2 L Eye','3 Nose','4 R Eye','5 L Cheek','6 Up Lip','7 R Cheek','8 LL Cheek','9 Mouth','10 LR Cheek','11 Chin'};
% % % % 
% % % % imagesc(a2iContastRatioMatrix);
% % % % hold on;
% % % % plot([0 11.5],[0 11.5],'r','LineWidth',5);
% % % % set(gca,'ytick',1:11,'ytickLabel',acPartNames);
% % % % set(gca,'xtick',1:11);
% % % % 
% % % % a2fAvgResPartPop = a2fAvgResPartPop/   length(aiSinha);       
% % % % figure(2);
% % % % clf;
% % % % tightsubplot(2,2,1,'Spacing',0.1);
% % % % plot(a2fAvgResPartPop(1:5,:)','LineWidth',2)
% % % % hold on;
% % % % plot(a2fAvgResPartPop(6:11,:)','LineWidth',2,'LineStyle','-.')
% % % % legend(acPartNames,'FontSize',7)
% % % % grid on
% % % % xlabel('Intensity (low = dark)');
% % % % ylabel('Response (- baseline)');
% % % % title('Population anaylsis');
% % % % figure(5);
% % % % clf;
% % % % for j=1:size(a3fAvgResPart,3)
% % % %     tightsubplot(5,5,j);
% % % %     imagesc(a3fAvgResPart(:,:,j));
% % % % end;
% % % %     tightsubplot(5,5,25);
% % % % 
% % % % imagesc(median(a3fAvgResPart,3))
% % % % 
% % % % %%
% % % % % Most powerful relationships
% % % % [afDummy, aiSortIdx] = sort(afConsistencyNeg + afConsistencyPos,'descend');
% % % % 
% % % % iSelectedRatioPop = aiSortIdx(1);
% % % % AvgResPop = zeros(1,21);
% % % % iCounter = 0;
% % % % for iExpIter=1:length(aiSinha)
% % % %     iExperiment = aiSinha(iExpIter);
% % % %     switch acUnits{iExperiment}.m_strImageListDescrip
% % % %         case 'SinhaFOB'
% % % %             aiCatInd = 7:7+iNumRatios-1;
% % % %             iOffset = 96;
% % % %         case 'Sinha'
% % % %             aiCatInd = 1:iNumRatios;
% % % %             iOffset = 0;
% % % %     end
% % % %     aiY = aiCatInd;
% % % %     aiX = aiCatInd+iNumRatios;
% % % %     aiInd = sub2ind(size(acUnits{iExperiment}.m_a2bSignificantCat), aiY,aiX);
% % % %     afPValue = acUnits{iExperiment}.m_a2fPValueCat(aiInd);
% % % %     aiPeriStimulusRangeMS = acUnits{iExperiment}.m_strctStatParams.m_iBeforeMS:acUnits{iExperiment}.m_strctStatParams.m_iAfterMS;
% % % %     iStartAvg = find(aiPeriStimulusRangeMS>=acUnits{iExperiment}.m_strctStatParams.m_fStartAvgMS,1,'first');
% % % %     iEndAvg = find(aiPeriStimulusRangeMS>=acUnits{iExperiment}.m_strctStatParams.m_fEndAvgMS,1,'first');
% % % %     iStartBaseAvg = find(aiPeriStimulusRangeMS>=acUnits{iExperiment}.m_strctStatParams.m_fStartBaselineAvgMS,1,'first');
% % % %     iEndBaseAvg = find(aiPeriStimulusRangeMS>=acUnits{iExperiment}.m_strctStatParams.m_fEndBaselineAvgMS,1,'first');
% % % % 
% % % %     afAvgStimulusResponse = mean(acUnits{iExperiment}.m_a2fAvgFirintRate_Stimulus(:,iStartAvg:iEndAvg),2);
% % % %     afBaseline = mean(acUnits{iExperiment}.m_a2fAvgFirintRate_Stimulus(:,iStartBaseAvg:iEndBaseAvg),2);
% % % %         
% % % %     if 1 %afPValue(iSelectedRatioPop) <=pThreshold
% % % %         iCounter = iCounter + 1;
% % % %         a2fAvgResPart = zeros(iNumParts,iNumParts);
% % % %         for iPartIter=1:iNumParts
% % % %             for iIntIter=1:iNumParts
% % % %                 aiRelevant = find(a2iEdges(:,iPartIter) == iIntIter);
% % % %                 a2fAvgResPart(iPartIter, iIntIter) = mean(afAvgStimulusResponse(iOffset + aiRelevant))-mean(afBaseline(iOffset + aiRelevant));
% % % %             end
% % % %         end
% % % %         
% % % %         iRatio=iSelectedRatioPop;
% % % %         iPartA = a2iPartRatio(iRatio,1);
% % % %         iPartB = a2iPartRatio(iRatio,2);
% % % %  
% % % %         afAvgRes = NaN*ones(1,length(afHistCent));
% % % %        for k=1:length(afHistCent)
% % % %             aiInd = find(a2iEdges(:,iPartA)-a2iEdges(:,iPartB) ==  afHistCent(k));
% % % %             if ~isempty(aiInd)
% % % %                 afAvgRes(k) = mean(afAvgStimulusResponse(iOffset+aiInd)) - mean(afBaseline(iOffset+aiInd));
% % % %             end;
% % % %        end
% % % %         AvgResPop = AvgResPop + afAvgRes;
% % % % %        abValid = ~isnan(afAvgRes);
% % % %     
% % % %     end
% % % % end
% % % % 
% % % % tightsubplot(2,2,2,'Spacing',0.1);
% % % % cla
% % % % plot(afHistCent,AvgResPop / iCounter,'LineWidth',2);
% % % % hold on;
% % % % plot(1:11,a2fAvgResPartPop(iPartA,:),'r','LineWidth',2);
% % % % plot(1:11,a2fAvgResPartPop(iPartB,:),'g','LineWidth',2);
% % % % legend({[acPartNames{iPartA}(2:end),' - ',acPartNames{iPartB}(2:end)],acPartNames{iPartA}(2:end),acPartNames{iPartB}(2:end)})
% % % % xlabel('Intensity Difference (and intensity)');
% % % % ylabel('Firing rate - baseline');
% % % % title('Population analysis');
% % % % grid on
% % % % set(gca,'xtick',-11:11);
% % % % 
% % % % %%
% % % % 
% % % % % Most powerful relationships
% % % % [afDummy, aiSortIdx] = sort(afConsistencyNeg + afConsistencyPos,'descend');
% % % % 
% % % % 
% % % % figure(3);
% % % % clf;
% % % % iSelectedRatioPop = aiSortIdx(1);
% % % % iCounter= 0;
% % % % a2fAvgResPartPop = zeros(11,11);
% % % % for iExpIter=1:length(aiSinha)
% % % %     iExperiment = aiSinha(iExpIter);
% % % %     switch acUnits{iExperiment}.m_strImageListDescrip
% % % %         case 'SinhaFOB'
% % % %             aiCatInd = 7:7+iNumRatios-1;
% % % %             iOffset = 96;
% % % %         case 'Sinha'
% % % %             aiCatInd = 1:iNumRatios;
% % % %             iOffset = 0;
% % % %     end
% % % %     aiY = aiCatInd;
% % % %     aiX = aiCatInd+iNumRatios;
% % % %     aiInd = sub2ind(size(acUnits{iExperiment}.m_a2bSignificantCat), aiY,aiX);
% % % %     afPValue = acUnits{iExperiment}.m_a2fPValueCat(aiInd);
% % % %     aiPeriStimulusRangeMS = acUnits{iExperiment}.m_strctStatParams.m_iBeforeMS:acUnits{iExperiment}.m_strctStatParams.m_iAfterMS;
% % % %     iStartAvg = find(aiPeriStimulusRangeMS>=acUnits{iExperiment}.m_strctStatParams.m_fStartAvgMS,1,'first');
% % % %     iEndAvg = find(aiPeriStimulusRangeMS>=acUnits{iExperiment}.m_strctStatParams.m_fEndAvgMS,1,'first');
% % % %     iStartBaseAvg = find(aiPeriStimulusRangeMS>=acUnits{iExperiment}.m_strctStatParams.m_fStartBaselineAvgMS,1,'first');
% % % %     iEndBaseAvg = find(aiPeriStimulusRangeMS>=acUnits{iExperiment}.m_strctStatParams.m_fEndBaselineAvgMS,1,'first');
% % % % 
% % % %     afAvgStimulusResponse = mean(acUnits{iExperiment}.m_a2fAvgFirintRate_Stimulus(:,iStartAvg:iEndAvg),2);
% % % %     afBaseline = mean(acUnits{iExperiment}.m_a2fAvgFirintRate_Stimulus(:,iStartBaseAvg:iEndBaseAvg),2);
% % % %         
% % % %     if afPValue(iSelectedRatioPop) <=pThreshold
% % % %       iRatio=iSelectedRatioPop;
% % % %         iPartA = a2iPartRatio(iRatio,1);
% % % %         iPartB = a2iPartRatio(iRatio,2);
% % % %          
% % % %         iCounter = iCounter + 1;
% % % %         a2fAvgResPart = zeros(iNumParts,iNumParts);
% % % %         for iIntIter1=1:iNumParts
% % % %             for iIntIter2=1:iNumParts
% % % %                 aiRelevant = find(a2iEdges(:,iPartA) == iIntIter1 & a2iEdges(:,iPartB) == iIntIter2);
% % % %                 if ~isempty(aiRelevant)
% % % %                     a2fAvgResPart(iIntIter1, iIntIter2) = mean(afAvgStimulusResponse(iOffset + aiRelevant))-mean(afBaseline(iOffset + aiRelevant));
% % % %                 end;
% % % %             end
% % % %         end
% % % %         a2fAvgResPartPop = a2fAvgResPartPop + a2fAvgResPart;
% % % %     end;
% % % %     tightsubplot(3,4,iCounter,'Spacing',0.05)
% % % %     imagesc(a2fAvgResPart);
% % % %     set(gca,'xTick',1:11,'yTick',1:11);
% % % %  end;
% % % %    colormap jet;
% % % % colorbar
% % % % dbg = 1;
% % % % 
% % % % %%
% % % % % 
% % % % % plot(aiRatioLinear.^2, aiRatioEdge.^2,'r.'); hold on;
% % % % % plot(aiRatioLinear.^2, aiLinearEdge.^2,'b.')
% % % % % 
% % % % % hold on;
% % % % % plot([0 1 ],[0 1],'k');
% % % % % axis([0 1 0 1]);
% % % % % 
% % % % %   
% % % % %         P = POLYFIT(afHistCent(aiInd),afAvgRes(aiInd),2) ;
% % % % %         afPolyModel = polyval(P, afHistCent);
% % % % %         Rpoly2 = corr(afAvgRes(aiInd)',afPolyModel(aiInd)');
% % % % %     end
% % % % % end
% % % % 
% % % % 
% % % % 
% % % % 
% % % % 
% % % % 
% % % % % 
% % % % % 
% % % % % % Compute Face Selectivity index
% % % % % %aiSinha= find(abSinhaExperiments);
% % % % % iNumSinhaExperiments = length(aiSinha);
% % % % % iNumCategories = nchoosek(11,2);
% % % % % afSignificant = zeros(1,iNumCategories);
% % % % % afConsistencyPos = zeros(1,iNumCategories);
% % % % % afConsistencyNeg = zeros(1,iNumCategories);
% % % % % 
% % % % % afNumSigCatPerUnit = zeros(1,iNumSinhaExperiments);
% % % % % for iExpIter=1:iNumSinhaExperiments
% % % % %     abSig = zeros(1,iNumCategories);
% % % % %     for iCatIter=1:iNumCategories
% % % % %         abSig(iCatIter) = acUnits{aiSinha(iExpIter)}.m_a2bSignificantCat(iCatIter, iCatIter + iNumCategories);
% % % % %         afSignificant(iCatIter) = afSignificant(iCatIter) + acUnits{aiSinha(iExpIter)}.m_a2bSignificantCat(iCatIter, iCatIter + iNumCategories);
% % % % %         if acUnits{aiSinha(iExpIter)}.m_a2bSignificantCat(iCatIter, iCatIter + iNumCategories)
% % % % %             if acUnits{aiSinha(iExpIter)}.m_afAvgFiringSamplesCategory(iCatIter) > acUnits{aiSinha(iExpIter)}.m_afAvgFiringSamplesCategory(iCatIter+ iNumCategories)
% % % % %                 afConsistencyPos(iCatIter) = afConsistencyPos(iCatIter) + 1;
% % % % %             else
% % % % %                 afConsistencyNeg(iCatIter) = afConsistencyNeg(iCatIter) + 1;
% % % % %             end
% % % % %         end;
% % % % %     end
% % % % %     afNumSigCatPerUnit(iExpIter) = sum(abSig);
% % % % % end
% % % % % afConsistency = afConsistencyPos ./ (afConsistencyPos + afConsistencyNeg);
% % % % % afSignificant = afSignificant / iNumSinhaExperiments ;
% % % % % [afDummy, aiSortInd] = sort(afSignificant,'descend');
% % % % % 
% % % % % subplot(2,3,3);
% % % % % plot(afSignificant);
% % % % % hold on;
% % % % % plot(aiSortInd(1),afSignificant(aiSortInd(1)),'co');
% % % % % plot(aiSortInd(2),afSignificant(aiSortInd(2)),'mo');
% % % % % plot(aiSortInd(3),afSignificant(aiSortInd(3)),'yo');
% % % % % xlabel('Contrast Categories');
% % % % % ylabel('Cells with significant ratio');
% % % % % legend(['A', acUnits{aiSinha(1)}.m_acCatNames(aiSortInd(1:3))])
% % % % 
% % % % % title(sprintf('Total number of cell: %d',iNumSinhaExperiments));
% % % % % grid on
% % % % % h4=subplot(2,3,4);
% % % % % plot(afConsistency)
% % % % % hold on;
% % % % % plot(afConsistency,'r.')
% % % % % plot(aiSortInd(1),afConsistency(aiSortInd(1)),'co');
% % % % % plot(aiSortInd(2),afConsistency(aiSortInd(2)),'mo');
% % % % % plot(aiSortInd(3),afConsistency(aiSortInd(3)),'yo');
% % % % % axis([1 iNumCategories 0 1])
% % % % % xlabel('Contrast Categories');
% % % % % ylabel('Polarity Consistency');
% % % % % title('Polarity Consistency');
% % % % % h5=subplot(2,3,5);
% % % % % [aiCount, afCent]=hist(afNumSigCatPerUnit,[1:iNumCategories]);
% % % % % bar(afCent,aiCount);
% % % % % xlabel('Num Significant Contrast Categories');
% % % % % ylabel('Num cells');
% % % % 
% % % % return