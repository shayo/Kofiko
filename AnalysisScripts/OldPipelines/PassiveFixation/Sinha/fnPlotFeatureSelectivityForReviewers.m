figure(1);
X = [aiFaceSelectivityIndex > 0.3;afdPrimeBaselineSub > 0.5; afAUC > 0.5 & afPvalue_AUC < 0.05];
figure;imagesc(1-X); colormap gray
set(gca,'ytick',[1 2 3],'yticklabel',{'FSI','D''','AUC'});
xlabel('Units');

clf;
plot(aiFaceSelectivityIndex)
plot(afdPrime)
plot(afdPrimeBaselineSub)
plot(afAUC)
plot(afAUCBaselineSub)
afPvalue_AUC
afPvalue_AUC_BaslineSub


fPValue = 1e-5;


iNumUnits = length(acUnits);

[a2iSigRatio, acNames, aiSinhaRatio,abASmallerB, aiNumSignificant,a2bSigPair] = fnCalcSigRatiosSinha(acUnits(aiFaceSelectivityIndex > 0.3), fPValue);
figure(7);clf;subplot(3,1,1);
fnPlotFeaturePolarity(a2iSigRatio,aiSinhaRatio,abASmallerB)
title('FSI');
[a2iSigRatio, acNames, aiSinhaRatio,abASmallerB, aiNumSignificant,a2bSigPair] = fnCalcSigRatiosSinha(acUnits(afdPrimeBaselineSub > 0.5), fPValue);
figure(7);subplot(3,1,2);
fnPlotFeaturePolarity(a2iSigRatio,aiSinhaRatio,abASmallerB)
title('D prime');
[a2iSigRatio, acNames, aiSinhaRatio,abASmallerB, aiNumSignificant,a2bSigPair] = fnCalcSigRatiosSinha(acUnits(afAUC > 0.5 & afPvalue_AUC < 0.05), fPValue);
figure(7);subplot(3,1,3);
fnPlotFeaturePolarity(a2iSigRatio,aiSinhaRatio,abASmallerB)
title('AUC');


[a2iSigRatio, acNames, aiSinhaRatio,abASmallerB, aiNumSignificant,a2bSigPair] = fnCalcSigRatiosSinha(acUnits);


%%
save('a2fTuned','a2fTuned')
strctTmp = load('D:\Code\Doris\Stimuli_Generating_Code\Sinha\a3bPartMasks.mat');
a3bPartMasks = zeros(size(strctTmp.a3bPartMasks))>0;
a3bPartMasks(:,:,1) = strctTmp.a3bPartMasks(:,:,1);
    [i,j]=find(a3bPartMasks(:,:,1));
    apt2fCenter(1,:) = [mean(j),mean(i)];
for k=2:11
    a3bPartMasks(:,:,k) = strctTmp.a3bPartMasks(:,:,k)& ~sum(a3bPartMasks,3)>0;
    [i,j]=find(a3bPartMasks(:,:,k));
    apt2fCenter(k,:) = [mean(j),mean(i)];
end

figure(10);
clf;

iNumTuned= size(a2fTuned,1);
iHeight = size(strctTmp.a3bPartMasks,1);
iWidth = size(strctTmp.a3bPartMasks,2);
for iUnitIter=1:iNumTuned
    Tmp=a2iPartRatio(a2fTuned(iUnitIter,:)>0,:);
    aiPartHist = histc(Tmp(:),1:11);
    a2iFace = zeros(iHeight,iWidth);
    for iPartIter=1:11
        a2iFace = a2iFace + double(a3bPartMasks(:,:,iPartIter))*aiPartHist(iPartIter);
    end
    a2iFace = a2iFace(1:4:end,1:4:end);
    tightsubplot(11,11, iUnitIter);
    imagesc(a2iFace);
    axis('off')
    drawnow
end

    colormap hot
figure(11);
clf;

[a2iSigRatio, acNames, aiSinhaRatio,abASmallerB, aiNumSignificant,a2bSigPair] = fnCalcSigRatiosSinha(acUnits, 1e-3);
aiTuned = find(aiNumSignificant>0);
a2fTuned = a2bSigPair(aiTuned,:);

iNumTuned= size(a2fTuned,1);
iHeight = size(strctTmp.a3bPartMasks,1);
iWidth = size(strctTmp.a3bPartMasks,2);
a2bTunedParts = zeros(iNumTuned,11);
for iUnitIter=1:iNumTuned
    Tmp=a2iPartRatio(a2fTuned(iUnitIter,:)>0,:);
    aiPartHist = histc(Tmp(:),1:11);
    
    aiNumTunedParts(iUnitIter) = sum(aiPartHist > 0);
    aiNumPairs(iUnitIter) = sum(a2fTuned(iUnitIter,:)>0);
    aiNumPossiblePairs(iUnitIter) = nchoosek( aiNumTunedParts(iUnitIter),2 );
    a2bTunedParts(iUnitIter,:) = aiPartHist;
    a2iFace = zeros(iHeight,iWidth);
    for iPartIter=1:11
        if aiPartHist(iPartIter) > 0
            a2iFace(a3bPartMasks(:,:,iPartIter)) = iPartIter;
        end
    end
    a2iFace = a2iFace / 11;
    a2iFace = a2iFace(1:4:end,1:4:end);
    tightsubplot(11,11, iUnitIter);
    a3iFace(:,:,1)=a2iFace;
    a3iFace(:,:,2)=a2iFace;
    a3iFace(:,:,3)=a2iFace;
    imagesc(a3iFace);
     hold on;
     
    for j=1:size(Tmp,1)
        if Tmp(j,1) == 2 ||  Tmp(j,1) == 4 || Tmp(j,2) == 2 || Tmp(j,2) == 4  
            plot([apt2fCenter( Tmp(j,1),1) apt2fCenter( Tmp(j,2),1)]/4,[apt2fCenter( Tmp(j,1),2) apt2fCenter( Tmp(j,2),2)]/4,'color','y');
        else
            plot([apt2fCenter( Tmp(j,1),1) apt2fCenter( Tmp(j,2),1)]/4,[apt2fCenter( Tmp(j,1),2) apt2fCenter( Tmp(j,2),2)]/4,'color','g');
        end
    end
    axis off
    drawnow
end

figure(1);


y=sum(a2bTunedParts > 0,1)
for i=1:11
    fprintf('%s %d\n',acPartNames{i},y(i));
end
a2bTunedParts(:,[2,4])



for k=2:11
    aiComb(k) = nchoosek(k,2);
end

figure(1001);
clf;
 plot(1:11,aiComb,'k');hold on;
plot(aiNumTunedParts,   aiNumPairs,'.');
xlabel('Num tuned parts');
ylabel('Num Tuned pairs');
hold on;
legend({'Max possible pairs','Actual Data'},'Location','NorthEastOutside');
axis([0 12 0 56])
set(gca,'xtick',0:11)
