strctRuns1=load('D:\Data\Doris\Data For Publications\FEF Opto\Snapshots from free surfer\Bert\RecordedRuns_1306.mat');
strctRuns2=load('D:\Data\Doris\Data For Publications\FEF Opto\Snapshots from free surfer\Bert\RecordedRuns_1306.mat');
strctRuns =[ strctRuns1.astrctRuns,strctRuns2.astrctRuns];
afTime = strctRuns(1).m_strctEyePos.m_afTime-strctRuns(1).m_strctEyePos.m_afTime(1);
   iNumRuns =length(strctRuns);
 
afGrayOnset = [0,40,80,120,160,200,240]*2;
afOpticalOnset = [20, 180]*2;
afBoth = [100,220]*2;
afElectricalOnset = [60,140]*2;
acCondition = {afGrayOnset,afOpticalOnset ,afBoth ,afElectricalOnset };
N = 52000;
X = zeros(iNumRuns, N);
Y = zeros(iNumRuns, N);
for k=1:iNumRuns
    X(k,:) = strctRuns(k).m_strctEyePos.m_afXpix(1:N);
    Y(k,:) = strctRuns(k).m_strctEyePos.m_afYpix(1:N);
end
 
%  Align to block onset...
iAlignIndex= find(afTime >= 60,1,'first');
Xa = X - repmat(X(:,iAlignIndex), 1,N);
Ya = Y - repmat(Y(:,iAlignIndex), 1,N);

afMeanX  = mean(Xa,1);
afMeanY  = mean(Ya,1);

afMeanGaze = sqrt(afMeanX.^2+ afMeanY.^2);

figure(200);
clf;
plot(afTime(1:N),afMeanGaze);
hold on;
plot(ones(1,2)*afTime(iAlignIndex),[0 5000],'r');

Xa = X(:,iAlignIndex)


%    
% W = 400;
% iSelectedRun = 15;
% figure(201);
% clf;
% for k=W:10:length(strctRuns(iSelectedRun).m_strctEyePos.m_afXpix)-W
%     plot(strctRuns(iSelectedRun).m_strctEyePos.m_afXpix(k-W+1:k),...
%         strctRuns(iSelectedRun).m_strctEyePos.m_afYpix(k-W+1:k),'k');
%     hold on;
%     plot(strctRuns(iSelectedRun).m_strctEyePos.m_afXpix(k),...
%         strctRuns(iSelectedRun).m_strctEyePos.m_afYpix(k),'r+');
%     
%     plot(512,384,'g+');
%     
%     hold off;
%     axis([-5000 5000 -5000 5000]);
%     title(num2str(afTime(k)));
%     drawnow
%     
% end

 %%
 clear a2fRadius
for iCondIter=1:4
    
    abInterval = zeros(1,length(afTime)) > 0;
    for iRepIter=1:length(acCondition{iCondIter})
        abInterval( afTime >= acCondition{iCondIter}(iRepIter) & afTime <= acCondition{iCondIter}(iRepIter) + 40) = true;
    end
    
    afX = [];
    afY = [];
    X0 = 512;
    Y0 = 384;
    for iRun=1:iNumRuns
        afX = [afX, strctRuns(iRun).m_strctEyePos.m_afXpix(abInterval)-X0];
        afY = [afY, strctRuns(iRun).m_strctEyePos.m_afYpix(abInterval)-Y0];
    end
    acRadius{iCondIter} = sqrt(afX.^2+afY.^2);
    
    afXRange = -1500:20:1500;
    afYRange = -1000:20:1000;
    a2fHist  = hist2mod(afX, afY, afXRange, afYRange);
    a2fHist = a2fHist / sum(a2fHist(:));
    a2fHist = conv2(a2fHist, fspecial('gaussian',[20 20],2),'same');
    % tightsubplot(2,2,iCondIter);
    figure(100+iCondIter);clf;
    imagesc(afXRange,afYRange,a2fHist)
    hold on;
    aftheta= linspace(0,2*pi,100);
    frad = 50;
%     plot(frad *cos(aftheta),frad *sin(aftheta),'w','linewidth',2);
    axis off
    colormap gray
     set(gcf,'position',[101+200*iCondIter   908   116    90]);
end
%%
afCent = 0:50:2000;
[afHist1]=histc(acRadius{1},afCent);
[afHist2]=histc(acRadius{2},afCent);
[afHist3]=histc(acRadius{3},afCent);
[afHist4]=histc(acRadius{4},afCent);
afHist1=afHist1/sum(afHist1);
afHist2=afHist2/sum(afHist2);
afHist3=afHist3/sum(afHist3);
afHist4=afHist4/sum(afHist4);

figure(12); clf; hold on;
plot(afCent,(afHist1),'k');
plot(afCent,(afHist2),'r');
plot(afCent,(afHist3),'g');
plot(afCent,(afHist4),'b');

[h,p,c]=ttest2(acRadius{3},acRadius{4})
