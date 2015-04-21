function fnDisplaySinhaAnalysis(ahPanels, strctUnit)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)


ahSubPlots = fnDisplayPassiveFixation(ahPanels,strctUnit);
if ~isfield(strctUnit,'m_acSinhaPlots')
    return;
end;

if ~isfield(strctUnit.m_acSinhaPlots{1},'m_acPartNames')
acPartNames = {'Forehead','L Eye','Nose','R Eye','L Cheek','Up Lip','R Cheek','LL Cheek','Mouth','LR Cheek','Chin'};

else
    acPartNames =  strctUnit.m_acSinhaPlots{1}.m_acPartNames;
end

h=tightsubplot(2,2,1,'Parent',ahPanels(3),'Spacing',0.1);
plot(strctUnit.m_acSinhaPlots{2}.m_a2fPartIntensityMean(1:5,:)','LineWidth',2);hold on;
plot(strctUnit.m_acSinhaPlots{2}.m_a2fPartIntensityMean(6:11,:)','--','LineWidth',2);
xlabel('Intensity');
ylabel('Avg. Firing Rate');
axis([1 11 min(strctUnit.m_acSinhaPlots{2}.m_a2fPartIntensityMean(:))-eps eps+max(strctUnit.m_acSinhaPlots{2}.m_a2fPartIntensityMean(:))]);
legend(acPartNames,'fontsize',6);

h=tightsubplot(2,2,2,'Parent',ahPanels(3),'Spacing',0.1);
plot(strctUnit.m_acSinhaPlots{4}.m_afIncorrectRatioResponse,'LineWidth',2);
xlabel('Number of incorrect ratios');
ylabel('Avg. Firing Rate');
axis([0 12 0 eps+1.1*max(strctUnit.m_acSinhaPlots{4}.m_afIncorrectRatioResponse(:))]);
grid on
h=subplot(2,1,2,'Parent',ahPanels(3));
bar(strctUnit.m_acSinhaPlots{3}.m_a2fPolarDiff);

afMaxRes = max(strctUnit.m_acSinhaPlots{3}.m_a2fPolarDiff,[],2);

fSig = 0.01;
aiSig = find(strctUnit.m_acSinhaPlots{3}.m_afPolarDiffPvalue < fSig);
hold on ;
plot(aiSig, afMaxRes(aiSig)*1.05,'r*');
axis([1 55 min(afMaxRes)*1.1-eps eps+max(afMaxRes)*1.1])
xlabel('Ratio-Pair');
ylabel('Response');
legend('A > B','A < B')

h=axes('parent',ahPanels(5));
%h=tightsubplot(2,2,1,'Parent',ahPanels(4),'Spacing',0.1);
aiPos = find(strctUnit.m_acSinhaPlots{3}.m_afPolarityDirection>0);
aiNeg = find(strctUnit.m_acSinhaPlots{3}.m_afPolarityDirection<0);
if ~isempty(aiPos)
    bar(aiPos, ones(size(aiPos)),'FaceColor','b'); hold on;
end
if ~isempty(aiNeg)
    bar(aiNeg, -ones(size(aiNeg)),'FaceColor','r')
end

aiNegSinha = [ 13    30    11    53    54];
aiPosSinha = [ 1     3    20    22    38    47    50];

bar(aiPosSinha, 0.1*ones(size(aiPosSinha)),'FaceColor','g'); hold on;
bar(aiNegSinha, -0.1*ones(size(aiNegSinha)),'FaceColor','g'); hold on;
xlabel('Ratio Pairs');
set(h,'ytick',[-1 1],'yticklabel',{'A < B','A > B'},'xtick',1:2:55);
axis([1 55 -1 1]);
title('Significant Ratio Pairs and their polarity. Green is Sinha proposed polarity');
% 
% figure(5);
% clf;
% for k=1:12
%     iSelectedPair = aiSinhaRatio(k);
%     iPartA = a2iPartRatio(iSelectedPair,1);
%     iPartB = a2iPartRatio(iSelectedPair,2);
% 
%     subplot(3,4,k);
%     imagesc(a3fContrast(:,:,k))
%     xlabel(acPartNames{iPartB});
%     ylabel(acPartNames{iPartA});
% end







% 
% 
% iNumParts = length(strctUnit.m_acPartsName);
% iNumContrastLevels = size(strctUnit.m_a2fAvgPartContrastResponse,2);
% 
% h=subplot(2,2,1,'Parent',ahPanels(2));
% image([],[],strctUnit.m_a2fAvgPartContrastResponse,'parent',h);
% colorbar
% xlabel('Contrast level');
% ylabel('Parts');
% set(h,'YTick',1:iNumParts);    
% set(h,'XTick',1:iNumContrastLevels);    
% set(h,'YTickLabel',strctUnit.m_acPartsName);
% 
% h1 = tightsubplot(2,1,2,'Spacing',0.1,'Parent',ahPanels(2));
% X = [strctUnit.m_afAvgFiringSamplesCategory(1:55),strctUnit.m_afAvgFiringSamplesCategory(56:56+54)];
% bar(X,'group','parent',h1);
% xlabel('Ratio');
% ylabel('Firing Rate');
% hold on;
% p1=plot([1 55],[strctUnit.m_afAvgFiringSamplesCategory(end-1) strctUnit.m_afAvgFiringSamplesCategory(end-1)],'g','LineWidth',2);
% p2=plot([1 55],[strctUnit.m_afAvgFiringSamplesCategory(end) strctUnit.m_afAvgFiringSamplesCategory(end)],'c','LineWidth',2);
% 
% iNumRatios = 55;
% fSigLevel = 0.05;
% for k=1:iNumRatios
%     if strctUnit.m_a2fPValueCat(k,k+55) < fSigLevel
%         
%         fMax = max(strctUnit.m_afAvgFiringSamplesCategory(k),strctUnit.m_afAvgFiringSamplesCategory(k+55));
%         if  strctUnit.m_a2fPValueCat(k,end) < fSigLevel &&  strctUnit.m_a2fPValueCat(k+55,end)  < fSigLevel 
%             plot(h1, k, fMax*1.2,'r*');
%         else
%             plot(h1, k, fMax*1.2,'r+');
%         end;
%     end;
% end;
% 
% %text(k, fMax,'Test Bal bAlv khf kdsjfkdsjhf ksjdf','Rotation',90)
% 
% 
% if isempty(g_a3iAllSinhaStimuli)
%     strImageList = '\\kofiko\StimulusSet\Sinha_randbackAndControl\128x128\List.txt';
%     if ~exist(strImageList,'file')
%         strImageList = 'D:\Data\Doris\Stimuli\Sinha_randbackAndControl\128x128\List.txt';
%     end
%     
%     [acFileNames] = fnReadImageList(strImageList);
%     I = imread(acFileNames{1});
%     g_a3iAllSinhaStimuli = zeros([size(I), length(acFileNames)]);
%     for k=1:length(acFileNames)
%         g_a3iAllSinhaStimuli(:,:,k) = imread(acFileNames{k});
%     end
% end
% 
% aiPeriStimulusRangeMS = strctUnit.m_aiPeriStimulusRangeMS;
% iStartAvg = find(aiPeriStimulusRangeMS>=strctUnit.m_strctStatParams.m_fStartAvgMS,1,'first');
% iEndAvg = find(aiPeriStimulusRangeMS>=strctUnit.m_strctStatParams.m_fEndAvgMS,1,'first');
% 
% afAvgStimulusResponse = mean(strctUnit.m_a2fAvgFirintRate_Stimulus(:,iStartAvg:iEndAvg),2);
% afWeights = afAvgStimulusResponse / sum(afAvgStimulusResponse);
% 
% 
% a2fAvgImage = zeros(size(g_a3iAllSinhaStimuli(:,:,1)));
% for k=1:size(g_a3iAllSinhaStimuli,3)
%     a2fAvgImage = a2fAvgImage + afWeights(k) * g_a3iAllSinhaStimuli(:,:,k);
% end
% 
% h3 = axes('parent',ahPanels(3));
% imshow(a2fAvgImage - mean(g_a3iAllSinhaStimuli,3),[],'parent',h3);
% colorbar
% colormap jet
% 
% afTmp = afAvgStimulusResponse;
% afTmp = afTmp / max(afTmp);
% 
% 

return;

function B=fnDup3(A)
B = zeros([size(A),3]);
B(:,:,1)=A;
B(:,:,2)=A;
B(:,:,3)=A;
return;

