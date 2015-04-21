addpath('C:\Users\shayo\Dropbox (MIT)\Code\AI\t-sne\tSNE_matlab');
addpath('C:\Users\shayo\Dropbox (MIT)\Code\AI\t-sne\bh_tsne');
strInputFile ='E:\Old Ephys Data\100720_110306_Houdini.plx';
iChannel = 1;
try
    for iUnitIter=1:4
        fprintf('Reading unit %d\n',iUnitIter);
        strctSpikes(iUnitIter).m_iChannel = iChannel;
        strctSpikes(iUnitIter).m_iUnit = iUnitIter;
        [nts, strctSpikes(iUnitIter).m_afTimestamps] = plx_ts(strInputFile, iChannel, iUnitIter);
        [nwf, npw, tswf, strctSpikes(iUnitIter).m_a2fWaveforms] = plx_waves_v(strInputFile,iChannel, iUnitIter);
    end
end

W=cat(1,strctSpikes.m_a2fWaveforms);
Wsmall = W(1:100:end,:);
A=GetSecs();
Xtsne = fast_tsne(W);
B=GetSecs();
fprintf('Elapsed Time: %.2f\n',B-A);
figure(11);
clf;
plot(Xtsne(:,1),Xtsne(:,2),'.');


Xtsne = tsne(Wsmall);
Xpca=my_pca(Wsmall, 2);

K = 8;
idxPCA = kmeans(Xpca,K);
idxTsne = kmeans(Xtsne,K);
% 
% for method = 1:2
% for k=1:5
%     if method == 1
%         a2fWaveforms = Wsmall(idxPCA == k,:);
%     else
%         a2fWaveforms = Wsmall(idxTsne == k,:);        
%     end
%     afMean = mean(a2fWaveforms,1);
%     fDenominator = (max(afMean(:))-min(afMean(:)));
%     a2fDiff = a2fWaveforms-repmat(afMean,size(a2fWaveforms,1),1);
%     SDe = std(a2fDiff(:));
%     a2fSNR(k,method) = fDenominator / (2*SDe);
%     
% end
% end

%%
a2fColors=lines(K);
figure(11);
clf;
subplot(2,2,1);
hold on;
for k=1:K
    plot(Xpca(idxPCA == k,1),Xpca(idxPCA == k,2),'.','color',a2fColors(k,:));
end
title('PCA');
subplot(2,2,2);
hold on;
for k=1:K
    plot(Xtsne(idxTsne == k,1),Xtsne(idxTsne == k,2),'.','color',a2fColors(k,:));
end
title('t-SNE');

subplot(2,2,3);
title('PCA cluster');
hold on;
for k=1:K
    plot(mean(Wsmall(idxPCA == k,:),1),'color',a2fColors(k,:));
end


subplot(2,2,4);
title('t-SNE cluster');
hold on;
for k=1:K
    plot(mean(Wsmall(idxTsne == k,:),1),'color',a2fColors(k,:));
end
% 
% figure(15);clf;
% for k=1:K
%     subplot(2,K, k)
%     plot(Wsmall(idxPCA == k,:)');
%     subplot(2,K, k+K)
%     plot(Wsmall(idxTsne == k,:)');
%     
% end

set (gcf, 'WindowButtonMotionFcn', {@PlayingAroundWithTsneCallback,Wsmall,Xtsne});

