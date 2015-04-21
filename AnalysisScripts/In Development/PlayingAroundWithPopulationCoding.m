afKernel = fspecial('gaussian',[1 80],2);
NumStimuli = 549;
T = 701;
N=length(acUnits);
a3fFiring = zeros(NumStimuli, T, N);

for iUnitIter=1:N
    fprintf('Unit %d\n',iUnitIter);
    strctUnit=acUnits{iUnitIter};
    a2fSmooth = NaN*ones(NumStimuli, T);
    for k=1:NumStimuli
        aiInd = find(strctUnit.m_aiStimulusIndexValid == k);
        if ~isempty(aiInd)
            a2fSmooth(k,:) = mean(conv2(double(strctUnit.m_a2bRaster_Valid(aiInd,:)), afKernel,'same'),1);
        end
    end
    a3fFiring(:,:,iUnitIter)=a2fSmooth;
end
S=NumStimuli;
a2fMeanFiring = nanmean(a3fFiring,3);
a2fBigMatrix = reshape(a3fFiring, S*T,N);
abValid = sum(isnan(a2fBigMatrix),2) == 0;
a2fBigMatrixMeanSub  = bsxfun(@minus,a2fBigMatrix,nanmean(a2fBigMatrix,1));
[coeff,ignore] = eig(a2fBigMatrixMeanSub(abValid,:)'*a2fBigMatrixMeanSub(abValid,:));
a2fPCACoeff = fliplr(coeff);
iNumReducedDim = 3;
a2fPCA = a2fBigMatrixMeanSub*a2fPCACoeff(:,1:iNumReducedDim);
a3fPCAProj = reshape(a2fPCA, S,T,iNumReducedDim);

aiTime = 200:501;
a2fJet = jet(length(aiTime));
a2fFaces = winter(length(aiTime));
a2fObjects = autumn(length(aiTime));
a2fSinha= cool(length(aiTime));

aiSelectedStimuli = [1:6,17:20,125];
figure(11);
clf;
hold on;
for j=1:length(aiSelectedStimuli)
    if aiSelectedStimuli(j) <= 16
        for q=1:length(aiTime)-1
            plot(a3fPCAProj(aiSelectedStimuli(j),aiTime(q:q+1),1),a3fPCAProj(aiSelectedStimuli(j),aiTime(q:q+1),2),...
                'color',a2fFaces(q,:));
                %a3fPCAProj(aiSelectedStimuli(j),aiTime(q:q+1),3)            ,
        end        
    elseif aiSelectedStimuli(j) <= 96
        for q=1:length(aiTime)-1
            plot(a3fPCAProj(aiSelectedStimuli(j),aiTime(q:q+1),1),a3fPCAProj(aiSelectedStimuli(j),aiTime(q:q+1),2),...
                'color',a2fObjects(q,:));
                %a3fPCAProj(aiSelectedStimuli(j),aiTime(q:q+1),3)            ,
        end
    else 
        for q=1:length(aiTime)-1
            plot(a3fPCAProj(aiSelectedStimuli(j),aiTime(q:q+1),1),a3fPCAProj(aiSelectedStimuli(j),aiTime(q:q+1),2),...
                'color',a2fSinha(q,:));
                %a3fPCAProj(aiSelectedStimuli(j),aiTime(q:q+1),3)            ,
        end
    end        
end

axis equal
figure(12);
clf;hold on;
for q=1:length(aiTime)-1
    plot(aiTime([q,q+1]),a2fMeanFiring(aiSelectedStimuli(aiSelectedStimuli<=16),aiTime(q:q+1)),'color',a2fFaces(q,:));
    plot(aiTime([q,q+1]),a2fMeanFiring(aiSelectedStimuli(aiSelectedStimuli>16),aiTime(q:q+1)),'color',a2fObjects(q,:));
end
%%
figure(11);
clf;
hold on;
H = 3;
for q=11:length(aiTime)
    h3=plot(a3fPCAProj(97:NumStimuli,aiTime(q-H:q),1)',a3fPCAProj(97:NumStimuli,aiTime(q-H:q),2)','b');
    h1=plot(a3fPCAProj(1:16,aiTime(q-H:q),1)',a3fPCAProj(1:16,aiTime(q-H:q),2)','r');
    h2=plot(a3fPCAProj(17:96,aiTime(q-H:q),1)',a3fPCAProj(17:96,aiTime(q-H:q),2)','k');
    
    set(gca,'xlim',[-0.1 0.6],'ylim',[-0.5 0.5]);
    drawnow
    delete([h1;h2;h3]);
    
end



%%
for K=1:20
    [IDC{K},C{K}]=kmeans(a2fSmooth(:,250:460), K);
    afError = zeros(1,K);
    for j=1:K
        N = sum(IDC{K}==j);
        afError(j)=sum(sqrt(sum((a2fSmooth(IDC{K}==j,250:460) - repmat(C{K}(j,:),N,1)).^2,2)));
    end
    E(K) = mean(afError);
end
find(IDC{4} == 1)
find(IDC{4} == 2)
find(IDC{4} == 3)
find(IDC{4} == 4)
