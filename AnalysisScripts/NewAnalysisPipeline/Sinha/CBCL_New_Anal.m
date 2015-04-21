iNumUnits = length(acUnits);
a3fAll = zeros(411,701,iNumUnits);
a2fRes = zeros(411, iNumUnits);
for iUnitIter=1:iNumUnits
    a3fAll(:,:,iUnitIter) = acUnits{iUnitIter}.m_a2fAvgFirintRate_Stimulus;
    afTmp =  nanmean(acUnits{iUnitIter}.m_a2fAvgFirintRate_Stimulus(:, 280:460),2);
    a2fRes(:,iUnitIter) = afTmp/max(afTmp(:));
end

[a2fSorted,a2iInd]=sort(a2fRes,1);

acFiles=fnReadImageList('D:\Data\Doris\Stimuli\CMU_CBCL_Experiment\CMU_CBCL_Experiment.txt');
a3fI = zeros(100,100, 411);
for k=1:length(acFiles)
    a3fI(:,:,k)=imread(acFiles{k});
end


a3fISorted = zeros(100,100, 411);
for iIter=1:411
    aiInd = a2iInd(iIter,:);
    a3fISorted(:,:,iIter) = mean(a3fI(:,:, aiInd(aiInd<=207) ),3);
end

X=reshape(a3fISorted, 100*100, 411);
[Coeff, Score,Latent]=princomp(X');
figure;plot(Score(:,1))
figure;plot(cumsum(Latent)./sum(Latent))
Y=reshape(Coeff(:,1),100,100)
figure;imshow(Y,[]);
M=reshape(mean(X,2),100,100);

figure(10);
clf;
while (1)
    afRange = [linspace(-1,1, 100),linspace(1,-1, 100)];
    for j=1:length(afRange)
        imshow(M + Y * 1e4*afRange(j),[]);
        title(num2str(j));
        drawnow
    end
end


figure(11);
clf;
for k=1:411
    imshow(a3fISorted(:,:,4),[]);
    drawnow
end;



figure(4);
clf;
plot(median(a2fRes,2))

