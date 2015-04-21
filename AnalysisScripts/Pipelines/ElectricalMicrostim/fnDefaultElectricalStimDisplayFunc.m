function fnDefaultElectricalStimDisplayFunc(ahPanels, strctData)
dbg =1 ;

iNumEvents = length(strctData.m_astrctStimulation);
iNowRows = ceil(sqrt(iNumEvents));
iNumCols = ceil(iNumEvents / iNowRows);

afTime = strctData.m_afRangeMS;
aiTimeRestricted = find(afTime >= 0 & afTime <= 150);

iCounter = 1;
for i=1:iNowRows
    for j=1:iNumCols
        h=tightsubplot(iNowRows,iNumCols,iCounter,'Spacing',0.1,'Parent',ahPanels(1));
        hold on;
        iNumStim = length(strctData.m_astrctStimulation(iCounter).m_afTrainOnset);
        plot(h,0,0,'ro');
        afMax = zeros(1,iNumStim );
        afMinX=zeros(1,iNumStim );
        afMaxX=zeros(1,iNumStim );
        afMaxY=zeros(1,iNumStim );
        afMinY=zeros(1,iNumStim );
        for k=1:iNumStim 
            afX = strctData.m_astrctStimulation(iCounter).m_a2fXpix(k,aiTimeRestricted);
            afY = strctData.m_astrctStimulation(iCounter).m_a2fYpix(k,aiTimeRestricted);
            afMax(k)=max(sqrt((afX-afX(1)).^2+(afY-afY(1)).^2));
            afMinX(k) = min(afX-afX(1));
            afMaxX(k) = max(afX-afX(1));
            afMaxY(k) = max(-(afY-afY(1)));
            afMinY(k) = min(-(afY-afY(1)));
            plot(h,afX-afX(1),-(afY-afY(1)),'k');
            plot(h,afX(end)-afX(1),-(afY(end)-afY(1)),'r+');
        end
        axis equal
        axis([-800 800 -800 800]);
        fPercSaccade = sum(afMax>40 & afMaxY > 40)/length(afMax)*100;
        if ~isfield(strctData.m_astrctStimulation(iCounter),'m_fAmplitude')
            strctData.m_astrctStimulation(iCounter).m_fAmplitude = NaN;
        end;
         title(sprintf('%d at %.2f mm , Amplitude %.2f, Success %.2f%% (%d stim)',iCounter, strctData.m_astrctStimulation(iCounter).m_fDepth,...
             strctData.m_astrctStimulation(iCounter).m_fAmplitude,fPercSaccade, length(afMax)));
        iCounter=iCounter+1;
        if iCounter > length(strctData.m_astrctStimulation)
            break;
        end;
    end
end

P=cat(1,strctData.m_astrctStimulation.m_a2fPupil_nozero);
X= cat(1,strctData.m_astrctStimulation.m_a2fXpix);
Y= cat(1,strctData.m_astrctStimulation.m_a2fYpix);
D=sqrt(X.^2+Y.^2);
M=max(D,[],2);
NoSaccade=M<80;

PIX_TO_MM = 10/128;
Pns=P(NoSaccade,:);
P0=Pns-repmat(Pns(:,1),[1,size(Pns,2)]);
h=axes('Parent',ahPanels(2));
hold on;
plot(-200:500,PIX_TO_MM*P0','color',[0.5 0.5 0.5]);
plot(-200:500,PIX_TO_MM*mean(P0),'color',[0 0 0]);
plot([-200 500],[0 0],'k--');
% 
% iCounter = 1;
% for i=1:iNowRows
%     for j=1:iNumCols
%         h=tightsubplot(iNowRows,iNumCols,iCounter,'Spacing',0.1,'Parent',ahPanels(2));
%         hold on;
%         P=strctData.m_astrctStimulation(iCounter).m_a2fPupil_nozero-repmat(strctData.m_astrctStimulation(iCounter).m_a2fPupil_nozero(:,1),[1,size(strctData.m_astrctStimulation(iCounter).m_a2fPupil_nozero,2)]);
%         abOutliers = max(abs(P),[],2) > 150;
% %         P2 = P(~abOutliers,:);
% %         for k=1:701
% %             [A,afP(k)]=ttest(P2(:,k));
% %         end
%         plot(-200:500,P(~abOutliers,:)','color',[0.5 0.5 0.5])
%         hold on;
%         plot(-200:500,median(P(~abOutliers,:),1),'color',[0 0 0])
%         plot([-200 500],[0 0],'k--');
%         iCounter=iCounter+1;
%         if iCounter > length(strctData.m_astrctStimulation)
%             break;
%         end;
%     end
% end
