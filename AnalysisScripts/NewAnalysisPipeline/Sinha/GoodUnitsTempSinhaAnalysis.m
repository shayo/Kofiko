% aiAspectRatio = 602:612; % -5:5
% aiAssemblyHeight = 613:623; % -5:5
% aiEyeDistance = 624:634; % -5:5
% aiIrisSize = 635:643; % -3:5

aiAspectRatio = 1284:1294; % -5:5
aiAssemblyHeight = 1295:1305; % -5:5
aiEyeDistance = 1306:1316; % -5:5
aiIrisSize = 1317:1325; % -4:4

aiSinhaPartsCorrectContrastNoForhead  = 644:771;

aiSinhaPartsCorrectContrast  = 644:899;
aiSinhaPartsIncorrectContrast= 900:1155;
aiCartoonParts= 1156:1283;
%%
iNumUnits = length(acData);
aiStimuli =  aiCartoonParts;

a3fSubset = zeros(length(aiStimuli), 701,iNumUnits);
for iIter=1:iNumUnits
    a3fSubset(:,:,iIter) = acData{iIter}.strctUnit.m_a2fAvgFirintRate_Stimulus(aiStimuli,:);
end
    afTime=acData{1}.strctUnit.m_aiPeriStimulusRangeMS;

clear a3fSubsetNorm
for k=1:iNumUnits
    a3fSubsetNorm(:,:,k) = a3fSubset(:,:,k) / max(max(a3fSubset(:,:,k)));
end
X=mean(a3fSubsetNorm,3);
figure(11);
clf;
imagesc(afTime,aiStimuli,X)
colorbar
%title('Assembly Height');
title('Cartoon Parts');

figure(12);
clf;
for k=1:iNumUnits
    tightsubplot(5,6,k,'Spacing',0.05)
    imagesc(a3fSubsetNorm(:,:,k));
    set(gca,'visible','off');
end
% 
% 
% aiGood = [7,8,9,10,12,13,15,16,20,21,22,23,26,27,30,31,32,33,37];
% 
% Y=mean(X(:,270:370),2)
% plot(Y)
% 
% figure;imagesc(X)
% Very Sparse:
% 19, 29
% 
% Inhibited:
% 28
% 
% Very Long respnse:
% 34,35